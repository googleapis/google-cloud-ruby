# Stackdriver

The stackdriver gem instruments a Ruby web application for Stackdriver
diagnostics. When loaded, it integrates with Rails, Sinatra, or other Rack-based
web frameworks to collect application diagnostic and monitoring information for
your application.

Specifically, this gem is a convenience package that loads the following gems:

- [google-cloud-debugger](https://googleapis.dev/ruby/google-cloud-debugger/latest
- [google-cloud-error_reporting](https://googleapis.dev/ruby/google-cloud-error_reporting/latest
- [google-cloud-logging](https://googleapis.dev/ruby/google-cloud-logging/latest
- [google-cloud-trace](https://googleapis.dev/ruby/google-cloud-trace/latest

On top of that, stackdriver gem automatically activates the following
instrumentation features:

- [google-cloud-debugger instrumentation](https://googleapis.dev/ruby/google-cloud-debugger/latest/file.INSTRUMENTATION.html
- [google-cloud-error_reporting strumentation](https://googleapis.dev/ruby/google-cloud-error_reporting/latest/file.INSTRUMENTATION.html
- [google-cloud-logging instrumentation](https://googleapis.dev/ruby/google-cloud-logging/latest/file.INSTRUMENTATION.html
- [google-cloud-trace instrumentation](https://googleapis.dev/ruby/google-cloud-trace/latest/file.INSTRUMENTATION.html

## Usage

Instead of requiring multiple Stackdriver client library gems and explicitly
load each built-in Railtie classes, now users can achieve all these through
requiring this single **stackdriver** umbrella gem.

```ruby
require "stackdriver"
```
