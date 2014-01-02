source 'https://rubygems.org'

# Core
gem 'rails', '4.0.2'
gem 'pg'

# Backend
gem 'figaro', '~> 0.7'
gem 'dotenv-rails', '~> 0.9'
gem 'yajl-ruby', :require => 'yajl'

# Frontend
# For assets precompilation on non-macs install node.js.
# therubyracer is discouraged because of high memory usage.
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '~> 2.3'
gem 'coffee-rails', '~> 4.0.0'
gem 'slim-rails', '~> 2.0'
gem 'jquery-rails', '~> 3.0'
gem 'quiet_assets', '~> 1.0'

gem 'ohm'
gem 'ohm-contrib'

# Wordnet Import
gem 'sequel'
gem 'mysql2'
gem 'ruby-progressbar'
gem 'thread', :require => 'thread/pool'
gem 'upsert'

# Neo4J export
gem 'neography'
gem 'neo4j-cypher'

group :development do
  gem 'awesome_print'
  gem 'better_errors', :platform => :ruby
  gem 'binding_of_caller', :platform => :ruby

  gem 'pry', '0.9.12.2'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'rspec-rails', '~> 2.14'
end
