source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

rails_version = ENV.fetch('ACTION_MAILER_VERSION', '6')

if rails_version == "main"
  gem 'rails', github: "rails/rails", branch: :main
else
  gem 'rails', "~> #{rails_version}"
end

gem 'byebug'
