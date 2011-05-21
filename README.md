# Premailer Rails 3 README

This gem is a no config solution for the wonderful [Premailer gem](https://github.com/alexdunae/premailer) to be used with Rails 3.
It uses interceptors which were introduced in Rails 3 and tweaks all mails which
receive the `deliver` method and adds a plain text part to it and inlines all CSS rules into the HTML part.

Currently it ignores any stylesheets linked within the email in favour of applying the stylesheet found at `public/stylesheets/email.css` or, if you use SASS on Heroku with Hassle, at `tmp/hassle/stylesheets/email.css`.

## Installation

Simply add the gem to your Gemfile in your Rails project:

    gem 'premailer-rails3'
