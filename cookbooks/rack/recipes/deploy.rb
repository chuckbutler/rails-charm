extra_packages node[:juju][:extra_packages] do
  action :install
end

scm_provider node[:juju][:scm_provider] do
  deploy_key node[:juju][:deploy_key]
  owner 'deploy'
  group 'deploy'
  action :bootstrap
end

rack_envfile "#{node[:rack][:root]}/shared/.env" do
  variables({
    rack_env: node[:juju][:rack_env],
    rails_env: node[:juju][:rack_env],
    port: 8080
  })
  user 'deploy'
  group 'deploy'
  mode '0644'
  action :merge
end

deploy_revision node[:rack][:root] do
  repo node[:juju][:repo]
  action :deploy

  user 'deploy'
  group 'deploy'

  symlink_before_migrate({'config/database.yml' => 'config/database.yml',
                          '.env' => '.env'})

  case node[:juju][:scm_provider]
    when 'git'
      revision node[:juju][:revision]
      ssh_wrapper "/tmp/private_code/wrap-ssh.sh"
    when 'svn'
      revision node[:juju][:revision]
      scm_provider Chef::Provider::Subversion
      svn_username node[:juju][:svn_username]
      svn_password node[:juju][:svn_password]
    else
      raise ArgumentError
  end

  before_migrate do
    # workaround for symlink_before_migrate() http://tickets.opscode.com/browse/CHEF-4374
    directory "#{release_path}/config" do
      user 'deploy'
      group 'deploy'
      action :create
    end

    bundle release_path do
      user 'deploy'
      group 'deploy'
      action :install
    end
  end

  before_restart do
    rake_task 'assets:precompile' do
      cwd "#{node[:rack][:root]}/current"
      user 'deploy'
      group 'deploy'
      ignore_failure true
      action :run
    end
  end
end

rack_procfile 'reverse_merge entries in Procfile' do
  procfile "#{node[:rack][:root]}/current/Procfile"
  entries({web: 'bundle exec rackup config.ru -p $PORT'})
  user 'deploy'
  group 'deploy'
  mode '0644'
  action :reverse_merge
end

executables do
  action :export
end