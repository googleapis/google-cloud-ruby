# Ruby Client for Cloud Natural Language API

[Cloud Natural Language API][Product Documentation]:
Provides natural language understanding technologies, such as sentiment
analysis, entity recognition, entity sentiment analysis, and other text
annotations.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Cloud Natural Language API.](https://console.cloud.google.com/apis/library/language.googleapis.com)
4. [Setup Authentication.](https://googleapis.dev/ruby/google-cloud-language/latest/file.AUTHENTICATION.html)

### Installation
```
$ gem install google-cloud-language
```

### Next Steps
- Read the [Client Library Documentation][] for Cloud Natural Language API
  to see other available methods on the client.
- Read the [Cloud Natural Language API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googleapis.dev/ruby/google-cloud-language/latest
[V1 Client Documentation]: https://googleapis.dev/ruby/google-cloud-language-v1/latest
[V1beta2 Client Documentation]: https://googleapis.dev/ruby/google-cloud-language-v1beta2/latest
[Product Documentation]: https://cloud.google.com/natural-language

## Migrating from 0.x versions

The 1.0 release of the google-cloud-language client is a significant upgrade
based on a next-gen code generator. If you have used earlier versions of this
library, there have been a number of changes that may require updates to
calling code. See the MIGRATING.md document for more information.

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below,
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
