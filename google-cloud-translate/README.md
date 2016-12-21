# google-cloud-translate

[Google Cloud Translation API](https://cloud.google.com/translate/) ([docs](https://cloud.google.com/translate/docs)) provides a simple, programmatic interface for translating an arbitrary string into any supported language. It is highly responsive, so websites and applications can integrate with Translation API for fast, dynamic translation of source text. Language detection is also available in cases where the source language is unknown.

Translation API supports more than one hundred different languages, from Afrikaans to Zulu. Used in combination, this enables translation between thousands of language pairs. Also, you can send in HTML and receive HTML with translated text back. You don't need to extract your source text or reassemble the translated content.

- [google-cloud-translate API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-translate/master/google/cloud/translate)
- [google-cloud-translate on RubyGems](https://rubygems.org/gems/google-cloud-translate)
- [Google Cloud Translation API documentation](https://cloud.google.com/translate/docs)

## Quick Start

```sh
$ gem install google-cloud-translate
```

## Authentication

Like other Cloud Platform services, Google Cloud Translation API supports
authentication using a project ID and OAuth 2.0 credentials. In addition,
it supports authentication using a public API access key. (If both the API
key and the project and OAuth 2.0 credentials are provided, the API key
will be used.) Instructions and configuration options are covered in the
[Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-translate/guides/authentication).

## Example

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new

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

See the [Contributing Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
