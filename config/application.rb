require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

class Application < Rails::Application
  config.middleware.use Rack::Deflater

  config.generators do |g|
    g.test_framework :rspec, fixture: false
    g.view_specs false
    g.integration_specs false
    g.stylesheets = false
    g.javascripts = false
    g.helper = false
  end

  config.exceptions_app = self.routes

  config.serve_static_assets = true

  config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
  config.assets.precompile += %w( .svg .eot .woff .ttf )
end
