def whyrun_supported?
  true
end

action :merge do
  converge_by("Update #{ @new_resource }") do
    env = dotenv_args

    @new_resource.variables.each do |key, value|
      env[key.to_s.upcase] = shell_quote(value)
    end

    user_env.each do |key, value|
      env[key.to_s.upcase] = shell_quote(value)
    end

    file @new_resource.name do
      content hash_to_shell_args(env).join("\n")
      user new_resource.user
      group new_resource.group
      mode new_resource.mode
      action :create
    end
  end
end

action :delete_variables do
  converge_by("Update #{ @new_resource }") do
    env = dotenv_args

    unless env.blank?
      @new_resource.delete_variables.each do |key|
        env.delete(key.to_s.upcase)
      end

      user_env.each do |key, value|
        env[key.to_s.upcase] = shell_quote(value)
      end

      file @new_resource.name do
        content hash_to_shell_args(env).join("\n")
        user new_resource.user
        group new_resource.group
        mode new_resource.mode
        action :create
      end
    end
  end
end

private

PAIR = /
      \A
      ([\w\.]+)         # key
      (?:\s*=\s*|:\s+?) # separator
      (                 # value begin
        '(?:\'|[^'])*'  #   single quoted value
        |               #   or
        "(?:\"|[^"])*"  #   double quoted value
        |               #   or
        [^#\n]+         #   unquoted value
      )                 # value end
      \z
    /x

def user_env
  if node[:juju][:env].present?
    node[:juju][:env].split(' ').reduce({}) do |result, pair|
      if match = pair.match(PAIR)
        key, value = match.captures
        value = value.strip.sub(/\A(['"])(.*)\1\z/, '\2')
        value = value.gsub('\n', "\n").gsub(/\\(.)/, '\1') if $1 == '"'
        result[key] = value
        result
      else
        raise FormatError, "Pair #{pair.inspect} doesn't match format"
      end
    end
  else
    {}
  end
end