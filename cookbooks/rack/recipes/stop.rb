service 'rack' do
  ignore_failure true
  provider Chef::Provider::Service::Upstart
  action :stop
end