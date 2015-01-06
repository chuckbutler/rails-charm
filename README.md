# Overview

This Rails charms provides a minimal, modular and adaptable interface for developing web applications in Ruby. This Charm will deploy Ruby on Rails, Sinatra or any other Rack application and connect it to supported services.

# Usage

To deploy this charm you will need at a minimum: a cloud environment, working Juju installation and a successful bootstrap. Once bootstrapped, deploy Rails charm and all required services.

## Ruby on Rails example

Create a YAML config file with your application's name and it's git location

**sample-app.yml**

    sample-app:
      repo: https://github.com/pavelpachkovskij/sample-rails

Deploy the application:

    juju deploy rails myapp --config sample-app.yml

Deploy and relate database

    juju deploy postgresql
    juju add-relation postgresql:db myapp

Now you can run migrations:

    juju ssh myapp/0 run rake db:migrate

Seed database

    juju ssh myapp/0 run rake db:seed

And finally expose the application:

    juju expose myapp

Find the instance's public URL from

    juju status myapp

### MySQL setup

    juju deploy mysql
    juju add-relation mysql myapp

## Sinatra example

Configure your application, for example html2haml

**html2haml.yml**

    html2haml:
      repo: https://github.com/twilson63/html2haml.git

Deploy your Rails service

    juju deploy rails html2haml --config html2haml.yml

Expose the service:

    juju expose html2haml

## Source code updates

    juju set <service_name> revision=<revision>

## Executing commands

    juju ssh <unit_name> run <command>

## Restart application

    juju ssh <unit_name> sudo restart rack

## Foreman integration

You can add Procfile to your application and Rack to start additional processes or replace default application server:

Example Procfile:

    web: bundle exec unicorn -p $PORT
    watcher: bundle exec rake watch

## Specifying a Ruby Version

You can use the ruby keyword of your app's Gemfile to specify a particular version of Ruby.

    source "https://rubygems.org"
    ruby "1.9.3"

# Horizontal scaling

Juju makes it easy to scale your Rails application. You can simply deploy any supported load balancer, add relation and launch any number of application instances.

## HAProxy

    juju deploy rails myapp --config rack.yml
    juju deploy haproxy
    juju add-relation haproxy myapp
    juju expose haproxy
    juju add-unit myapp -n 2

## Apache2

Apache2 is harder to start with, but it provides more flexibility with configuration options.
Here is a quick example of using Apache2 as a load balancer with your rack application:

Deploy Rack application

    juju deploy rails --config rack.yml

You have to enable mod_proxy_balancer and mod_proxy_http modules in your Apache2 config:

**apache2.yml** example

    apache2:
      enable_modules: proxy_balancer proxy_http

Deploy Apache2

    juju deploy apache2 --config apache2.yml

Create balancer relation between Apache2 and Rack application

    juju add-relation apache2:balancer rails

Apache2 charm expects a template to be passed in. Example of vhost that will balance all traffic over your application instances:

**vhost.tmpl**

    <VirtualHost *:80>
      ServerName rack
      ProxyPass / balancer://rack/ lbmethod=byrequests stickysession=BALANCEID
      ProxyPassReverse / balancer://rack/
    </VirtualHost>

Update Apache2 service config with this template

    juju set apache2 "vhost_http_template=$(base64 < vhost.tmpl)"

Expose Apache2 service

    juju expose apache2

# Logging with Logstash

You can add logstash service to collect information from application's logs and Kibana application to visualize this data.

    juju deploy kibana
    juju deploy logstash-indexer
    juju add-relation kibana logstash-indexer:rest

    juju deploy logstash-agent
    juju add-relation logstash-agent logstash-indexer
    juju add-relation logstash-agent rails
    juju set logstash-agent CustomLogFile="['/var/www/rack/current/log/*.log']" CustomLogType="rack"
    juju expose kibana

# Monitoring with Nagios and NRPE

You can can perform HTTP checks with Nagios. To do this deploy Nagios and relate it to your Rack application:

    juju deploy nagios
    juju add-relation rails nagios

Additionally you can perform disk, mem, and swap checks with NRPE extension:

    juju deploy nrpe
    juju add-relation rails nrpe
    juju add-relation nrpe nagios

# MongoDB relation

Deploy MonogDB service and relate it to Rack application:

    juju deploy mongodb
    juju add-relation mongodb rails

Rack charm will set environment variables which you can use to configure your Mongodb adapter.

    MONGODB_URL   => mongodb://host:port/database

## Mongoid 2.x

Your mongoid.yml should look like:

    production:
      uri: <%= ENV['MONGODB_URL'] %>

## Mongoid 3.x

Your mongoid.yml should look like:

    production:
      sessions:
        default:
          uri: <%= ENV['MONGODB_URL'] %>

In both cases you can set additional options specified by Mongoid.

# Memcached relation

Deploy Memcached service and relate it to Rack application:

    juju deploy memcached
    juju add-relation memcached rails

Rack charm will set environment variables which you can use to configure your Memcache adapter. [Dalli](https://github.com/mperham/dalli) use those variables by default.

    MEMCACHE_PASSWORD    => xxxxxxxxxxxx
    MEMCACHE_SERVERS     => instance.hostname.net
    MEMCACHE_USERNAME    => xxxxxxxxxxxx

# Redis relation

Deploy Redis service and relate it to Rack application:

    juju deploy redis-master
    juju add-relation redis-master:redis-master rails

Rack charm will set environment variables which you can use to configure your Redis adapter.

    REDIS_URL   => redis://username:password@my.host:6389

For example you can configure Redis adapter in config/initializers/redis.rb

    uri = URI.parse(ENV["REDIS_URL"])
    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

# Known issues

## Rack application didn't start because assets were not compiled

To be able to compile assets before you've joined database relation you have to disable initialize_on_precompile option in application.rb:

    config.assets.initialize_on_precompile = false

If you can't do this you still can join database and compile assets manually:

    juju ssh rails/0 run rake assets:precompile

Then restart Rack service (while you have to replace 'rack/0' with your application name, e.g. 'sample-rails/0', 'sudo restart rack' is a valid command to restart any deployed application):

    juju ssh rails/0 sudo restart rack

# Configuration

## Deploy from Git

Sample Git config:

    rack:
      repo: <repository_url>
      revision: <revision_number>

To deploy from private repo via SSH add 'deploy_key' option:

    deploy_key: <private_key>

## Deploy from SVN

Sample SVN config:

    rack:
      scm_provider: svn
      repo: <repository_url>
      revision: <revision_number>
      svn_username: <username>
      svn_password: <password>

## Install extra packages

Specify list of packages separated by spaces:

    extra_packages: 'libsqlite3++-dev libmagick++-dev'

## Set ENV variables

You can set ENV variables, which will be available within all processes defined in a Procfile:

    env: 'AWS_ACCESS_KEY_ID=aws_access_key_id AWS_SECRET_ACCESS_KEY=aws_secret_access_key'