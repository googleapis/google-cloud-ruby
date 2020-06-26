## Migrating to google-cloud-talent 0.20

The 0.20 release of the google-cloud-talent client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into two libraries. The new gem
    `google-cloud-talent-v4beta1` contains the actual client classes for version
    V4beta1 of the Talent service, and the gem `google-cloud-talent` now
    simply provides a convenience wrapper. See
    [Library Structure](#library-structure) for more info.
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
 *  Previously, some client classes included class methods for constructing
    resource paths. These paths are now instance methods on the client objects,
    and are also available in a separate paths module. See
    [Resource Path Helpers](#resource-path-helpers) for more info.
 *  Previously, clients reported RPC errors by raising instances of
    `Google::Gax::GaxError` and its subclasses. Now, RPC exceptions are of type
    `Google::Cloud::Error` and its subclasses. See
    [Handling Errors](#handling-errors) for more info.
 *  Some classes have moved into different namespaces. See
    [Class Namespaces](#class-namespaces) for more info.

### Library Structure

Older pre-0.20 releases of the `google-cloud-talent` gem were all-in-one gems
that included potentially multiple clients for multiple versions of the
Talent service. Factory methods such as `Google::Cloud::Talent::ApplicationService.new`
would return you instances of client classes such as
`Google::Cloud::Talent::V4beta1::ApplicationServiceClient`. These classes were all defined
in the same gem.

With the 0.20 release, the `google-cloud-talent` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. Currently,
Talent has one version, V4beta1. The
`Google::Cloud::Talent::V4beta1::ApplicationService::Client` class, along with its
helpers and data types, is now part of the `google-cloud-talent-v4beta1` gem.

For normal usage, you can continue to install the `google-cloud-talent` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will only
use `V4beta1` of the service, you can install `google-cloud-talent-v4beta1` by
itself, and construct instances of the
`Google::Cloud::Talent::V4beta1::ApplicationService::Client` client class directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 0.20 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all Talent V4beta1 application service clients:

```
Google::Cloud::Talent::V4beta1::ApplicationService::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `list_applications` call:

```
Google::Cloud::Talent::V4beta1::ApplicationService::Client.configure do |config|
  config.rpcs.list_applications.timeout = 20.0
end
```

Defaults for certain configurations can be set for all Talent versions and
services globally:

```
Google::Cloud::Talent.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the `new` method
of modules under `Google::Cloud::Talent`. For example, you might call
`Google::Cloud::Talent::ApplicationService.new`. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

With the 0.20 release, use named class methods of `Google::Cloud::Talent` to
create a client object. For example, `Google::Cloud::Talent.application_service`.
You may select a service version using the `:version` keyword argument.
However, other configuration parameters should be set in a configuration block
when you create the client.

Old:
```
client = Google::Cloud::Talent::ApplicationService.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::Talent.application_service do |config|
  config.credentials = "/path/to/credentials.json"
end
```

The configuration block is optional. If you do not provide it, or you do not
set some configuration parameters, then the default configuration is used. See
[Client Configuration](#client-configuration).

### Passing Arguments

In older releases, required arguments would be passed as positional method
arguments, while most optional arguments would be passed as keyword arguments.

With the 0.20 release, all RPC arguments are passed as keyword arguments,
regardless of whether they are required or optional. For example:

Old:
```
client = Google::Cloud::Talent::ApplicationService.new

parent = "projects/my-project/tenants/my-tenant/profiles/my-profile"

# Parent is a positional argument, but page_size is a keyword argument
response = client.list_applications parent, page_size: 10
```

New:
```
client = Google::Cloud::Talent.application_service

parent = "projects/my-project/tenants/my-tenant/profiles/my-profile"

# Parent and page_size are both keyword arguments
response = client.list_applications parent: parent, page_size: 10
```

In the 0.20 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::Talent.application_service

request = Google::Cloud::Talent::V1beta4::ListApplicationsRequest.new(
  parent: "projects/my-project/tenants/my-tenant/profiles/my-profile",
  page_size: 10
)

# Pass a request object as a positional argument:
response = client.list_applications request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
0.20 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::Talent::ApplicationService.new

parent = "projects/my-project/tenants/my-tenant/profiles/my-profile"

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.list_applications parent, page_size: 10, options: options
```

New:
```
client = Google::Cloud::Talent.application_service

parent = "projects/my-project/tenants/my-tenant/profiles/my-profile"

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.list_applications(
  { parent: parent, page_size: 10 },
  timeout: 10.0
) 
```

### Resource Path Helpers

The client library includes helper methods for generating the resource path
strings passed to many calls. These helpers have changed in two ways:

* In older releases, they are _class_ methods on the client class. In the 0.20
  release, they are _instance_ methods on the client. They are also available
  on a separate paths module that you can include elsewhere for convenience.
* In older releases, arguments to a resource path helper are passed as
  _positional_ arguments. In the 0.20 release, they are passed as named _keyword_
  arguments. Some helpers also support different sets of arguments, each set
  corresponding to a different type of path.

Following is an example involving using a resource path helper.

Old:
```
client = Google::Cloud::Talent::ApplicationService.new

# Call the helper on the client class
parent = Google::Cloud::Talent::V1beta4::ApplicationServiceClient.profile_path(
  "my-project", "my-tenant", "my-profile"
)

response = client.list_applications parent, page_size: 10
```

New:
```
client = Google::Cloud::Talent.application_service

# Call the helper on the client instance, and use keyword arguments
parent = client.profile_path project: "my-project", tenant: "my-tenant",
                             profile: "my-profile"

response = client.list_applications parent: parent, page_size: 10
```

Because arguments are passed as keyword arguments, some closely related paths
have been combined. For example, `job_path` and `job_without_tenant_path` used
to be separate helpers, one that took a tenant argument and one that did not.
In the 0.20 client, use `job_path` for both, and either pass or omit the
`tenant` keyword argument.

Old:
```
job1 = Google::Cloud::Talent::V1beta4::ApplicationServiceClient.job_path(
  "my-project", "my-tenant", "my-job"
)
job2 = Google::Cloud::Talent::V1beta4::ApplicationServiceClient.job_without_tenant_path(
  "my-project", "my-job"
)
```

New:
```
client = Google::Cloud::Talent.application_service
job1 = client.job_path project: "my-project", tenant: "my-tenant", job: "my-job"
job2 = client.job_path project: "my-project", job: "my-job"
```

Finally, in the 0.20 client, you can also use the paths module as a convenience module.

New:
```
# Bring the path helper methods into the current class
include Google::Cloud::Talent::V1beta4::ApplicationService::Paths

def foo
  client = Google::Cloud::Talent.application_service

  # Call the included helper method
  parent = profile_path project: "my-project", tenant: "my-tenant",
                        profile: "my-profile"

  response = client.list_applications parent: parent, page_size: 10

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

The 0.20 client library now uses the `Google::Cloud::Error` exception hierarchy,
for consistency across all the Google Cloud client libraries. In general, these
exceptions have the same name as their counterparts from older releases, but
are located in the `Google::Cloud` namespace rather than the `Google::Gax`
namespace.

Old:
```
client = Google::Cloud::Talent::ApplicationService.new

parent = "projects/my-project/tenants/my-tenant/profiles/my-profile"

begin
  response = client.list_applications parent, page_size: 10
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New:
```
client = Google::Cloud::Talent.application_service

parent = "projects/my-project/tenants/my-tenant/profiles/my-profile"

begin
  response = client.list_applications parent: parent, page_size: 10
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```

### Class Namespaces

In older releases, the client object was of classes with names like:
`Google::Cloud::Talent::V1beta4::ApplicationServiceClient`.
In the 0.20 release, the client object is of a different class:
`Google::Cloud::Talent::V1beta4::ApplicationService::Client`.
Note that most users will use the factory methods such as
`Google::Cloud::Talent.application_service` to create instances of the client object,
so you may not need to reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::Talent::V1beta4::Credentials`.
In the 0.20 release, each service has its own credentials class, e.g.
`Google::Cloud::Talent::V1beta4::ApplicationService::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).
