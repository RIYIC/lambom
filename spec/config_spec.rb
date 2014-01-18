require "lambom"
require "lambom/config"

describe Lambom::Config do
    Lambom.enable_debug

    describe "load config" do 
        Lambom::Config::FILE = 'spec/test_config.yml'
        config = Lambom::Config.new.load

        it "must load config file if exists" do
            expect(config).to be_an_instance_of(Lambom::Config)
        end
        it "must have test file values" do
            expect(config.server).to eq("1ca71cd6-08c4-4855-9381-2f41aeffe59c")
            expect(config.environment).to eq("development")
            expect(config.private_key_file).to eq("spec/private_key.pem")
            expect(config.loglevel).to eq("debug")
        end

        it "must have merged values" do
            merge_key_file = 'spec/test_private_key.pem'
            merge_server = "1ca71cd6-08c4-4855-9381-111111111111"
            merge_env = 'test'
            merge_loglevel = 'info'

            options = {
                private_key_file: merge_key_file,
                server: merge_server,
                environment: merge_env,
                loglevel: merge_loglevel
            }

            config.merge(options)
            expect(config.private_key_file).to eq(merge_key_file)
            expect(config.server).to eq(merge_server)
            expect(config.environment).to eq(merge_env)
            expect(config.loglevel).to eq(merge_loglevel)
        end
    end

    describe "loading bad yaml file" do
        it "must raise error if config file has bad yaml format" do
            expect {
                Lambom::Config::FILE = 'spec/test_config_bad_yaml.yml'
                Lambom::Config.new.load 
            }.to raise_error(/yaml/)
        end
    end
    
    describe "bad options in config file" do
        it "must raise error if config options not validate" do
            expect {
                Lambom::Config::FILE = 'spec/test_config_bad_options.yml'
                Lambom::Config.new.load 
            }.to raise_error(/Invalid value/)
        end
    end
end

