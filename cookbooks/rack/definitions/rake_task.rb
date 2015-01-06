define :rake_task, action: :run, user: 'ubuntu', group: 'ubuntu', cwd: nil, ignore_failure: false do
  execute "rake #{params[:name]}" do
    action params[:action]
    command wrap_bundle(["cd #{params[:cwd]}", "rack_bundle exec rake #{params[:name]}"])
    cwd params[:cwd]
    group params[:group]
    ignore_failure params[:ignore_failure]
    only_if { run_with_wrap_bundle(["cd #{params[:cwd]}", "rack_bundle exec rake #{params[:name]} --dry-run"]) && $?.success? }
    user params[:user]
  end
end