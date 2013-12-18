module Lambom
    class Converger
        include ShellMixin
        
        COOKBOOKS_URL = 'http://www2.ruleyourcloud.com/cookbooks.tar.gz'
        
        DEFAULT_CHEF_PATH = '/var/chef'
        
        CACHE_PATH = "#{DEFAULT_CHEF_PATH}/cache"
        
        ENV_VARS_DELETE = %w{
                         GEM_PATH 
                         RUBY_VERSION 
                         GEM_HOME 
                         MY_RUBY_HOME
                         rvm_bin_path
                         rvm_path
                         rvm_gem_options
                         rvm_prefix
                         rvm_version
        }

        CHEF_CONF_FILE = "#{Lambom::Config::CONFIG_DIR}/solo.rb"
 
        CHEF_CONF_DEV = <<EOF
cookbook_path ["/mnt/opscode/cookbooks", "/mnt/others/cookbooks", "/mnt/riyic/cookbooks"]
file_cache_path "#{CACHE_PATH}"
EOF

        CHEF_CONF_OTHER = <<EOF
cookbook_path ["#{DEFAULT_CHEF_PATH}/cookbooks", "#{DEFAULT_CHEF_PATH}/site-cookbooks"]
file_cache_path "#{CACHE_PATH}"
EOF
        CHEF_CONF = {
            :development => CHEF_CONF_DEV,
            :other => CHEF_CONF_OTHER,
        }

        def initialize(conf, json)
            @conf = conf
            @attributes_json = json
        end


        attr_reader :conf,:attributes_json

        def run
            preparar_entorno

            descargar_cookbooks

            ejecutar_converger
        end


        private

        def ejecutar_converger

            filename = "#{CACHE_PATH}/#{conf.server}.json"
            file = File.new(filename,"w")
            file.write(attributes_json)
            file.close

            cmd = %W{
               chef-solo
               -c #{CHEF_CONF_FILE}
               --log_level #{conf.loglevel}
               -j #{filename}
            }
            
            unless $debug
                cmd += [
                    "--logfile", 
                    "#{conf.logdir}/#{conf.logfile}"
                ]
            end
            
            run_cmd *cmd

        end

        def preparar_entorno
            ENV_VARS_DELETE.each {|v| ENV.delete(v)}
            ENV["PATH"] = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
            
            #creamos directorio de logs
            FileUtils.mkdir_p(conf.logdir) unless File.directory?(conf.logdir)
            File.chmod(0750, conf.logdir)

            #creamos o directorio cache de chef
            FileUtils.mkdir_p(CACHE_PATH) unless File.directory?(CACHE_PATH)
            File.chmod(0750,CACHE_PATH)

            # establecemos o archivo de configuracion de chef segun o entorno
            switch_chef_conf(conf.environment.to_sym)
        end

        def descargar_cookbooks
            unless (conf.environment == 'development')
                # aqui podemos meter unha ejecucion de berkshelf para descargar os cookbooks necesarios
                temp = "/tmp/cookbooks.tar.gz"
                run_cmd('curl','-o',temp, '-L',COOKBOOKS_URL)
                FileUtils.mkdir_p(DEFAULT_CHEF_PATH) unless File.directory?(DEFAULT_CHEF_PATH)
                run_cmd('tar','xzf',temp,'--no-same-owner','-C', DEFAULT_CHEF_PATH)
                File.unlink(temp)
            end
        end

        def switch_chef_conf(env)
            FileUtils.mkdir_p(Lambom::Config::CONFIG_DIR) unless File.directory?(Lambom::Config::CONFIG_DIR)
            File.chmod(0750,Lambom::Config::CONFIG_DIR)

            file = File.new(CHEF_CONF_FILE,"w")

            if CHEF_CONF.has_key?(env)
                file.write(CHEF_CONF[env])
            else
                file.write(CHEF_CONF[:other])
            end


            file.close
        end
    end
end
