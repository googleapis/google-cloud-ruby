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

- [google-cloud-asset](https://googleapis.dev/ruby/google-cloud-asset/latest
- [google-cloud-bigquery](https://googleapis.dev/ruby/google-cloud-bigquery/latest
- [google-cloud-bigquery-data_transfer](https://googleapis.dev/ruby/google-cloud-bigquery-data_transfer/latest
- [google-cloud-bigtable](https://googleapis.dev/ruby/google-cloud-bigtable/latest
- [google-cloud-container](https://googleapis.dev/ruby/google-cloud-container/latest
- [google-cloud-dataproc](https://googleapis.dev/ruby/google-cloud-dataproc/latest
- [google-cloud-datastore](https://googleapis.dev/ruby/google-cloud-datastore/latest
- [google-cloud-dialogflow](https://googleapis.dev/ruby/google-cloud-dialogflow/latest
- [google-cloud-dlp](https://googleapis.dev/ruby/google-cloud-dlp/latest
- [google-cloud-dns](https://googleapis.dev/ruby/google-cloud-dns/latest
- [google-cloud-error_reporting](https://googleapis.dev/ruby/google-cloud-error_reporting/latest
- [google-cloud-firestore](https://googleapis.dev/ruby/google-cloud-firestore/latest
- [google-cloud-kms](https://googleapis.dev/ruby/google-cloud-kms/latest
- [google-cloud-language](https://googleapis.dev/ruby/google-cloud-language/latest
- [google-cloud-logging](https://googleapis.dev/ruby/google-cloud-logging/latest
- [google-cloud-monitoring](https://googleapis.dev/ruby/google-cloud-monitoring/latest
- [google-cloud-os_login](https://googleapis.dev/ruby/google-cloud-os_login/latest
- [google-cloud-pubsub](https://googleapis.dev/ruby/google-cloud-pubsub/latest
- [google-cloud-redis](https://googleapis.dev/ruby/google-cloud-redis/latest
- [google-cloud-resource_manager](https://googleapis.dev/ruby/google-cloud-resource_manager/latest
- [google-cloud-scheduler](https://googleapis.dev/ruby/google-cloud-scheduler/latest
- [google-cloud-spanner](https://googleapis.dev/ruby/google-cloud-spanner/latest
- [google-cloud-speech](https://googleapis.dev/ruby/google-cloud-speech/latest
- [google-cloud-storage](https://googleapis.dev/ruby/google-cloud-storage/latest
- [google-cloud-tasks](https://googleapis.dev/ruby/google-cloud-tasks/latest
- [google-cloud-text_to_speech](https://googleapis.dev/ruby/google-cloud-text_to_speech/latest
- [google-cloud-trace](https://googleapis.dev/ruby/google-cloud-trace/latest
- [google-cloud-translate](https://googleapis.dev/ruby/google-cloud-translate/latest
- [google-cloud-video_intelligence](https://googleapis.dev/ruby/google-cloud-video_intelligence/latest
- [google-cloud-vision](https://googleapis.dev/ruby/google-cloud-vision/latest

## Quick Start

```sh
$ gem install google-cloud
```

## Authentication

Instructions and configuration options are covered in the [Authentication
Guide](https://googleapis.dev/ruby/google-cloud/latest/file.AUTHENTICATION.html).

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

This library is supported on Ruby 2.4+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or in
security maintenance, and not end of life. Currently, this means Ruby 2.4 and
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
Guide](https://googleapis.dev/ruby/google-cloud/latest/file.CONTRIBUTING.html)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.dev/ruby/google-cloud/latest/file.CODE_OF_CONDUCT.html)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googleapis.dev/ruby/google-cloud/latest/file.LICENSE.html).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
