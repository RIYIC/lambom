require 'mixlib/shellout'
require 'securerandom'

module Lambom
    module ShellMixin
        
        DEFAULT_TIMEOUT = 12000
        
        def run_cmd(*cmd)
            # Seteamos a 200min o timeout por defecto

            opts = {:timeout => DEFAULT_TIMEOUT}

            if $debug
                puts "RUN_CMD: #{cmd}"
                opts[:live_stream] = STDOUT
            end

            com = Mixlib::ShellOut.new(cmd, opts)

            com.run_command
            com.error!

            puts "output: #{com.stdout}" if $debug
            com.stdout
        end

        class String
            def self.random(n)
                SecureRandom.hex(n)
            end
        end
    end
end
