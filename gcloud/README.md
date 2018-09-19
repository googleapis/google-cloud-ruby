# gcloud

#### The `gcloud` gem and `Gcloud` namespace are now deprecated.

The current `gcloud` gem exists only to facilitate the timely transition of
legacy code from the deprecated `Gcloud` namespace to the new `Google::Cloud`
namespace. Please see the [GitHub
repository](https://github.com/GoogleCloudPlatform/google-cloud-ruby) for more
information about using the `google-cloud` umbrella gem and the individual
service gems.

- [gcloud API documentation](http://googleapis.github.io/google-cloud-ruby/docs/gcloud/latest)
- [gcloud on RubyGems](https://rubygems.org/gems/gcloud)

## Quick Start

```sh
$ gem install gcloud
```

## Authentication

Instructions and configuration options are covered in the [Authentication
Guide](https://googleapis.github.io/google-cloud-ruby/docs/gcloud/latest/file.AUTHENTICATION).

## Example

```ruby
require "gcloud"

gcloud = Gcloud.new
bigquery = gcloud.bigquery
dataset = bigquery.dataset "my-dataset"
table = dataset.table "my-table"
table.data.each do |row|
  puts row
end
```

## Supported Ruby Versions

This library is supported on Ruby 2.3+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or in
security maintenance, and not end of life. Currently, this means Ruby 2.3 and
later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may
change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing
Guide](https://googleapis.github.io/google-cloud-ruby/docs/gcloud/latest/file.CONTRIBUTING)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.github.io/google-cloud-ruby/docs/gcloud/latest/file.CODE_OF_CONDUCT)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googleapis.github.io/google-cloud-ruby/docs/gcloud/latest/file.LICENSE).

## Support

Please [report bugs at the project on
Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
