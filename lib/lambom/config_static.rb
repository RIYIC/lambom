require 'yaml'
require 'ostruct'

module Lambom
    class Config
        FILE = '/etc/riyic/lambom.conf'

        def self.load
            config = ::OpenStruct.new
            config.server = nil
            config.private_key_file = nil
            config.environment = 'production'
            config.loglevel = 'debug'

            # si non existe o ficheiro de configuracion devolvemos a configuracion inicializada
            # pode que se complete por linea de comandos
            return config unless File.exists?(FILE)

            h = {}
            begin
                h = YAML.load(IO::read(FILE))
            rescue Exception => e
                e.to_s =~ /line (\d+) column/
                raise "Error loading yaml config file #{FILE}, syntax error in line #{$1}"
            end

            puts h.inspect if $debug

            h.each do |k,v|
                if validate(k,v)
                    config.send("#{k}=", v)
                else
                    raise "Invalid value '#{v}' to parameter '#{k}'"
                end
            end
            
            config

        end


        def self.validate(parametro,valor)
            case parametro
            when "server"
                # uuid
                valor =~ /^[\d\w\-]{36}$/
            when "private_key_file"
                #unix path
                valor =~ /^[\w\s.\/\-_+%]+$/i
            when "environment"
                #env de rails
                ["production","development","test"].include?(valor)
            when "loglevel"
                #loglevel de chef
                %w{debug info}.include?(valor)
            else
                false
            end

        end
    end
end
