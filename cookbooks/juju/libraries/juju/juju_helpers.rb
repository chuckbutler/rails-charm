module JujuHelpers
  def juju_config
    @juju_config ||= JSON.load(config_get('--format=json')).symbolize_keys.tap do |config|
      File.open(juju_config_cache_path, "w+") do |file|
        file.write(config.to_yaml)
      end
    end
  end

  def juju_relation
    @juju_relation ||= JSON.load(relation_get('--format=json'))
  end

  def unit_get(key)
    run("unit-get #{shell_quote(key)}")
  end

  def juju_config_cache
    File.exists?(juju_config_cache_path) ? YAML.load(File.read(juju_config_cache_path)) : {}
  end

private
  def config_get(key)
    run("config-get #{shell_quote(key)}")
  end

  def relation_get(key)
    run("relation-get #{shell_quote(key)}")
  end

  def juju_config_cache_path
    "/root/.juju_config_cache.yml"
  end
end

module JujuHelpersDev
  def juju_config
    {
      repo: 'https://github.com/pavelpachkovskij/octopress',
      scm_provider: 'git',
      revision: 'public',
      rack_env: 'development',
    }
  end
end