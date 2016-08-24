# google-cloud-translate

[Google Translate](https://cloud.google.com/translate/) ([docs](https://cloud.google.com/translate/docs)) provides a simple, programmatic interface for translating an arbitrary string into any supported language. It is highly responsive, so websites and applications can integrate with Translate API for fast, dynamic translation of source text. Language detection is also available in cases where the source language is unknown.

Translate API supports more than ninety different languages, from Afrikaans to Zulu. Used in combination, this enables translation between thousands of language pairs. Also, you can send in HTML and receive HTML with translated text back. You don't need to extract your source text or reassemble the translated content.

- [google-cloud-translate API documentation](http://googlecloudplatform.github.io/gcloud-ruby/#/docs/google-cloud-translate/google/cloud/translate)
- [google-cloud-translate on RubyGems](https://rubygems.org/gems/google-cloud-translate)
- [Google Translate documentation](https://cloud.google.com/translate/docs)

## Quick Start

```sh
$ gem install google-cloud-translate
```

## Authentication

Unlike other Cloud Platform services, which authenticate using a project
ID and OAuth 2.0 credentials, Translate API requires a public API access
key. (This may change in future releases of Translate API.) Follow the
general instructions at [Identifying your application to
Google](https://cloud.google.com/translate/v2/using_rest#auth), and the
specific instructions for [Server
keys](https://cloud.google.com/translate/v2/using_rest#creating-server-api-keys).

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/google-cloud-translate/guides/authentication).

## Example

```ruby
require "google/cloud"

gcloud = Google::Cloud.new
translate = gcloud.translate

translation = translate.translate "Hello world!", to: "la"

puts translation #=> Salve mundi!

translation.from #=> "en"
translation.origin #=> "Hello world!"
translation.to #=> "la"
translation.text #=> "Salve mundi!"
```

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](../LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/gcloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/gcloud-ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).