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
    $debug = false

    class << self
        def run(argv)
            puts "DEBUG ENABLED" if $debug
            puts "Recived args: #{argv.inspect}" if $debug
            raise 'Must be run as root' unless Process.uid == 0

            #cargar config
            conf = Lambom::Config.new.load(argv)
            
            # executar converxencia
            Lambom::Converger.new(conf).run
        end


        def enable_debug
            $debug = true
        end
    end

end
