# Ruby Client for the Cloud Debugger V2 API

API Client library for the Cloud Debugger V2 API

The Cloud Debugger API allows applications to interact with the Google Cloud Debugger backends. It provides two interfaces: the Debugger interface and the Controller interface. The Controller interface allows you to implement an agent that sends state data -- for example, the value of program variables and the call stack -- to Cloud Debugger when the application is running. The Debugger interface allows you to implement a Cloud Debugger client that allows users to set and delete the breakpoints at which the state data is collected, as well as read the data that is captured.

https://github.com/googleapis/google-cloud-ruby

## Installation

```
$ gem install google-cloud-debugger-v2
```

## Before You Begin

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. [Enable the API.](https://console.cloud.google.com/apis/library/clouddebugger.googleapis.com)
1. {file:AUTHENTICATION.md Set up authentication.}

## Quick Start

```ruby
require "google/cloud/debugger/v2"

client = ::Google::Cloud::Debugger::V2::Controller::Client.new
request = my_create_request
response = client.register_debuggee request
```

View the [Client Library Documentation](https://googleapis.dev/ruby/google-cloud-debugger-v2/latest)
for class and method documentation.

See also the [Product Documentation](https://cloud.google.com/debugger)
for general usage information.

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html) as shown below,
or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest)
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

## Supported Ruby Versions

This library is supported on Ruby 2.4+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.4
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.
