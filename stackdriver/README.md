# stackdriver

This gem instruments a Ruby web application for Stackdriver diagnostics. When loaded, it integrates with Rails, Sinatra, or other Rack-based web frameworks to collect application diagnostic and monitoring information for your application.

Specifically, this gem is a convenience package that loads and automatically activates the instrumentation features of the following gems:
- [google-cloud-logging](../google-cloud-logging)
- [google-cloud-error_reporting](../google-cloud-error_reporting)
- [google-cloud-monitoring](../google-cloud-monitoring)

Please see the top-level project [README](../README.md) for more information about the individual Stackdriver google-cloud-ruby gems.

## Quick Start

```sh
$ gem install stackdriver
```

## Overview
Instead of requiring multiple Stackdriver client library gems and explicitly load each built-in Railtie classes, now users can achieve all these through requiring this single **stackdriver** umbrella gem.
```ruby
require "stackdriver"
```

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](https://googlecloudplatform.github.io/stackdriver-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](../LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
