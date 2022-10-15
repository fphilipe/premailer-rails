source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

rails_version = ENV.fetch('ACTION_MAILER_VERSION', '7')

if rails_version == 'head'
  gem 'rails', github: 'rails/rails'
  gem 'sprockets-rails', github: 'rails/sprockets-rails'
else
  gem 'rails', "~> #{rails_version}"
  gem 'sprockets-rails' if rails_version >= '7'
end

gem 'byebug'
