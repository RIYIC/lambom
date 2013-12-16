require "lambom"
require "lambom/converger"

describe Lambom::Converger do
    conf = Lambom::Config.new

    conf.merge(environment: 'test',
              server: '61a75d44-9856-4e64-a269-f95a232c9bcd',
              private_key_file: "spec/private_key.pem")
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


