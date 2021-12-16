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

## Enabling gRPC interceptors

To enable [gRPC interceptors](https://github.com/grpc/proposal/blob/master/L11-ruby-interceptors.md) for this library,
write your interceptor as a subclass of `GRPC::ClientInterceptor`, then add an instance of it to the list of gRPC
interceptors accepted by the `configure` method provided by a lower-level generated Gapic client class.

The lower-level Gapic clients used by this library are:

* []()

Configuring a Ruby gRPC interceptor:

```ruby
require "grpc"
require "google/cloud/pubsub"

class MyInterceptor < GRPC::ClientInterceptor
  attr_reader :name

  def initialize name
    @name = name
  end

  def request_response(request:, call:, method:, metadata:)
    logger.info "[#{name}] Sending unary request/response to #{method}"
    metadata['request_id'] = generate_request_id
    yield
  end

  def client_streamer(requests:, call:, method:, metadata:)
    logger.info "[#{name}] Sending client streamer to #{method}"
    metadata['request_id'] = generate_request_id
    yield
  end

  def server_streamer(request:, call:, method:, metadata:)
    logger.info "[#{name}] Sending server streamer to #{method}"
    metadata['request_id'] = generate_request_id
    yield
  end

  def bidi_streamer(requests:, call:, method:, metadata:)
    logger.info "[#{name}] Sending bidi streamer to #{method}"
    metadata['request_id'] = generate_request_id
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

Google::Cloud::PubSub::V1::Publisher::Client.configure do |config|
  config.interceptors = [MyInterceptor.new("MyPublisherInterceptor")]
end

Google::Cloud::PubSub::V1::Subscriber::Client.configure do |config|
  config.interceptors = [MyInterceptor.new("MySubscriberInterceptor")]
end

pubsub = Google::Cloud::PubSub.new
```
