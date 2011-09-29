# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "premailer-rails3/version"

Gem::Specification.new do |s|
  s.name        = "premailer-rails3"
  s.version     = PremailerRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Philipe Fatio"]
  s.email       = ["philipe.fatio@gmail.com"]
  s.homepage    = "https://github.com/fphilipe/premailer-rails3"
  s.summary     = %q{Easily create HTML emails in Rails 3.}
  s.description = %q{This gem brings you the power of the premailer gem to Rails 3
                     without any configuration needs. Create HTML emails, include a
                     CSS file as you do in a normal HTML document and premailer will
                     inline the included CSS.}

  s.rubyforge_project = "premailer-rails3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("premailer", ["~> 1.7"])
  s.add_dependency("rails", ["~> 3"])

  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'mail'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'hpricot'
end
