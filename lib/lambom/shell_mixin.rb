require 'mixlib/shellout'

module Lambom
    module ShellMixin
        def run_cmd(*cmd)
            puts "RUN_CMD: #{cmd}" if $debug
            com = Mixlib::ShellOut.new(cmd)
            com.run_command
            com.error!
            puts "salida: #{com.stdout}" if $debug
            com.stdout
        end
    end
end
