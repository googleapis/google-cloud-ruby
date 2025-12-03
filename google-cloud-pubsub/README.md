# google-cloud-pubsub

[Google Cloud Pub/Sub](https://cloud.google.com/pubsub/) ([docs](https://cloud.google.com/pubsub/docs/reference/rest/)) is designed to provide reliable, many-to-many, asynchronous messaging between applications. Publisher applications can send messages to a “topic” and other applications can subscribe to that topic to receive the messages. By decoupling senders and receivers, Google Cloud Pub/Sub allows developers to communicate between independently written applications.

- Full set of examples and detailed docs in the [google-cloud-pubsub API documentation](https://googleapis.dev/ruby/google-cloud-pubsub/latest)
- [google-cloud-pubsub on RubyGems](https://rubygems.org/gems/google-cloud-pubsub)
- [General Google Cloud Pub/Sub documentation](https://cloud.google.com/pubsub/docs)

## Quick Start

```sh
$ gem install google-cloud-pubsub
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Google Cloud Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine (GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run, the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googleapis.dev/ruby/google-cloud-pubsub/latest/file.AUTHENTICATION.html).

## Example

```ruby
require "googleauth"
require "google/cloud/pubsub"

credentials = ::Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: ::File.open("/path/to/keyfile.json")
)

pubsub = Google::Cloud::PubSub.new(
  project_id: "my-project",
  credentials: credentials
)

# Get a publisher for a topic
publisher = pubsub.publisher "my-topic"

# Publish a new message
msg = publisher.publish "new-message"

# Get a subscriber for a subscription
subscriber = pubsub.subscriber "my-topic-sub"

# Create a listener to listen for available messages
# By default, this block will be called on 8 concurrent threads.
# This can be changed with the :threads option
listener = subscriber.listen do |received_message|
  # process message
  puts "Data: #{received_message.message.data}, published at #{received_message.message.published_at}"
  received_message.acknowledge!
end

# Handle exceptions from listener
listener.on_error do |exception|
  puts "Exception: #{exception.class} #{exception.message}"
end

# Gracefully shut down the subscriber on program exit, blocking until
# all received messages have been processed or 10 seconds have passed
at_exit do
  listener.stop!(10)
end

# Start background threads that will call the block passed to listen.
listener.start

# Block, letting processing threads continue in the background
sleep
```


## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/current/stdlibs/logger/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb) and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

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

### Enabling library level logging

This library includes an opt-in logging mechanism that provides detailed information about high-level operations. These logs are useful for troubleshooting and monitoring the client's behavior. When enabled, logs are tagged with subtags to indicate the operation type.

The following subtags are used:

*   `callback-delivery`: Logs when a message is delivered to the user-provided callback.
*   `callback-exceptions`: Logs any exceptions raised from the user callback.
*   `ack-nack`: Logs when a message is acknowledged (`ack`) or negatively acknowledged (`nack`).
*   `ack-batch`: Logs the reason and size of acknowledgement batches sent to the server.
*   `publish-batch`: Logs the reason and size of message batches sent to the server for publishing.
*   `expiry`: Logs when a message's lease expires and it is dropped from client-side lease management.
*   `subscriber-streams`: Logs key events in the subscriber's streaming connection, such as opening, closing, and errors.
*   `subscriber-flow-control`: Logs when the subscriber's client-side flow control is paused or resumed.

**WARNING:** These logs may contain message data in plaintext, which could include sensitive information. Ensure you are practicing good data hygiene with your application logs. It is recommended to enable this logging only for debugging purposes and not permanently in production.

To enable logging across all of Google Cloud Ruby SDK Gems, set the `GOOGLE_SDK_RUBY_LOGGING_GEMS` environment variable to `all`.
To enable logging for just the google-cloud-pubsub gem, set the `GOOGLE_SDK_RUBY_LOGGING_GEMS` environment variable to a comma separated string that contains `pubsub`
To disable logging across all of Google Cloud Ruby SDK Gems, set the `GOOGLE_SDK_RUBY_LOGGING_GEMS` to `none`

```sh
export GOOGLE_SDK_RUBY_LOGGING_GEMS=pubsub
```

You can programmatically configure a custom logger. The logger can be set globally for the Pub/Sub library, or provided on a per-client basis.

To set a logger globally, configure it on the `Google::Cloud` configuration object:

```ruby
require "google/cloud/pubsub"
require "logger"

# Configure a global logger for the pubsub library
Google::Cloud.configure.pubsub.logger = Logger.new "my-app.log"
```

Alternatively, you can provide a logger directly to the `PubSub` client initializer. If a logger instance is provided, it will override any globally configured logger.

```ruby
require "google/cloud/pubsub"
require "logger"

# Provide a logger directly to the client
custom_logger = Logger.new "pubsub-client.log"
pubsub = Google::Cloud::PubSub.new logger: custom_logger
```

If no custom logger is configured, a default logger that writes to standard output will be used.


## Supported Ruby Versions

This library is supported on Ruby 3.1+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or in
security maintenance, and not end of life. Older versions of Ruby _may_ still
work, but are unsupported and not recommended. See
https://www.ruby-lang.org/en/downloads/branches/ for details about the Ruby
support schedule.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

This library is considered to be stable and will not have backwards-incompatible changes introduced in subsequent minor releases.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing
Guide](https://googleapis.dev/ruby/google-cloud-pubsub/latest/file.CONTRIBUTING.html)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.dev/ruby/google-cloud-pubsub/latest/file.CODE_OF_CONDUCT.html)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googleapis.dev/ruby/google-cloud-pubsub/latest/file.LICENSE.html).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
