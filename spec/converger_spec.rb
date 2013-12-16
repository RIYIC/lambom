require "lambom"
require "lambom/converger"

describe Lambom::Converger do
    conf = Lambom::Config.new

    conf.merge(environment: 'development',
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
    "recipe[riyic::default]",
  ]
}
EOF

    if "must run convergence tool"
        expect(Lambom::Converger.run(conf,json)).to eq(true)
    end
end


