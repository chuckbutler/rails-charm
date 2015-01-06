require 'securerandom'

mongodb = {
  host: juju_relation['hostname'],
  port: juju_relation['port'],
  database: "rack_#{node[:juju][:rack_env]}"
}

if %i(host port).any? { |attr| mongodb[attr].nil? || mongodb[attr].empty? }
  puts "Waiting for all attributes being set."
else
  rack_envfile "#{node[:rack][:root]}/shared/.env" do
    variables({
      mongodb_url: "mongodb://#{mongodb[:host]}:#{mongodb[:port]}/#{mongodb[:database]}",
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