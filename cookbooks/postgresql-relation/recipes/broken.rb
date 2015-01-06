rack_envfile "#{node[:rack][:root]}/shared/.env" do
  delete_variables(%w(database_url))
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