# google-cloud-dns

[Google Cloud DNS](https://cloud.google.com/dns/) ([docs](https://cloud.google.com/dns/docs)) is a high-performance, resilient, global DNS service that provides a cost-effective way to make your applications and services available to your users. This programmable, authoritative DNS service can be used to easily publish and manage DNS records using the same infrastructure relied upon by Google. To learn more, read [What is Google Cloud DNS?](https://cloud.google.com/dns/what-is-cloud-dns).

- [google-cloud-dns API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-dns/latest)
- [google-cloud-dns on RubyGems](https://rubygems.org/gems/google-cloud-dns)
- [Google Cloud DNS documentation](https://cloud.google.com/dns/docs)

## Quick Start

```sh
$ gem install google-cloud-dns
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-dns/latest/file.AUTHENTICATION).

## Example

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new

# Retrieve a zone
zone = dns.zone "example-com"

# Update records in the zone
change = zone.update do |tx|
  tx.add     "www", "A",  86400, "1.2.3.4"
  tx.remove  "example.com.", "TXT"
  tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
                                           "20 mail2.example.com."]
  tx.modify "www.example.com.", "CNAME" do |r|
    r.ttl = 86400 # only change the TTL
  end
end
```

## Enabling Logging

To enable logging for this library, set the logger for the underlying [Google API Client](https://github.com/google/google-api-ruby-client/blob/master/README.md#logging) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-logging/latest/Google/Cloud/Logging/Logger) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/).

If you do not set the logger explicitly and your application is running in a Rails environment, it will default to `Rails.logger`. Otherwise, if you do not set the logger and you are not using Rails, logging is disabled by default.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

my_logger = Logger.new $stderr
my_logger.level = Logger::WARN

# Set the Google API Client logger
Google::Apis.logger = my_logger
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
Guide](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-dns/latest/file.CONTRIBUTING)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-dns/latest/file.CODE_OF_CONDUCT)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-dns/latest/file.LICENSE).

## Support

Please [report bugs at the project on
Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
