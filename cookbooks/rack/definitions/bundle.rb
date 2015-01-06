define :bundle, action: :install do
  %w(.rvmrc ruby-version .ruby-version .rbenv-version).each do |rvm_file|
    file "#{params[:name]}/#{rvm_file}" do
      action :delete
    end
  end

  node[:rack][:gems_dependencies].each do |bundled_gem, packages|
    if %x(grep -q #{bundled_gem} #{params[:name]}/Gemfile.lock) && $?.success?
      packages.each do |pckg|
        package pckg do
          action :install
        end
      end
    end
  end

  ruby_version_string = run_with_wrap_bundle(["cd #{params[:name]}", "bundle platform --ruby"]).chomp

  if ruby_version_string == "No ruby version specified"
    ruby_version_string = run('rvm current')
  else
    ruby_version_string = ruby_version_string.sub('(', '').sub(')', '').split.join('-')

    execute "rvm install #{ruby_version_string}" do
      action :run
    end
  end

  execute "rvm wrapper #{ruby_version_string} rack bundle" do
    action :run
  end

  file "#{params[:name]}/.ruby-version" do
    action :create
    content ruby_version_string
    group params[:group]
    user params[:user]
  end

  bundle_without = (%w(development production test).reject{ |env| env == node[:juju][:rack_env] }).join(' ')

  execute 'bundle install' do
    action :run
    command wrap_bundle("rack_bundle install --without #{bundle_without} --path #{node[:rack][:root]}/shared/bundle")
    cwd params[:name]
    group params[:group]
    user params[:user]
  end
end