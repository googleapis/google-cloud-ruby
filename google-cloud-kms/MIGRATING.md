## Migrating to google-cloud-kms 2.0

The 2.0 release of the google-cloud-kms client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into two libraries. The new gem
    `google-cloud-kms-v1` contains the actual client classes for version
    V1 of the KMS service, and the gem `google-cloud-kms` now
    simply provides a convenience wrapper. See
    [Library Structure](#library-structure) for more info.
 *  The library uses a new configuration mechanism giving you closer control
    over endpoint address, network timeouts, and retry. See
    [Client Configuration](#client-configuration) for more info. Furthermore,
    when creating a client object, you can customize its configuration in a
    block rather than passing arguments to the constructor. See
    [Creating Clients](#creating-clients) for more info.
 *  Previously, IAM methods such as `set_iam_policy` were exposed on the main
    client object. Now they are on a separate IAM client object. See
    [Creating Clients](#creating-clients) for more info.
 *  Previously, positional arguments were used to indicate required arguments.
    Now, all method arguments are keyword arguments, with documentation that
    specifies whether they are required or optional. Additionally, you can pass
    a proto request object instead of separate arguments. See
    [Passing Arguments](#passing-arguments) for more info.
 *  Previously, some client classes included helper methods for constructing
    resource paths. These methods now take keyword rather than positional
    arguments, and are also available in a separate paths module. See
    [Resource Path Helpers](#resource-path-helpers) for more info.
 *  Previously, clients reported RPC errors by raising instances of
    `Google::Gax::GaxError` and its subclasses. Now, RPC exceptions are of type
    `Google::Cloud::Error` and its subclasses. See
    [Handling Errors](#handling-errors) for more info.
 *  Some classes have moved into different namespaces. See
    [Class Namespaces](#class-namespaces) for more info.

### Library Structure

Older 1.x releases of the `google-cloud-kms` gem were all-in-one gems
that included potentially multiple clients for multiple versions of the
KMS service. The `Google::Cloud::Kms.new` factory method would
return you an instance of a `Google::Cloud::Kms::V1::KeyManagementServiceClient`
object for the V1 version of the service.

With the 2.0 release, the `google-cloud-kms` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. Currently,
KMS has one version, V1. The
`Google::Cloud::Kms::V1::KeyManagementService::Client` class, along with its
helpers and data types, is now part of the `google-cloud-kms-v1` gem.
If an additional version of the KMS service is released, an additional gem
may be provided for its client classes.

For normal usage, you can continue to install the `google-cloud-kms` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will only
use `V1` of the service, you can install `google-cloud-kms-v1` by
itself, and construct instances of the
`Google::Cloud::Kms::V1::KeyManagementService::Client` client class directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 2.0 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all KMS V1 clients:

```
Google::Cloud::Kms::V1::KeyManagementService::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `list_key_rings` call:

```
Google::Cloud::Kms::V1::KeyManagementService::Client.configure do |config|
  config.rpcs.list_key_rings.timeout = 20.0
end
```

Defaults for certain configurations can be set for all KMS versions and
services globally:

```
Google::Cloud::Kms.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the
`Google::Cloud::Kms.new` class method. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

With the 2.0 release, use the `Google::Cloud::Kms.key_management_service` class
method to create a client object. You may select a service version using the
`:version` keyword argument. However, other configuration parameters should be
set in a configuration block when you create the client.

Old:
```
client = Google::Cloud::Kms.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::Kms.key_management_service do |config|
  config.credentials = "/path/to/credentials.json"
end
```

The configuration block is optional. If you do not provide it, or you do not
set some configuration parameters, then the default configuration is used. See
[Client Configuration](#client-configuration).

Additionally, IAM-related methods such as `set_iam_policy`, `get_iam_policy`,
and `test_iam_permissions` have been moved to a separate client class, which
you can construct by calling the `Google::Cloud::Kms.iam_policy` class method.

### Passing Arguments

In older releases, required arguments would be passed as positional method
arguments, while most optional arguments would be passed as keyword arguments.

With the 2.0 release, all RPC arguments are passed as keyword arguments,
regardless of whether they are required or optional. For example:

Old:
```
client = Google::Cloud::Kms.new

parent = "projects/my-project/locations/my-location"

# Parent is a positional argument, while page_size is a keyword argument.
response = client.list_key_rings parent, page_size: 10
```

New:
```
client = Google::Cloud::Kms.key_management_service

parent = "projects/my-project/locations/my-location"

# Parent and page_size are both keyword arguments
response = client.list_key_rings parent: parent, page_size: 10
```

In the 2.0 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::Kms.key_management_service

request = Google::Cloud::Kms::V1::ListKeyRingsRequest.new(
  parent: "projects/my-project/locations/my-location",
  page_size: 10
)

# Pass a request object as a positional argument:
response = client.list_key_rings request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
2.0 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::Kms.new

parent = "projects/my-project/locations/my-location"

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.list_key_rings parent, page_size: 10, options: options
```

New:
```
client = Google::Cloud::Kms.key_management_service

parent = "projects/my-project/locations/my-location"

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.list_key_rings(
  { parent: parent, page_size: 10 },
  timeout: 10.0
)
```

### Resource Path Helpers

The client library includes helper methods for generating the resource path
strings passed to many calls. These helpers have changed in two ways:

* In older releases, they are both _class_ methods and _instance_ methods on
  the client class. In the 2.0 release, they are _instance methods only_.
  However, they are also available on a separate paths module that you can
  include elsewhere for convenience.
* In older releases, arguments to a resource path helper are passed as
  _positional_ arguments. In the 2.0 release, they are passed as named _keyword_
  arguments.

Following is an example involving using a resource path helper.

Old:
```
client = Google::Cloud::Kms.new

# Call the helper on the client instance
parent = client.location_path "my-project", "my-location"

response = client.list_key_rings parent
```

New:
```
client = Google::Cloud::Kms.key_management_service

# Call the helper on the client instance, and use keyword arguments
parent = client.location_path project: "my-project", location: "my-location"

response = client.list_key_rings parent: parent
```

In the 2.0 client, you can also use the paths module as a convenience module.

New:
```
# Bring the path helper methods into the current class
include Google::Cloud::Kms::V1::KeyManagementService::Paths

def foo
  client = Google::Cloud::Kms.key_management_service

  # Call the included helper method
  parent = location_path project: "my-project", location: "my-location"

  response = client.list_key_rings parent: parent

  # Do something with response...
end
```

### Handling Errors

The client reports standard
[gRPC error codes](https://github.com/grpc/grpc/blob/master/doc/statuscodes.md)
by raising exceptions. In older releases, these exceptions were located in the
`Google::Gax` namespace and were subclasses of the `Google::Gax::GaxError` base
exception class, defined in the `google-gax` gem. However, these classes were
different from the standard exceptions (subclasses of `Google::Cloud::Error`)
thrown by other client libraries such as `google-cloud-storage`.

The 2.0 client library now uses the `Google::Cloud::Error` exception hierarchy,
for consistency across all the Google Cloud client libraries. In general, these
exceptions have the same name as their counterparts from older releases, but
are located in the `Google::Cloud` namespace rather than the `Google::Gax`
namespace.

Old:
```
client = Google::Cloud::Kms.new

parent = "projects/my-project/locations/my-location"

begin
  response = client.list_key_rings parent, page_size: 10
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New:
```
client = Google::Cloud::Kms.key_management_service

parent = "projects/my-project/locations/my-location"

begin
  response = client.list_key_rings parent: parent, page_size: 10
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```

### Class Namespaces

In older releases, the client object was of classes with names like:
`Google::Cloud::Kms::V1::KeyManagementServiceClient`.
In the 2.0 release, the client object is of a different class:
`Google::Cloud::Kms::V1::KeyManagementService::Client`.
Note that most users will use the factory methods such as
`Google::Cloud::Kms.key_management_service` to create instances of the client object,
so you may not need to reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::Kms::V1::Credentials`.
In the 2.0 release, each service has its own credentials class, e.g.
`Google::Cloud::Kms::V1::KeyManagementService::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).
