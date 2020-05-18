# Ruby Client for Google Cloud Firestore API

[Google Cloud Firestore API][Product Documentation]:

- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable the Google Cloud Firestore API.](https://console.cloud.google.com/apis/api/firestore)
3. [Setup Authentication.](https://googleapis.dev/ruby/google-cloud-firestore/latest/file.AUTHENTICATION.html)

### Installation
```
$ gem install google-cloud-firestore
```

### Next Steps
- Read the [Client Library Documentation][] for Google Cloud Firestore API
  to see other available methods on the client.
- Read the [Google Cloud Firestore API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

## Example

```ruby
require "google/cloud/firestore"

firestore = Google::Cloud::Firestore.new(
  project_id: "my-project",
  credentials: "/path/to/keyfile.json"
)

city = firestore.col("cities").doc("SF")
city.set({ name: "San Francisco",
           state: "CA",
           country: "USA",
           capital: false,
           population: 860000 })

firestore.transaction do |tx|
  new_population = tx.get(city).data[:population] + 1
  tx.update(city, { population: new_population })
end
```

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb) and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

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

[Client Library Documentation]: https://googleapis.dev/ruby/google-cloud-firestore/latest
[Product Documentation]: https://cloud.google.com/firestore
