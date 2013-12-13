module Riyic

    class Node
        extend AttributeMixin
        include ShellMixin

        #variables de clase, aqui gardamos un nodo anterior, para encadenar tests
        @@node = nil

        # class method para crear uns metodos check_xxx
        # de forma dinamica, para usar o dsl vps.check_xxx
        def self.define_check_tests(*checks)
            checks.each do |name|
                send :define_method, "check_#{name}" do |objetivo,&block|
                    # construimos o obxeto check dinamicamente
                    # p.ex: Riyic::Check::File
                    # e executamos o seu metodo run 

                    # capitalizamos o nome do check
                    # en caso de que o nome do check sexa composto hai que trozealo
                    # p.ex: external_command  -> ExternalCommand
                    class_name = name.to_s.split('_').map {|p| p.capitalize}.join('')
                    
                    test = Object.const_get("Riyic").
                                  const_get("Check").
                                  const_get(class_name).
                                        new(self,objetivo,&block)
                    status = test.run

                    puts "RESULTADO check_#{name}: ".yellow+((status == "OK")? "OK".green : "KO".red)
                    puts 
                end
            end
        end

        # metodo para gardar o nodo na clase, 
        # para asi poder encadenar tests sin ter que volver a crear o nodo
        def self.set_node(node)
            @@node = node
        end

        def self.get_node
            @@node
        end
        
        attr_setter :driver, :driver_options, :ssh_key, :build_vps
        define_check_tests :file, :command, :port, :process, :external_command , :external_port
        attr_reader :name, :node_attrs
        attr_accessor :already_converged

        def initialize(name,&block)

            # defaults
            @name                   = name
            @node_attrs             = {}
            @vps                    = nil
            @already_converged      = nil

            # atributos a setear en el bloque
            @ssh_key                = "my_ssh_key"
            @driver                 = "lxc"
            @driver_options         = {:base => "ubuntu12.04.2",
                                       :ip   => "10.0.3.100"}
            @build_vps              = true

            
            instance_eval(&block)
            create_vps
        end

        # getter da ip do vps
        def ip
            @vps.ip 
        end

        def ssh(cmd)
            unless ssh_conn_open?(@ssh_conn)
                @ssh_conn = ssh_connect @vps.ip, @vps.ssh_user, :keys => [@ssh_key]
            end

            if cmd.is_a?(Array)
                cmd = cmd.join(" ")
            end

            puts "Enviando #{cmd} a #{@vps.ip} con el user #{@vps.ssh_user}" if $debug
            res = ssh_exec!(@ssh_conn, cmd)
            puts "Resultado:#{res}" if $debug
            res

        end

        def converge(&block)
            return if @already_converged

            r = Riyic::Exec.new(self,&block)
            
            # seteamos os atributos a partir do json do nodo
            @node_attrs = Oj.load(r.node_json)
            
            puts "ATRIBUTOS A SETEAR NO NODO #{@node_attrs}" if $debug

            # executamos a converxencia
            # si peta saimos cos detalles do erro
            begin
                r.converge
            rescue Exception => e
                puts e.message
                puts e.backtrace
                exit(1)
            end
            puts "TEST CONVERGENCIA OK".green
            @already_converged = true

        end
        
          
        
        private
        def create_vps
            puts "Creando vps con nombre #{@name}, driver #{@driver}, options #{@driver_options}"

            #creamos o vps dinamicamente, en funcion do driver/backend
            @vps = Object.const_get("Riyic").
                          const_get("Driver").
                          const_get(@driver.capitalize).
                                        new(@name,@driver_options)

            if @build_vps
                @vps.create
                puts "CREADO OK"
            else
                # si non temos que crear o vps, se supon que xa esta creado
                # asiq solicitamos o driver que cargue os seus parametros
                @vps.load
                puts "VPS CARGADO OK"
            end

            puts "TESTEANDO CONEXION A INTERNET DESDE O NODO"
            i = 0

            while i < 10 do
                return if test_salida_internet
                i+=1
            end

            raise "Vps sin salida a internet".red if i == 10
        end

        def test_salida_internet

            begin
                ssh "ping -c 3 yahoo.es"
            rescue
                sleep 1
                return false
            end

            true
        end

    end
end
