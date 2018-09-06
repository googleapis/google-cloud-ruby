# Enabling gRPC Logging

To enable logging for this library, set the logger for the underlying
[gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger
that you set may be a Ruby stdlib
[`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as
shown below, or a
[`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-logging/latest/Google/Cloud/Logging/Logger)
that will write logs to [Stackdriver
Logging](https://cloud.google.com/logging/). See
[grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
and the gRPC
[spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb)
for additional information.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

module MyLogger
  LOGGER = Logger.new $stderr, level: Logger::WARN
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end
```
