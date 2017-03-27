# google-cloud-debugger

[Stackdriver Debugger](https://cloud.google.com/debugger/) ([docs](https://cloud.google.com/debugger/docs/)) lets you inspect the state of a running application at any code location in real time, without stopping or slowing down the application, and without modifying the code to add logging statements. You can use Stackdriver Debugger with any deployment of your application, including test, development, and production. The Ruby debugger adds minimal request latency, typically less than 50ms, and only when the application state is captured. In most cases, this is not noticeable by users.

- [google-cloud-debugger documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-debugger/master/google/cloud/debugger)
- [google-cloud-debugger on RubyGems](https://rubygems.org/gems/google-cloud-debugger)
- [Stackdriver Debugger documentation](https://cloud.google.com/debugger/docs/)

## Quick Start

Setting up Stackdriver Debugger involves three steps:

1. Add the `google-cloud-debugger` library to your app.
2. Register your app's source code.
3. Deploy your app and set a breakpoint.

See the
[google-cloud-debugger documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-debugger/master/google/cloud/debugger)
for a quick tutorial.

## Supported Ruby Versions

This library is supported on Ruby 2.3+.

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
