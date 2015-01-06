$: << File.expand_path('..', __FILE__)
require 'yaml'
require 'securerandom'
require 'active_support/all'
require 'juju/juju_helpers'
require 'juju/ruby_helpers'

class Chef
  class Resource
    include JujuHelpers
    include RubyHelpers
    if ENV['JUJU_ENV'] == 'development'
      include JujuHelpersDev
    end
  end

  class Recipe
    include RubyHelpers
    include JujuHelpers
    if ENV['JUJU_ENV'] == 'development'
      include JujuHelpersDev
    end
  end

  class Provider
    include RubyHelpers
    include JujuHelpers
    if ENV['JUJU_ENV'] == 'development'
      include JujuHelpersDev
    end
  end
end