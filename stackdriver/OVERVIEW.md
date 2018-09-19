# Stackdriver

The stackdriver gem instruments a Ruby web application for Stackdriver
diagnostics. When loaded, it integrates with Rails, Sinatra, or other Rack-based
web frameworks to collect application diagnostic and monitoring information for
your application.

Specifically, this gem is a convenience package that loads the following gems:

- [google-cloud-debugger](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-debugger)
- [google-cloud-error_reporting](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-error_reporting)
- [google-cloud-logging](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-logging)
- [google-cloud-trace](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace)

On top of that, stackdriver gem automatically activates the following
instrumentation features:

- [google-cloud-debugger instrumentation](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-debugger/latest/file.INSTRUMENTATION)
- [google-cloud-error_reporting strumentation](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-error_reporting/latest/file.INSTRUMENTATION)
- [google-cloud-logging instrumentation](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-logging/latest/file.INSTRUMENTATION)
- [google-cloud-trace instrumentation](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace/latest/file.INSTRUMENTATION)

## Usage

Instead of requiring multiple Stackdriver client library gems and explicitly
load each built-in Railtie classes, now users can achieve all these through
requiring this single **stackdriver** umbrella gem.

```ruby
require "stackdriver"
```
