# Ruby Client for the Secret Manager API

API Client library for the Secret Manager API

Secret Manager is a secure and convenient storage system for API keys, passwords, certificates, and other sensitive data. Secret Manager provides a central place and single source of truth to manage, access, and audit secrets across Google Cloud.

Actual client classes for the various versions of this API are defined in
_versioned_ client gems, with names of the form `google-cloud-secret_manager-v*`.
The gem `google-cloud-secret_manager` is a convenience wrapper library that brings the
verisoned gems in as dependencies, and provides high-level methods for
constructing clients.

View the [Client Library Documentation](https://googleapis.dev/ruby/google-cloud-secret_manager/latest)
for this library, google-cloud-secret_manager, to see the convenience methods for
constructing client objects. Reference documentation for the client objects
themselves can be found in the client library documentation for the versioned
client gems:
[google-cloud-secret_manager-v1](https://googleapis.dev/ruby/google-cloud-secret_manager-v1/latest),
[google-cloud-secret_manager-v1beta1](https://googleapis.dev/ruby/google-cloud-secret_manager-v1beta1/latest).

See also the [Product Documentation](https://cloud.google.com/secret-manager)
for more usage information.

## Quick Start

```
$ gem install google-cloud-secret_manager
```

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. [Enable the API.](https://console.cloud.google.com/apis/library/secretmanager.googleapis.com)
1. {file:AUTHENTICATION.md Set up authentication.}

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html) as shown below,
or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest)
that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
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
