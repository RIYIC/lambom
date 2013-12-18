require "lambom"
require "lambom/converger"

describe Lambom::Converger do
    conf = Lambom::Config.new

    conf.merge(:environment => "production",
              :server => "4586273f-f17a-4984-99ef-69c255e1b395",
              :private_key_file => "spec/private_key.pem",
              :loglevel => 'info' )
    json = <<EOF
{
  "riyic": {
    "dockerized": "no",
    "updates_check_interval": "never",
    "env": "development"
  },
  "run_list": [
    "recipe[riyic::default]"
  ]
}
EOF

    it "must run convergence tool" do
        expect{
            Lambom::Converger.new(conf, json).run
        }.not_to raise_error
    end
end


