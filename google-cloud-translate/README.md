# Ruby Client for the Cloud Translation API

API Client library for the Cloud Translation API

Cloud Translation can dynamically translate text between thousands of language pairs. Translation lets websites and programs programmatically integrate with the translation service.

Actual client classes for the various versions of this API are defined in
_versioned_ client gems, with names of the form `google-cloud-translate-v*`.
The gem `google-cloud-translate` is a convenience wrapper library that brings the
verisoned gems in as dependencies, and provides high-level methods for
constructing clients.

View the [Client Library Documentation](https://googleapis.dev/ruby/google-cloud-translate/latest)
for this library, google-cloud-translate, to see the convenience methods for
constructing client objects. Reference documentation for the client objects
themselves can be found in the client library documentation for the versioned
client gems:
[google-cloud-translate-v2](https://googleapis.dev/ruby/google-cloud-translate-v2/latest),
[google-cloud-translate-v3](https://googleapis.dev/ruby/google-cloud-translate-v3/latest).

See also the [Product Documentation](https://cloud.google.com/translate)
for more usage information.

## Quick Start

```
$ gem install google-cloud-translate
```

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the API.](https://console.cloud.google.com/apis/library/translate.googleapis.com)
4. [Set up authentication](AUTHENTICATION.md).

## Migrating from 2.x versions

The 3.0 release of the google-cloud-translate client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
See the {file:MIGRATING.md MIGRATING.md} document for more information.

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
