rack_envfile "#{node[:rack][:root]}/shared/.env" do
  delete_variables(%w(memcache_servers memcache_password memcache_username))
  action :delete_variables
end

executables do
  action :export
end

service 'rack' do
  ignore_failure true
  provider Chef::Provider::Service::Upstart
  action :restart
end