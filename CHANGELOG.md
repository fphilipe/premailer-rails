# Changelog

## v1.5.1

- Prefer precompiled assets over asset pipeline

- Improve construction of file URL when requesting from CDN

- No longer use open-uri

- Remove gzip unzipping after requesting file

## v1.5.0

- No longer support ruby 1.8

- Find linked stylesheets by `rel='stylesheet'` attribute instead of
  `type='text/css'`

- Don't test hpricot on JRuby due to incompatibility

## v1.4.0

- Fix attachments

## v1.3.2

- Rename gem to premailer-rails (drop the 3)

- Add support for rails 4

- Refactor code

- Add support for precompiled assets

- No longer include default `email.css`

## v1.1.0

- Fixed several bugs

- Strip asset digest from CSS path

- Improve nokogiri support

- Request CSS file if asset is not found locally

  This allows you to host all your assets on a CDN and deploy the
  app without the `app/assets` folder.

Thanks to everyone who contributed!
