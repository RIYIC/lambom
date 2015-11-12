require 'yaml'

module Lambom

  class Config

    CONFIG_DIR = "/etc/riyic"
    FILE = "#{CONFIG_DIR}/lambom.conf"
    UNIX_PATH_REGEX = /^[\w\s.\/\-_+%]+$/i
    URL_REGEX = /^(http(s)?|ftp):\/\/(([A-Za-z0-9-]+\.)*([A-Za-z0-9-]+\.[A-Za-z0-9]+))+((\/?)(([A-Za-z0-9\._\-]+)(\/){0,1}[A-Za-z0-9.-\/]*)){0,1}/

    attr_accessor(
      :server, 
      :private_key_file, 
      :environment, 
      :loglevel, 
      :json_file, 
      :berksfile, 
      :cached, 
      :download_tarball,
      :api_url
    )
            
    attr_reader :logdir, :logfile

  
    def initialize
      @server = nil
      @private_key_file = nil
      @json_file = nil
      @berksfile = nil
      @cached = false
      @environment = 'production'
      @loglevel = 'debug'
      @logdir = '/var/log/riyic'
      @logfile = "solo_#{Time.now.strftime("%Y%m%d%H%M%S")}"
      @download_tarball = nil
      @api_url = nil
    end


    def load(argv={})

      h = {}

      # evitamos cascar si o ficheiro de configuracion non existe
      if File.exists?(FILE)

        begin
          h = YAML.load(IO::read(FILE))
        rescue Exception => e
          e.to_s =~ /line (\d+) column/
          raise "Error loading yaml config file #{FILE}, syntax error in line #{$1}"
        end

        puts "hash de opcions: #{h.inspect}" if $debug

        raise "Error in config file, YAML loaded is not a hash" unless h.class == Hash

        # convert keys from string to symbols
        h = h.each_with_object({}) {|(k,v),o| o[k.to_sym] = v}
      
      end

      # merge line command hash with config file loaded
      h.merge!(argv)
  
      # validate parametros
      h.each do |k,v|
        if validate(k,v)
          instance_variable_set "@#{k}".to_sym, v
        else
          raise "Invalid value '#{v}' to parameter '#{k}'"
        end
      end
      
      return self

    end

    def merge(options={})
      options.each do |k,v|
        puts "mergeando #{k} con valor #{v} en config" if $debug
        self.send("#{k}=",v) if validate(k,v)
      end
    end


    def validate(parametro,valor)

      case parametro.to_sym
      when :server
        # uuid
        valor =~ /^[\d\w\-]{36}$/
      when :private_key_file
        #unix path
        valor =~ UNIX_PATH_REGEX && File.exists?(valor)
      when :environment
        #env de rails
        ["production","development","test"].include?(valor)
      when :loglevel
        #loglevel de chef
        %w{debug info}.include?(valor)
      when :berksfile
        valor =~ UNIX_PATH_REGEX && File.exists?(valor)
      when :json_file
        valor =~ UNIX_PATH_REGEX && File.exists?(valor)
      when :cached
        [true,false].include?(valor)
      when :api_url
        valor =~ URL_REGEX
      when :download_tarball
        valor =~ URL_REGEX
      else
        false
        #raise "Invalid parameter #{parametro}"
      end

    end
  end
end
