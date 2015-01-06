memcached = {
  host: juju_relation['host'],
  port: juju_relation['port'],
}

if %i(host port).any? { |attr| memcached[attr].nil? || memcached[attr].empty? }
  puts "Waiting for all attributes being set."
else
  rack_envfile "#{node[:rack][:root]}/shared/.env" do
    variables({
      memcache_servers: "#{memcached[:host]}:#{memcached[:port]}",
      memcache_password: nil,
      memcache_username: nil
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