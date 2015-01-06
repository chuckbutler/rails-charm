default[:rack][:root] = '/var/www/rack'
default[:rack][:gems_dependencies] = {
  'pg' => %w(libpq++-dev),
  'mysql2' => %w(libmysql++-dev),
  'sqlite3' => %w(libsqlite3-dev),
  'rmagick' => %w(libmagick++-dev),
  'nokogiri' => %w(libxslt-dev libxml2-dev)
}