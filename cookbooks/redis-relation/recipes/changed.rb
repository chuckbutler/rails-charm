redis = {
  host: juju_relation['hostname'],
  port: juju_relation['port'],
}

if %i(host port).any? { |attr| redis[attr].nil? || redis[attr].empty? }
  puts "Waiting for all attributes being set."
else
  rack_envfile "#{node[:rack][:root]}/shared/.env" do
    variables({
      redis_url: "redis://#{redis[:host]}:#{redis[:port]}",
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