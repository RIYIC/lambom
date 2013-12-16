require 'yaml'

module Lambom
    class Config
        FILE = '/etc/riyic/lambom.conf'


        attr_accessor :server, :private_key_file, :environment, :loglevel
        attr_reader :logdir, :logfile

        def initialize
            @server = nil
            @private_key_file = nil
            @environment = 'production'
            @loglevel = 'debug'
            @logdir = '/var/log/riyic'
            @logfile = "solo_#{Time.now.strftime("%F_%T")}"
        end

        def load
            # evitamos cascar si o ficheiro de configuracion non existe
            return self unless File.exists?(FILE)

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
                    instance_variable_set "@#{k}".to_sym, v
                else
                    raise "Invalid value '#{v}' to parameter '#{k}'"
                end
            end
            
            self

        end

        def merge(options)
            options.each do |k,v|
                puts "mergeando #{k} con valor #{v} en config" if $debug
                self.send("#{k}=",v) if validate(k,v)
                #instance_variable_set "@#{k}".to_sym, v if validate(k,v)
            end
        end

        def validate(parametro,valor)
            case parametro.to_sym
            when :server
                # uuid
                valor =~ /^[\d\w\-]{36}$/
            when :private_key_file
                #unix path
                valor =~ /^[\w\s.\/\-_+%]+$/i
            when :environment
                #env de rails
                ["production","development","test"].include?(valor)
            when :loglevel
                #loglevel de chef
                %w{debug info}.include?(valor)
            else
                false
                #raise "Invalid parameter #{parametro}"
            end

        end
    end
end
