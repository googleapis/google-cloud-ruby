# Troubleshooting

## Debug Logging

There are features built into the Google Cloud Ruby client libraries which can help you debug your application. This guide will show you how to log client library requests and responses.

**Warning:** These logs are not intended to be used in production and are meant to be used only for quickly debugging a project. The logs consist of basic logging to STDOUT, which may or may not include sensitive information. Make sure that once you are done debugging to disable the debugging flag or configuration used to avoid leaking sensitive user data. This may also include authentication tokens.

### Log examples

In Ruby, you typically pass a standard Ruby `Logger` instance to the client.

```ruby
# debug_logging_example.rb
require "google/cloud/translate/v3"
require "logger"

# Create a logger that outputs to STDOUT with DEBUG level
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

# Pass the logger to the client
client = Google::Cloud::Translate::V3::TranslationService::Client.new do |config|
  config.logger = logger
end

request = {
  parent: "projects/my-project",
  target_language_code: "en-US",
  contents: ["こんにちは"]
}

# The request and response will be logged to STDOUT
response = client.translate_text request
```

Running this script will output detailed debug information from the client library.

## Configuration

There are a few ways to configure debug logging which we will go through in this document.

### Passing a Standard Ruby Logger

The Ruby client libraries are designed to accept any logger that matches the interface of the standard Ruby `Logger` class.

```ruby
require "logger"

# Create a customized logger
custom_logger = Logger.new("application.log")
custom_logger.level = Logger::DEBUG

client = Google::Cloud::Translate::V3::TranslationService::Client.new do |config|
  config.logger = custom_logger
end
```

With this, you will be using your custom logger implementation. This opens the opportunity to extend the capabilities of logging in case you have specific needs (e.g., log rotation, formatting).

### Global Configuration

You can also configure the logger globally for all Google Cloud clients in your application using `Google::Cloud::Configure`.

```ruby
require "google/cloud/translate/v3"

Google::Cloud.configure do |config|
  config.logger = Logger.new(STDERR)
  config.logger.level = Logger::WARN
end

# This client will automatically use the global logger configuration
client = Google::Cloud::Translate::V3::TranslationService::Client.new
```

### Disabling Logging

To ensure a client does not log, you can pass a generic logger that does nothing, or simply ensure the log level is set high enough (e.g., `FATAL`) that normal operations are not recorded.

```ruby
# The TranslationServiceClient will not log debug/info messages
client = Google::Cloud::Translate::V3::TranslationService::Client.new do |config|
  # Use a logger that discards output or has a high threshold
  config.logger = Logger.new(nil)
end
```

## How can I trace gRPC issues?

When working with libraries that use gRPC (which is the default transport for many Google Cloud Ruby clients), you can use the underlying gRPC C-core environment variables to enable logging.

### Prerequisites

Ensure you have the `grpc` gem installed. You can check this by running:

```ruby
gem list grpc
# or if using bundler
bundle show grpc
```

### Transport logging with gRPC

The primary method for debugging gRPC calls in Ruby is setting environment variables. These affect the underlying C extension. The environment variables affecting gRPC are listed in the [gRPC repository](https://www.google.com/search?q=https://github.com/grpc/grpc/blob/master/doc/environment_variables.md). The important ones for diagnostics are `GRPC_TRACE` and `GRPC_VERBOSITY`.

For example, you might want to start off with `GRPC_TRACE=all` and `GRPC_VERBOSITY=debug` which will dump a lot of information, then tweak them to reduce this to only useful data (e.g., `GRPC_TRACE=http,call_error`).

```
GRPC_VERBOSITY=debug GRPC_TRACE=all ruby your_script.rb
```

## How can I diagnose proxy issues?

See [**Client Configuration**: Configuring a Proxy](https://docs.cloud.google.com/ruby/docs/reference/help/client_configuration).

## Reporting a problem

If none of the above advice helps to resolve your issue, please ask for help. If you have a support contract with Google, please create an issue in the support console instead of filing on GitHub. This will ensure a timely response.

Otherwise, please either file an issue on GitHub or ask a question on Stack Overflow. In most cases creating a GitHub issue will result in a quicker turnaround time, but if you believe your question is likely to help other users in the future, Stack Overflow is a good option. When creating a Stack Overflow question, please use the `google-cloud-platform` tag and `ruby` tag.

Although there are multiple GitHub repositories associated with the Google Cloud Libraries, we recommend filing an issue in [https://github.com/googleapis/google-cloud-ruby](https://github.com/googleapis/google-cloud-ruby) unless you are certain that it belongs elsewhere. The maintainers may move it to a different repository where appropriate, but you will be notified of this via the email associated with your GitHub account.

When filing an issue or asking a Stack Overflow question, please include as much of the following information as possible. This will enable us to help you quickly.

