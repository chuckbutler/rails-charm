define :executables, action: :export do
  if params[:action] == :export
    rack_procfile 'rack Procfile' do
      cwd "#{node[:rack][:root]}/current"
      user 'deploy'
      app 'rack'
      action :export
    end

    template "/usr/bin/run" do
      cookbook 'rack'
      source 'bin/run.erb'
      owner 'root'
      group 'root'
      mode '0755'
      helpers(RubyHelpers)
      action :create
    end

    template "/usr/bin/service_restart" do
      cookbook 'rack'
      source 'bin/restart.erb'
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end
end