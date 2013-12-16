require "oj"
require 'time'
require "mixlib/authentication"
require "mixlib/authentication/signedheaderauth"
require 'digest/sha1'
require 'openssl'
require 'net/http'

require "lambom/shell_mixin"
require "lambom/config"
require "lambom/api"
require "lambom/converger"


module Lambom
    $debug = true

    class << self
        def run(argv)
            puts "DEBUG ENABLED" if $debug
            puts "args recibidos #{argv.inspect}" if $debug
            
            #cargar config
            conf = Lambom::Config.new.load
            
            # sobreescribimos a configuracion ca linea de comandos
            conf.merge(argv)

            attributes = {}
            # descargar atributos do servidor (a menos que nos pasen json_file => file.json)
            if argv.has_key?("json_file")
                json_attributes = IO.read(argv["json_file"])
            else
                json_attributes = Lambom::ApiClient.new(conf).get_server_config
            end

            # executar converxencia
            Lambom::Converger.new(conf,json_attributes).run
        end


        def enable_debug
            $debug = true
        end
    end

end
