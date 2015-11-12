#require "berkshelf/cli"
require 'chef/application/solo'
module Lambom
  class Converger
    include ShellMixin
    
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
cookbook_path ["/mnt/cookbooks/supermarket", "/mnt/others/cookbooks", "/mnt/riyic/cookbooks"]
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

    def initialize(conf)
      @conf = conf
      @name = conf.server || String.random(8)
      @json_file = conf.json_file
      @berksfile = conf.berksfile
    end


    attr_reader :conf,:attributes_json

    def run
      preparar_entorno

      descargar_atributos unless conf.json_file

      descargar_cookbooks unless conf.cached || conf.environment == 'development'

      ejecutar_converger
    end


    private

    def descargar_atributos
      
      # descargar atributos do servidor 
      json_attributes = Lambom::ApiClient.new(conf).get_server_config

      @json_file = "#{CACHE_PATH}/#{@name}.json"

      file = File.new(@json_file,"w")
      file.write(json_attributes)
      file.close

    end

    def descargar_cookbooks
      
      if conf.download_tarball
      
        # download cookbooks from a tarball
        temp = "/tmp/cookbooks.tar.gz"
        run_cmd('curl','-o',temp, '-L',conf.download_tarball)
        FileUtils.mkdir_p(DEFAULT_CHEF_PATH) unless File.directory?(DEFAULT_CHEF_PATH)
        run_cmd('tar','xzf',temp,'--no-same-owner','-C', DEFAULT_CHEF_PATH)
        File.unlink(temp)
        
      end
      
      # else
      #   # use berkshelf to download cookbooks
      #   # Download berksfile from riyic unless it was passed by command line
      #   descargar_berksfile unless @berksfile
      #   berks_install
      # end
    end

    # def descargar_berksfile
    #   @berksfile = "#{CACHE_PATH}/#{@name}.berksfile"
    #   berksfile_str = Lambom::ApiClient.new(conf).get_berksfile

    #   file = File.new(@berksfile,"w")
    #   file.write(berksfile_str)
    #   file.close
    # end


    # def berks_install
    #   cmd = %W{
    #     berks install -b #{@berksfile} -p #{DEFAULT_CHEF_PATH}/cookbooks
    #   }

    #   run_cmd *cmd     

    # end


    def ejecutar_converger

      #cmd = %W{
      #   chef-solo
      #   -c #{CHEF_CONF_FILE}
      #   --log_level #{conf.loglevel}
      #   -j #{@json_file}
      #}
      #
      #unless $debug
      #  cmd += [
      #    "--logfile", 
      #    "#{conf.logdir}/#{conf.logfile}"
      #  ]
      #end
      #run_cmd *cmd
      
      cmd = %W{
         -c #{CHEF_CONF_FILE}
         --log_level #{conf.loglevel}
         -j #{@json_file}
      }
      
      unless $debug
        cmd += [
          "--logfile", 
          "#{conf.logdir}/#{conf.logfile}"
        ]
      end

      # reseteamos argv
      ARGV.clear
      cmd.each do |arg|
        ARGV << arg
      end

      Chef::Application::Solo.new.run
    end


    def preparar_entorno
      # dont drop ruby vars from env
      #ENV_VARS_DELETE.each {|v| ENV.delete(v)}
      #ENV["PATH"] = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      
      #creamos directorio de logs
      FileUtils.mkdir_p(conf.logdir) unless File.directory?(conf.logdir)
      File.chmod(0750, conf.logdir)

      #creamos o directorio cache de chef
      FileUtils.mkdir_p(CACHE_PATH) unless File.directory?(CACHE_PATH)
      File.chmod(0750,CACHE_PATH)

      # establecemos o archivo de configuracion de chef segun o entorno
      switch_chef_conf(conf.environment.to_sym)
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
