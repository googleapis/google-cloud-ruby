# Ruby Client for the Grafeas V1 API

An implementation of the Grafeas API, which stores, and enables querying and retrieval of critical metadata about all of your software artifacts.

The Grafeas API stores, and enables querying and retrieval of, critical metadata about all of your software artifacts.

https://github.com/googleapis/google-cloud-ruby

This gem is a _versioned_ client. It provides basic client classes for a
specific version of the Grafeas V1 API. Most users should consider using
the main client gem,
[grafeas](https://rubygems.org/gems/grafeas).
See the section below titled *Which client should I use?* for more information.

## Installation

```
$ gem install grafeas-v1
```

## Quick Start

```ruby
require "grafeas/v1"

client = ::Grafeas::V1::Grafeas::Client.new
request = ::Grafeas::V1::GetOccurrenceRequest.new # (request fields as keyword arguments...)
response = client.get_occurrence request
```

View the [Client Library Documentation](https://cloud.google.com/ruby/docs/reference/grafeas-v1/latest)
for class and method documentation.

## Debug Logging

This library comes with opt-in Debug Logging that can help you troubleshoot
your application's integration with the API. When logging is activated, key
events such as requests and responses, along with data payloads and metadata
such as headers and client configuration, are logged to the standard error
stream.

**WARNING:** Client Library Debug Logging includes your data payloads in
plaintext, which could include sensitive data such as PII for yourself or your
customers, private keys, or other security data that could be compromising if
leaked. Always practice good data hygiene with your application logs, and follow
the principle of least access. Google also recommends that Client Library Debug
Logging be enabled only temporarily during active debugging, and not used
permanently in production.

To enable logging, set the environment variable `GOOGLE_SDK_RUBY_LOGGING_GEMS`
to the value `all`. Alternatively, you can set the value to a comma-delimited
list of client library gem names. This will select the default logging behavior,
which writes logs to the standard error stream. On a local workstation, this may
result in logs appearing on the console. When running on a Google Cloud hosting
service such as [Google Cloud Run](https://cloud.google.com/run), this generally
results in logs appearing alongside your application logs in the
[Google Cloud Logging](https://cloud.google.com/logging/) service.

You can customize logging by modifying the `logger` configuration when
constructing a client object. For example:

```ruby
require "grafeas/v1"
require "logger"

client = ::Grafeas::V1::Grafeas::Client.new do |config|
  config.logger = Logger.new "my-app.log"
end
```

## Google Cloud Samples

To browse ready to use code samples check [Google Cloud Samples](https://cloud.google.com/docs/samples).

## Supported Ruby Versions

This library is supported on Ruby 2.7+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Older versions of Ruby _may_
still work, but are unsupported and not recommended. See
https://www.ruby-lang.org/en/downloads/branches/ for details about the Ruby
support schedule.

## Which client should I use?

Most modern Ruby client libraries for Google APIs come in two flavors: the main
client library with a name such as `grafeas`,
and lower-level _versioned_ client libraries with names such as
`grafeas-v1`.
_In most cases, you should install the main client._

### What's the difference between the main client and a versioned client?

A _versioned client_ provides a basic set of data types and client classes for
a _single version_ of a specific service. (That is, for a service with multiple
versions, there might be a separate versioned client for each service version.)
Most versioned clients are written and maintained by a code generator.

The _main client_ is designed to provide you with the _recommended_ client
interfaces for the service. There will be only one main client for any given
service, even a service with multiple versions. The main client includes
factory methods for constructing the client objects we recommend for most
users. In some cases, those will be classes provided by an underlying versioned
client; in other cases, they will be handwritten higher-level client objects
with additional capabilities, convenience methods, or best practices built in.
Generally, the main client will default to a recommended service version,
although in some cases you can override this if you need to talk to a specific
service version.

### Why would I want to use the main client?

We recommend that most users install the main client gem for a service. You can
identify this gem as the one _without_ a version in its name, e.g.
`grafeas`.
The main client is recommended because it will embody the best practices for
accessing the service, and may also provide more convenient interfaces or
tighter integration into frameworks and third-party libraries. In addition, the
documentation and samples published by Google will generally demonstrate use of
the main client.

### Why would I want to use a versioned client?

You can use a versioned client if you are content with a possibly lower-level
class interface, you explicitly want to avoid features provided by the main
client, or you want to access a specific service version not be covered by the
main client. You can identify versioned client gems because the service version
is part of the name, e.g. `grafeas-v1`.

### What about the google-apis-<name> clients?

Client library gems with names that begin with `google-apis-` are based on an
older code generation technology. They talk to a REST/JSON backend (whereas
most modern clients talk to a [gRPC](https://grpc.io/) backend) and they may
not offer the same performance, features, and ease of use provided by more
modern clients.

The `google-apis-` clients have wide coverage across Google services, so you
might need to use one if there is no modern client available for the service.
However, if a modern client is available, we generally recommend it over the
older `google-apis-` clients.
