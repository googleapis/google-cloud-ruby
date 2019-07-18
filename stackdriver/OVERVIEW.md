# Stackdriver

The stackdriver gem instruments a Ruby web application for Stackdriver
diagnostics. When loaded, it integrates with Rails, Sinatra, or other Rack-based
web frameworks to collect application diagnostic and monitoring information for
your application.

Specifically, this gem is a convenience package that loads the following gems:

- [google-cloud-debugger](../google-cloud-debugger/README.md
- [google-cloud-error_reporting](../google-cloud-error_reporting/README.md
- [google-cloud-logging](../google-cloud-logging/README.md
- [google-cloud-trace](../google-cloud-trace/README.md

On top of that, stackdriver gem automatically activates the following
instrumentation features:

- [google-cloud-debugger instrumentation](../google-cloud-debugger/INSTRUMENTATION.md
- [google-cloud-error_reporting strumentation](../google-cloud-error_reporting/INSTRUMENTATION.md
- [google-cloud-logging instrumentation](../google-cloud-logging/INSTRUMENTATION.md
- [google-cloud-trace instrumentation](../google-cloud-trace/INSTRUMENTATION.md

## Usage

Instead of requiring multiple Stackdriver client library gems and explicitly
load each built-in Railtie classes, now users can achieve all these through
requiring this single **stackdriver** umbrella gem.

```ruby
require "stackdriver"
```
