# google-cloud-spanner

[Google Cloud Spanner API](https://cloud.google.com/spanner/) ([docs](https://cloud.google.com/spanner/docs)) provides a fully managed, mission-critical, relational database service that offers transactional consistency at global scale, schemas, SQL (ANSI 2011 with extensions), and automatic, synchronous replication for high availability.

- [google-cloud-spanner API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-spanner/latest)
- [google-cloud-spanner on RubyGems](https://rubygems.org/gems/google-cloud-spanner)
- [Google Cloud Spanner API documentation](https://cloud.google.com/spanner/docs)

## Quick Start

```sh
$ gem install google-cloud-spanner
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-spanner/guides/authentication).

## Example

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

db.transaction do |tx|
  results = tx.execute "SELECT * FROM users"

  results.rows.each do |row|
    puts "User #{row[:id]} is #{row[:name]}"
  end
end
```

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

However, Ruby 2.3 or later is strongly recommended, as earlier releases have
reached or are nearing end-of-life. After June 1, 2018, Google will provide
official support only for Ruby versions that are considered current and
supported by Ruby Core (that is, Ruby versions that are either in normal
maintenance or in security maintenance).
See https://www.ruby-lang.org/en/downloads/branches/ for further details.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
