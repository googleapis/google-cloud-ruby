# google-cloud-trace

[Stackdriver Trace](https://cloud.google.com/trace/) is a distributed tracing 
system that collects latency data from your applications and displays it in the 
Google Cloud Platform Console. You can track how requests propagate through your
application and receive detailed near real-time performance insights. 
Stackdriver Trace automatically analyzes all of your application's traces to 
generate in-depth latency reports to surface performance degradations, and can 
capture traces from all of your VMs, containers, or Google App Engine projects.

- [google-cloud-trace API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-trace/latest)
- [google-cloud-trace instrumentation documentation](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-trace/guides/instrumentation)
- [google-cloud-trace on RubyGems](https://rubygems.org/gems/google-cloud-trace)
- [Stackdriver Trace documentation](https://cloud.google.com/trace/docs/)

## Quick Start
```sh
$ gem install google-cloud-trace
```

## Authentication

The Instrumentation client and API use Service Account credentials to connect 
to Google Cloud services. When running on Google Cloud Platform environments, 
the credentials will be discovered automatically. When running on other 
environments the Service Account credentials can be specified by providing the 
path to the JSON file, or the JSON itself, in environment variables or 
configuration code.

Instructions and configuration options are covered in the 
[Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-trace/guides/authentication).

## Example

```ruby
require "google/cloud/trace"

trace = Google::Cloud::Trace.new

result_set = trace.list_traces Time.now - 3600, Time.now
result_set.each do |trace_record|
  puts "Retrieved trace ID: #{trace_record.trace_id}"
end
```

## Rails and Rack Integration

This library also provides a built-in Railtie for Ruby on Rails integration. To
 do this, simply add this line to config/application.rb:
```ruby
require "google/cloud/trace/rails"
```

Alternatively, check out [stackdriver](../stackdriver) gem, which includes this 
library and enables the Railtie by default.

For Rack integration and more examples, see 
[Instrumentation Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/guides/instrumentation).

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may 
change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the 
[Contributing Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/contributing) 
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See 
[Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
 [LICENSE](LICENSE).

## Support

Please 
[report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to 
[ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) 
about the client or APIs on [StackOverflow](http://stackoverflow.com).
