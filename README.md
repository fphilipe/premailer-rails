# Premailer Rails 3 README

This gem is a no config solution for the wonderful
[Premailer gem](https://github.com/alexdunae/premailer) to be used with Rails 3.
It uses interceptors which were introduced in Rails 3 and tweaks all mails which
are `deliver`ed and adds a plain text part to them and inlines all CSS rules
into the HTML part.

By default it inlines all the CSS files that are linked to in the HTML:

```html
<link type='text/css' ... />
```

Don't worry about the host in the CSS URL since this will be ignored.

If no CSS file is linked to in the HTML and no inline `<style type="text/css">`
is presnet, it will try to load a default CSS file `email.css`.

Every CSS file (including the default `email.css`) is loaded from within the
app. The retrieval of the file depends on your assets configuration:

* Rails 3.1 asset pipeline: It will load the compiled version of the CSS asset
  which is normally located in `app/assets/stylesheets/`.

* Classic static assets: It will try to load the CSS file located in
  `public/stylesheets/`

* [Hassle](https://github.com/pedro/hassle): It will try to load the
  compiled CSS file located in the default Hassle location
  `tmp/hassle/stylesheets/`

## Installation

Simply add the gem to your Gemfile in your Rails project:

    gem 'premailer-rails3'

premailer-rails3 requires either nokogiri or hpricot. It doesn't list them as a
dependency so you can choose which one to use.

    gem 'nokogiri'
    # or
    gem 'hpricot'

If both are loaded for some reason, premailer chooses hpricot.

That's it!

## Configuration

Premailer itself accepts a number of options. In order for premailer-rails3 to
pass these options on to the underlying premailer instance, specify them in an
initializer:

```ruby
PremailerRails.config.merge!(:preserve_styles => true,
                             :remove_ids      => true)
```

For a list of options, refer to the [Premailer documentation](http://rubydoc.info/gems/premailer/1.7.3/Premailer:initialize)

The default configs are:

```ruby
{
  :input_encoding     => 'UTF-8',
  :inputencoding      => 'UTF-8',
  :generate_text_part => true
}
```

The input encoding option [changed](https://github.com/alexdunae/premailer/commit/5f5cbb4ac181299a7e73d3eca11f3cf546585364)
at some point. To make sure this option works regardless of the premailer
version, the old and new setting is specified. If you want to use another
encoding make sure to specify the right one or both.

If you don't want to generate a text part from the html part, set the config
`:generate_text_part` to false.

Note that the options `:with_html_string` and `:css_string` are used to make
this gem work and will thus be overridden.
