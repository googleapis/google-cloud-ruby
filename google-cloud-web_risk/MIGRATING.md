## Migrating to google-cloud-web_risk 1.0

The `google-cloud-web_risk` gem is a significant upgrade over the older and now
deprecated `google-cloud-webrisk` gem. It is based on a
[next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for the older
gem will likely require updates to use this version. This document describes
the changes that have been made, and what you need to do to update your usage.

To summarize:

 *  The new gem supports versions V1 and V1beta1 of the Web Risk service. The
    older gem supported only V1beta1.
 *  The client has been broken out into multiple libraries. The new gems
    `google-cloud-web_risk-v1` and `google-cloud-web_risk-v1beta1` contain the
    actual client classes for versions V1 and V1beta1 of the Web Risk service,
    and the gem `google-cloud-web_risk` provides a convenience wrapper.
    See [Library Structure](#library-structure) for more info.
 *  Some classes have moved into different namespaces. In particular, the
    `Google::Cloud::Webrisk` module has been renamed to `Google::Cloud::WebRisk`.
    See [Class Namespaces](#class-namespaces) for more info.
 *  The library uses a new configuration mechanism giving you closer control
    over endpoint address, network timeouts, and retry. See
    [Client Configuration](#client-configuration) for more info. Furthermore,
    when creating a client object, you can customize its configuration in a
    block rather than passing arguments to the constructor. See
    [Creating Clients](#creating-clients) for more info.
 *  Previously, positional arguments were used to indicate required arguments.
    Now, all method arguments are keyword arguments, with documentation that
    specifies whether they are required or optional. Additionally, you can pass
    a proto request object instead of separate arguments. See
    [Passing Arguments](#passing-arguments) for more info.
 *  Previously, clients reported RPC errors by raising instances of
    `Google::Gax::GaxError` and its subclasses. Now, RPC exceptions are of type
    `Google::Cloud::Error` and its subclasses. See
    [Handling Errors](#handling-errors) for more info.

### Library Structure

The older `google-cloud-webrisk` gem was an all-in-one gem
that included potentially multiple clients for multiple versions of the
Web Risk service. The `Google::Cloud::Webrisk.new` factory method would
return you an instance of a `Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1Client`
object for the V1beta1 version of the service. (Version V1 of the service was
not supported by the older gem.)

The new `google-cloud-web_risk` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. The
`Google::Cloud::WebRisk::V1::WebRiskService::Client` class, along with its
helpers and data types, is now part of the `google-cloud-web_risk-v1` gem.
Similarly, the `Google::Cloud::WebRisk::V1beta1::WebRiskService::Client`
class is part of the `google-cloud-web_risk-v1beta1` gem.

For normal usage, you can install the `google-cloud-web_risk` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will only
use `V1` of the service, you can install `google-cloud-web_risk-v1` by
itself, and construct instances of the
`Google::Cloud::WebRisk::V1::WebRiskService::Client` client class directly.

### Class Namespaces

As part of the gem being renamed from `google-cloud-webrisk` to
`google-cloud-web_risk`, the main namespace module has also been renamed
accordingly, from `Google::Cloud::Webrisk` to `Google::Cloud::WebRisk`. (Note
the "R" in "WebRisk" is now capitalized.) This affects the entire library,
including clients, data types, and all other modules and classes.

Additionally, some of the underlying classes have also been renamed.
In the older gem, the client object was of classes with names like:
`Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1Client`.
In the new gem, the corresponding client object is of a different class:
`Google::Cloud::WebRisk::V1beta1::WebRiskService::Client`.
Note that most users will use the factory methods such as
`Google::Cloud::WebRisk.web_risk_service` to create instances of the client object,
so you may not need to reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::Webrisk::V1beta1::Credentials`.
In the 1.0 release, each service has its own credentials class, e.g.
`Google::Cloud::WebRisk::V1beta1::WebRiskService::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).

### Client Configuration

In the older gem, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

In the new gem, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all Web Risk V1 clients:

```
Google::Cloud::WebRisk::V1::WebRiskService::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `search_uris` call:

```
Google::Cloud::WebRisk::V1::WebRiskService::Client.configure do |config|
  config.rpcs.search_uris.timeout = 20.0
end
```

Defaults for certain configurations can be set for all Web Risk versions and
services globally:

```
Google::Cloud::WebRisk.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In the older gem, to create a client object, you would use the
`Google::Cloud::Webrisk.new` class method. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

In the new gem, use the `Google::Cloud::WebRisk.web_risk_service` class
method to create a client object. You may select a service version using the
`:version` keyword argument. However, other configuration parameters should be
set in a configuration block when you create the client.

Old:
```
client = Google::Cloud::Webrisk.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::WebRisk.web_risk_service do |config|
  config.credentials = "/path/to/credentials.json"
end
```

The configuration block is optional. If you do not provide it, or you do not
set some configuration parameters, then the default configuration is used. See
[Client Configuration](#client-configuration).

### Passing Arguments

In the older gem, required arguments would be passed as positional method
arguments, while most optional arguments would be passed as keyword arguments.

In the new gem, all RPC arguments are passed as keyword arguments,
regardless of whether they are required or optional. For example:

Old:
```
client = Google::Cloud::Webrisk.new

uri = "http://example.com"
threat_types = [Google::Cloud::Webrisk::V1beta1::ThreatType::MALWARE]

# Both uri and threat_types are positional arguments.
response = client.search_uris uri, threat_types
```

New:
```
client = Google::Cloud::WebRisk.web_risk_service

uri = "http://example.com"
threat_types = [Google::Cloud::WebRisk::V1::ThreatType::MALWARE]

# Both uri and threat_types are keyword arguments.
response = client.search_uris uri: uri, threat_types: threat_types
```

In the new gem, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::WebRisk.web_risk_service

request = Google::Cloud::WebRisk::V1::SearchUrisRequest.new(
  uri: "http://example.com",
  threat_types: [Google::Cloud::WebRisk::V1::ThreatType::MALWARE]
)

# Pass a request object as a positional argument:
response = client.search_uris request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
1.0 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::Webrisk.new

uri = "http://example.com"
threat_types = [Google::Cloud::Webrisk::V1beta1::ThreatType::MALWARE]

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.search_uris uri, threat_types, options: options
```

New:
```
client = Google::Cloud::WebRisk.web_risk_service

uri = "http://example.com"
threat_types = [Google::Cloud::WebRisk::V1::ThreatType::MALWARE]

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.search_uris(
  { uri: uri, threat_types: threat_types },
  timeout: 10.0
)
```

### Handling Errors

The client reports standard
[gRPC error codes](https://github.com/grpc/grpc/blob/master/doc/statuscodes.md)
by raising exceptions. In the older gem, these exceptions were located in the
`Google::Gax` namespace and were subclasses of the `Google::Gax::GaxError` base
exception class, defined in the `google-gax` gem. However, these classes were
different from the standard exceptions (subclasses of `Google::Cloud::Error`)
thrown by other client libraries such as `google-cloud-storage`.

The new client library now uses the `Google::Cloud::Error` exception hierarchy,
for consistency across all the Google Cloud client libraries. In general, these
exceptions have the same name as their counterparts from older releases, but
are located in the `Google::Cloud` namespace rather than the `Google::Gax`
namespace.

Old:
```
client = Google::Cloud::Webrisk.new

uri = "http://example.com"
threat_types = [Google::Cloud::Webrisk::V1beta1::ThreatType::MALWARE]

begin
  response = client.search_uris uri, threat_types
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New:
```
client = Google::Cloud::WebRisk.web_risk_service

uri = "http://example.com"
threat_types = [Google::Cloud::WebRisk::V1::ThreatType::MALWARE]

begin
  response = client.search_uris uri: uri, threat_types: threat_types
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```
