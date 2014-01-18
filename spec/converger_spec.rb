require "lambom"
require "lambom/converger"

describe Lambom::Converger do
    conf = Lambom::Config.new

    conf.merge(:environment => "production",
              :server => "4586273f-f17a-4984-99ef-69c255e1b395",
              :private_key_file => "spec/private_key.pem",
              :loglevel => 'info',
              :json_file => 'spec/test_json_file',
              :api_url => 'http://172.17.42.1:3000/api/v1' )


    it "must run convergence tool" do
        expect{
            Lambom::Converger.new(conf).run
        }.not_to raise_error
    end
end


