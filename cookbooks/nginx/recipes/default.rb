package 'nginx' do
  action :install
end

template '/etc/nginx/sites-available/rack' do
  source 'site.conf.erb'
  owner 'root'
  group 'root'
end