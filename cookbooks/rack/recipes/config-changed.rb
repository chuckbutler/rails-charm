if (node.default[:juju][:revision] != node.override[:juju][:revision]) ||
    (node.default[:juju][:env] != node.override[:juju][:env])

  service 'rack' do
    ignore_failure true
    provider Chef::Provider::Service::Upstart
    action :stop
  end

  include_recipe 'rack::deploy'

  service 'rack' do
    ignore_failure true
    provider Chef::Provider::Service::Upstart
    action :start
  end
end