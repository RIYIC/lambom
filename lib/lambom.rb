require "oj"
require 'time'
require "mixlib/authentication"
require "mixlib/authentication/signedheaderauth"
require 'digest/sha1'
require 'openssl'
require 'net/http'
require "lambom/colorized_strings"

module Lambom
    $debug = false

    class << self
        def build_node(argv)
            puts "DEBUG ENABLED" if $debug
            puts "args recibidos #{argv.inspect}"
            #Lambom::Node.new().build
        end

        def enable_debug
            $debug = true
        end
    end

end
