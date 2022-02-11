source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

rails_version = ENV.fetch('ACTION_MAILER_VERSION', '7')

if rails_version == 'head'
  gem 'rails', github: 'rails/rails'
  if ENV['PROPSHAFT'] == 'true'
    gem 'propshaft', github: 'rails/propshaft'
  else
    gem 'sprockets-rails', github: 'rails/sprockets-rails'
  end
else
  gem 'rails', "~> #{rails_version}"
  if ENV['PROPSHAFT'] == 'true'
    gem 'propshaft'
  else
    gem 'sprockets-rails' if rails_version >= '7'
  end
end

gem 'byebug'
