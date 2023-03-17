# Ruby Client for the Locations API

API Client library for the Locations API

An add-on interface used by some Google API clients to provide location management calls.

https://github.com/googleapis/google-cloud-ruby

## Installation

```
$ gem install google-cloud-location
```

## Before You Begin

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. [Set up authentication.](AUTHENTICATION.md)

## Quick Start

```ruby
require "google/cloud/location"

client = ::Google::Cloud::Location::Locations::Client.new
request = ::Google::Cloud::Location::ListLocationsRequest.new # (request fields as keyword arguments...)
response = client.list_locations request
```

View the [Client Library Documentation](https://cloud.google.com/ruby/docs/reference/google-cloud-location/latest)
for class and method documentation.

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/current/stdlibs/logger/Logger.html) as shown below,
or a [`Google::Cloud::Logging::Logger`](https://cloud.google.com/ruby/docs/reference/google-cloud-logging/latest)
that will write logs to [Cloud Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

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


## Google Cloud Samples

To browse ready to use code samples check [Google Cloud Samples](https://cloud.google.com/docs/samples).

## Supported Ruby Versions

This library is supported on Ruby 2.6+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Older versions of Ruby _may_
still work, but are unsupported and not recommended. See
https://www.ruby-lang.org/en/downloads/branches/ for details about the Ruby
support schedule.
