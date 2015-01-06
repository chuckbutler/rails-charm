require 'etc'

def whyrun_supported?
  true
end

action :reverse_merge do
  converge_by("Update #{ @new_resource }") do
    procfile = Foreman::Procfile.new(::File.exists?(@new_resource.procfile) ? @new_resource.procfile : nil)
    @new_resource.entries.each do |key, command|
      key = key.to_s
      procfile[key] = command unless key_exists?(procfile, key)
    end
    file @new_resource.procfile do
      content procfile.to_s
      user new_resource.user
      group new_resource.group
      mode new_resource.mode
      action :create
    end
  end
end

action :export do
  converge_by("Export #{ @new_resource }") do
    execute "foreman export --procfile #{ @new_resource.procfile || 'Procfile' } upstart /etc/init \
    --user #{ @new_resource.user || 'deploy' } --app #{ @new_resource.app || 'rack'} \
    --log #{node[:rack][:root]}/shared/log" do
      cwd new_resource.cwd
      action :run
    end
  end
end

private

def key_exists?(procfile, key)
  procfile.entries { |k, v| return true if k == key } && false
end