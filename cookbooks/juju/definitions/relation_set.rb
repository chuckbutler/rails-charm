define :relation_set do
  args_string = params[:variables].map { |key, value| "#{key}=\"#{value}\"" }.join(' ')

  execute "relation-set #{args_string}" do
    action :run
  end
end