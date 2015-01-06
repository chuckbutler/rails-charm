mysql = {
  host: juju_relation['host'],
  database: juju_relation['database'],
  username: juju_relation['user'],
  password: juju_relation['password'],
  port: juju_relation['port']
}

if %i(host database username password).any? { |attr| mysql[attr].nil? || mysql[attr].empty? }
  puts "Waiting for all attributes being set."
else
  rack_envfile "#{node[:rack][:root]}/shared/.env" do
    variables({
      database_url: "mysql2://#{mysql[:username]}:#{mysql[:password]}@#{mysql[:host]}:#{mysql[:port]}/#{mysql[:database]}",
    })
    user 'deploy'
    group 'deploy'
    mode '0644'
    action :merge
  end

  executables do
    action :export
  end

  service 'rack' do
    ignore_failure true
    provider Chef::Provider::Service::Upstart
    action :restart
  end
end