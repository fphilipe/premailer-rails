source 'https://rubygems.org'

gemspec

action_mailer_version = ENV.fetch('ACTION_MAILER_VERSION', '4.0')

if action_mailer_version == 'head'
  git 'git://github.com/rails/rails.git' do
    gem 'actionmailer'
  end
else
  gem 'actionmailer', "~> #{action_mailer_version}"
end

platforms :rbx do
  gem 'rubysl'
  gem 'racc'
end
