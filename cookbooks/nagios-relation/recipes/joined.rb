private_address = unit_get('private-address')

relation_set do
  variables(
    "monitors" => {
      "version" => "0.3",
      'monitors' => {
        'local' => {},
        'remote' => {
          'http' => {
            'http' => {
              'port' => 80,
              'host' => private_address
            }
          }
        }
      }
    }.to_yaml,
    "target-id" => ENV["JUJU_UNIT_NAME"].gsub('/', '-'),
    "target-address" => private_address
  )
end