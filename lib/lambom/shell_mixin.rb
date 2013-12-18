require 'mixlib/shellout'

module Lambom
    module ShellMixin
        def run_cmd(*cmd)

            opts = {}

            if $debug
                puts "RUN_CMD: #{cmd}"
                opts = {:live_stream => STDOUT}
            end

            com = Mixlib::ShellOut.new(cmd, opts)

            com.run_command
            com.error!

            puts "output: #{com.stdout}" if $debug
            com.stdout
        end
    end
end
