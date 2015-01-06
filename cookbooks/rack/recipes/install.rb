include_recipe 'nginx::default'
include_recipe 'nodejs::default'

user 'deploy' do
  home '/home/deploy'
  shell '/bin/bash'
  supports manage_home: true
  action :create
end

%w{config log pids cached-copy bundle system db}.each do |dir|
  directory "#{node[:rack][:root]}/shared/#{dir}" do
    owner 'deploy'
    group 'deploy'
    mode '0755'
    recursive true
    action :create
  end
end

cookbook_file "#{node[:rack][:root]}/shared/config/database.yml" do
  source 'database.yml'
  cookbook 'rack'
  owner 'deploy'
  group 'deploy'
  action :create
end

include_recipe 'rack::deploy'

nginx_site 'rack' do
  action :enable
end

nginx_site 'default' do
  action :disable
end

service 'nginx' do
  action :start
end

juju_port 80 do
  action :open
end