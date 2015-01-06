define :nginx_site, :action => :enable do
  site_available_path = "/etc/nginx/sites-available/#{params[:name]}"
  site_enabled_path = "/etc/nginx/sites-enabled/#{params[:name]}"

  if params[:action] == :enable
    link site_enabled_path do
      to site_available_path
      not_if { File.exists?(site_enabled_path) }
      only_if { File.exists?(site_available_path) }
      action :create
    end
  elsif params[:action] == :disable
    file site_enabled_path do
      only_if { File.exists?(site_enabled_path) }
      action :delete
    end
  end
end