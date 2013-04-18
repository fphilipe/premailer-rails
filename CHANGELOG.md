# Changelog

## v1.4.0

- Fix attachments

## v1.3.2

- Rename gem to premailer-rails (drop the 3)

- Add support for rails 4

- Refactor code

- Add support for precompiled assets

- Remove autoloading of default stylesheet (email.css)

## v1.1.0

- Fixed several bugs

- Strip asset digest from CSS path

- Improve nokogiri support

- Request CSS file if asset is not found locally

  This allows you to host all your assets on a CDN and deploy the
  app without the `app/assets` folder.

Thanks to everyone who contributed!
