require 'shellwords'
require 'dotenv'
require 'foreman/procfile'

module RubyHelpers
  def run(command)
    value = %x{ #{command} 2>&1 }.strip
    value.empty? ? nil : value
  end

  def run_with_wrap_bundle(commands)
    run(wrap_bundle(commands))
  end

  def wrap_bundle(commands)
    [
      'unset BUNDLE_GEMFILE RUBYOPT GEM_HOME',
      hash_to_shell_args(dotenv_args).map{ |args| "export #{args}" },
      commands
    ].flatten.join(';')
  end

  def shell_quote(value)
    Shellwords.escape(value)
  end

  def hash_to_shell_args(hash)
    hash.map { |key, value| "#{key}=#{value}" }
  end

  def dotenv_args
    ::File.exists?(dotenv_path) ? Dotenv::Environment.new(dotenv_path) : {}
  end
private
  def dotenv_path
    "#{node[:rack][:root]}/shared/.env"
  end
end