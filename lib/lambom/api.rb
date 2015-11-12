require 'time'
require "mixlib/authentication"
require "mixlib/authentication/signedheaderauth"
require 'digest/sha1'
require 'openssl'
require 'net/http'

module Lambom
  class ApiClient
    DEFAULT_API_URL =  "https://riyic.com/api/v1"

    def initialize(conf)
      @server_id = conf.server or raise "Required parameter \"server\" not found"
      @private_key_file = conf.private_key_file or raise "Required parameter \"private_key_file\" not found"
      @env = conf.environment

      @api_url = conf.api_url || DEFAULT_API_URL
    end

    def get_server_config
      get('servers',"#{@server_id}/generate_config");

    end

    def get_berksfile
      get("servers","#{@server_id}/berksfile")
    end



    def get(controller, action='',params={})
      uri = build_uri(controller,action)
      req = Net::HTTP::Get.new(uri.request_uri)
      req.body=generate_body_string(params)
      send(uri,req)

    end

    def post(controller, action='',params={})
      uri = build_uri(controller,action)
      req = Net::HTTP::Post.new(uri.request_uri)
      #req.set_form_data(params)
      req.body=generate_body_string(params)
      send(uri,req)
    end

    def send(uri,req)
      
      ## agregamos os headers da signature
      headers = generate_headers(@server_id, @private_key_file, req)
      puts headers.inspect if $debug
      
      headers.each do |header,value|
        req[header] = value
      end
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      response = http.request(req)
      puts response.body if $debug

      if response.is_a?(Net::HTTPSuccess)
        return response.body
      else
        puts "code:#{response.code}, message:#{response.message}" if $debug
        raise "api error: #{response.body}"
      end

      #puts resp.inspect if @debug
      #response = Oj.load(response.body)

      #if response["status"] == "OK" 
      #  return response
      #else
      #  raise response.body
      #end
        
    end


    private

    def build_uri(controller, action='')
      URI("#{@api_url}/#{controller}/#{action}")
    end

    def generate_body_string(h={})
      r = ""

      h.each do |k,v|
        r << "&#{k}=#{v}"
      end

      r
    end


    def generate_headers(server_id, private_key_file, request)
      
      args = {
        :body => request.body.to_s,
        :user_id => server_id.to_s,
        :http_method => request.method.to_s,
        :timestamp => Time.now.iso8601,
        :path => request.path.to_s,
        :proto_version => 1.1
      }
      
      # cargamos a private key do ficheiro
      key = IO::read(private_key_file)
      private_key = OpenSSL::PKey::RSA.new(key)
      
      Mixlib::Authentication::SignedHeaderAuth.signing_object(args).sign(private_key)
    end


  end
end
