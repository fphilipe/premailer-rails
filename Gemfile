source 'https://rubygems.org'

gemspec

rails_version = ENV.fetch('ACTION_MAILER_VERSION', '6')

if rails_version == 'head'
  git 'git://github.com/rails/rails.git' do
    gem 'rails'
  end
  gem 'sprockets-rails', github: 'rails/sprockets-rails'
  gem 'arel', github: 'rails/arel'
else
  gem 'rails', "~> #{rails_version}"
end

gem 'byebug'
