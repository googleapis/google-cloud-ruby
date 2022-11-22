# Logging

## Enabling gRPC Logging

To enable logging for this library, set the logger for the underlying
[gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger
that you set may be a Ruby stdlib
[`Logger`](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html) as
shown below, or a
[`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest)
that will write logs to [Stackdriver
Logging](https://cloud.google.com/logging/). See
[grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
and the gRPC
[spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb)
for additional information.

Configuring a Ruby stdlib logger:

```ruby
require "logger"
require "grpc"

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

## Adding gRPC interceptors

[gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) accepts [Ruby-language
interceptors](https://github.com/grpc/proposal/blob/master/L11-ruby-interceptors.md) that allow you to insert your own
custom logging into a client's RPC calls. (gRPC interceptors are also useful for auth, metrics, tracing and similar
use cases.)

This library performs RPCs using the following [gapic](https://github.com/googleapis/gapic-generator-ruby) clients from
the underlying
[google-cloud-pubsub-v1](https://github.com/googleapis/google-cloud-ruby/tree/main/google-cloud-pubsub-v1) library:

* [`Google::Cloud::PubSub::V1::IAMPolicy::Client`](https://googleapis.dev/ruby/google-cloud-pubsub-v1/latest/Google/Cloud/PubSub/V1/IAMPolicy/Client.html)
* [`Google::Cloud::PubSub::V1::Publisher::Client`](https://googleapis.dev/ruby/google-cloud-pubsub-v1/latest/Google/Cloud/PubSub/V1/Publisher/Client.html)
* [`Google::Cloud::PubSub::V1::SchemaService::Client`](https://googleapis.dev/ruby/google-cloud-pubsub-v1/latest/Google/Cloud/PubSub/V1/SchemaService/Client.html)
* [`Google::Cloud::PubSub::V1::Subscriber::Client`](https://googleapis.dev/ruby/google-cloud-pubsub-v1/latest/Google/Cloud/PubSub/V1/Subscriber/Client.html)

To add a gRPC interceptor to one or more of these clients, first implement your logic as a subclass of
[`GRPC::ClientInterceptor`](https://www.rubydoc.info/gems/grpc/GRPC/ClientInterceptor). The example below logs all four
types of gRPC calls (unary, client streaming, server streaming, and bi-directional streaming.) It also demonstrates how
to set a metadata field.

```ruby
require "grpc"
require "logger"
require "securerandom"

class MyInterceptor < GRPC::ClientInterceptor
  attr_reader :name

  def initialize name
    @name = name
  end

  def request_response(request:, call:, method:, metadata:)
    logger.info "[#{name}] Sending unary request/response to #{method}"
    metadata["request_id"] = generate_request_id
    yield
  end

  def client_streamer(requests:, call:, method:, metadata:)
    logger.info "[#{name}] Sending client streamer to #{method}"
    metadata["request_id"] = generate_request_id
    yield
  end

  def server_streamer(request:, call:, method:, metadata:)
    logger.info "[#{name}] Sending server streamer to #{method}"
    metadata["request_id"] = generate_request_id
    yield
  end

  def bidi_streamer(requests:, call:, method:, metadata:)
    logger.info "[#{name}] Sending bidi streamer to #{method}"
    metadata["request_id"] = generate_request_id
    yield
  end

  private

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def generate_request_id
    SecureRandom.uuid
  end
end
```

Next, use the block yielded by a `Client.configure` method to add an instance of your class to the `interceptors`
configuration of one or more of the generated clients listed above.

Note that the `Google::Cloud::PubSub::V1` configurations must be performed **before** the `Google::Cloud::PubSub` client
is instantiated.

```ruby
require "google/cloud/pubsub"

Google::Cloud::PubSub::V1::Publisher::Client.configure do |config|
  config.interceptors = [MyInterceptor.new("MyPublisherInterceptor")]
end

Google::Cloud::PubSub::V1::Subscriber::Client.configure do |config|
  config.interceptors = [MyInterceptor.new("MySubscriberInterceptor")]
end

pubsub = Google::Cloud::PubSub.new
```
