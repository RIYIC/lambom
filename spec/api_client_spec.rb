require "lambom"
require "lambom/api"

describe Lambom::ApiClient do
    conf = Lambom::Config.new.load
    
    conf.merge(environment: 'development',
              server: '61a75d44-9856-4e64-a269-f95a232c9bcd',
              private_key_file: "spec/private_key.pem")

    api = Lambom::ApiClient.new(conf)

    it "must be an ApiClient object" do
        expect(api).to be_an_instance_of(Lambom::ApiClient)
    end

    describe "getAttributes" do
        it "must connect to riyic api" do
            expect(api.get_server_config).to match(/^\{.+\}$/)
        end
        it "must fail to connect to api" do
            conf.merge(server: "61a75d44-9856-4e64-a269-111111111111")
            api2 = Lambom::ApiClient.new(conf)
            expect{api2.get_server_config}.to raise_error(/api error/)
        end
    end
end
