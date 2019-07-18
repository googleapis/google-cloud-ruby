# google-cloud

The [google-cloud](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud)
gem is a convenience package that lazily loads the vast majority of the
[google-cloud-*](https://github.com/googleapis/google-cloud-ruby) gems.
Because there are now so many google-cloud-* gems, instead of using this gem in
your production application, we encourage you to directly require only the
individual google-cloud-* gems that you need.

- [google-cloud API documentation](https://googleapis.dev/ruby/google-cloud/latest)
- [google-cloud on RubyGems](https://rubygems.org/gems/google-cloud)

## List of dependencies

This gem depends on and lazily loads the following google-cloud-* gems:

- [google-cloud-asset](../google-cloud-asset/README.md
- [google-cloud-bigquery](../google-cloud-bigquery/README.md
- [google-cloud-bigquery-data_transfer](../google-cloud-bigquery-data_transfer/README.md
- [google-cloud-bigtable](../google-cloud-bigtable/README.md
- [google-cloud-container](../google-cloud-container/README.md
- [google-cloud-dataproc](../google-cloud-dataproc/README.md
- [google-cloud-datastore](../google-cloud-datastore/README.md
- [google-cloud-dialogflow](../google-cloud-dialogflow/README.md
- [google-cloud-dlp](../google-cloud-dlp/README.md
- [google-cloud-dns](../google-cloud-dns/README.md
- [google-cloud-error_reporting](../google-cloud-error_reporting/README.md
- [google-cloud-firestore](../google-cloud-firestore/README.md
- [google-cloud-kms](../google-cloud-kms/README.md
- [google-cloud-language](../google-cloud-language/README.md
- [google-cloud-logging](../google-cloud-logging/README.md
- [google-cloud-monitoring](../google-cloud-monitoring/README.md
- [google-cloud-os_login](../google-cloud-os_login/README.md
- [google-cloud-pubsub](../google-cloud-pubsub/README.md
- [google-cloud-redis](../google-cloud-redis/README.md
- [google-cloud-resource_manager](../google-cloud-resource_manager/README.md
- [google-cloud-scheduler](../google-cloud-scheduler/README.md
- [google-cloud-spanner](../google-cloud-spanner/README.md
- [google-cloud-speech](../google-cloud-speech/README.md
- [google-cloud-storage](../google-cloud-storage/README.md
- [google-cloud-tasks](../google-cloud-tasks/README.md
- [google-cloud-text_to_speech](../google-cloud-text_to_speech/README.md
- [google-cloud-trace](../google-cloud-trace/README.md
- [google-cloud-translate](../google-cloud-translate/README.md
- [google-cloud-video_intelligence](../google-cloud-video_intelligence/README.md
- [google-cloud-vision](../google-cloud-vision/README.md

## Quick Start

```sh
$ gem install google-cloud
```

## Authentication

Instructions and configuration options are covered in the [Authentication
Guide](./AUTHENTICATION.md).

## Example

As shown in the example below, the google-cloud gem lazily loads its
google-cloud-* dependencies only as needed.

```ruby
require "google-cloud"

gcloud = Google::Cloud.new

Google::Cloud::Bigquery #=> NameError: uninitialized constant Google::Cloud::Bigquery

bigquery = gcloud.bigquery

Google::Cloud::Bigquery #=> Google::Cloud::Bigquery
Google::Cloud::Logging #=> NameError: uninitialized constant Google::Cloud::Logging

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
Guide](./CONTRIBUTING.md)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](./CODE_OF_CONDUCT.md)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](./LICENSE.md).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
