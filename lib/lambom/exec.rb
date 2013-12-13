module Riyic
    class Exec
        # para incluir o setters automaticos
        extend AttributeMixin

        attr_setter :environment, 
                    :download_cookbooks, 
                    :server_id, 
                    :api_key, 
                    :json_file,
                    :install
    
        def initialize(node,&block)
            @node = node
            @environment = "test"
            @download_cookbooks = false
            @server_id = nil
            @api_key = nil
            @json_file = nil
            @install = false
    
            instance_eval(&block)

            install_riyic if @install
        end
    
        def install_riyic
            base_url = Riyic::API.base_url(@environment)
            @node.ssh "wget -O - #{base_url}/download/install.sh | sudo bash -x"
        end

        def node_json
            #devolve ou ben o json_file ou ben a json obtido da peticion a api de riyic
            
            if @json_file
                File.read(@json_file)
            else
                api = Riyic::API.new(@api_key, @server_id, @environment)
                api.get_server_config
            end

        end
    
        def converge 
            puts "Testeando a convergencia do nodo #{@node.name}"

            if @json_file 
                f = File.read(@json_file)
                @json_file_remote = "/tmp/test_#{String.random}.json"
                @node.ssh("echo -n '#{f}' > #{@json_file_remote}")
            end
            
            cmd = build_cmd
            puts @node.ssh(cmd)
        end

        private
            def build_cmd
                cmd = ["sudo","ryc"]
                cmd.push("-E", @environment) if @environment
                cmd.push("-A", @api_key) if @api_key
                cmd.push("-S", @server_id) if @server_id
                cmd.push("-j", @json_file_remote) if @json_file
                return cmd
            end
    end
end
