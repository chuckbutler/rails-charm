define :scm_provider, action: :bootstrap do
  if params[:action] == :bootstrap
    case params[:name]
      when 'git'
        package 'git-core' do
          action :install
        end
      when 'svn'
        package 'subversion' do
          action :install
        end
      else
        raise ArgumentError
    end

    if params[:deploy_key]
      directory "/tmp/private_code/.ssh" do
        owner params[:owner]
        group params[:group]
        recursive true
      end

      cookbook_file "/tmp/private_code/wrap-ssh.sh" do
        source "wrap-ssh.sh"
        owner params[:owner]
        group params[:group]
        mode 00700
      end

      file '/tmp/private_code/.ssh/id_deploy' do
        content params[:deploy_key]
        owner params[:owner]
        group params[:group]
        mode 00400
      end
    end
  end
end