## Migrating to google-cloud-monitoring 1.0

The 1.0 release of the google-cloud-monitoring client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into multiple libraries. The new gems
    `google-cloud-monitoring-v3` and `google-cloud-monitoring-dashboard-v1`
    contain the actual client classes for version V3 of the monitoring service
    and version V1 of the monitoring-dashboard service, respectively, and the
    gem `google-cloud-monitoring` now simply provides a convenience wrapper.
    See [Library Structure](#library-structure) for more info.
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

Older 0.x releases of the `google-cloud-monitoring` gem were all-in-one gems
that included multiple clients for potentially multiple versions of the various
monitoring-related services. Factory methods such as `Google::Cloud::Monitoring::Metric.new`
would return you instances of the actual client classes such as
`Google::Cloud::Monitoring::V3::MetricServiceClient`. These classes were all
defined in the same gem.

With the 1.0 release, the `google-cloud-monitoring` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service and version. The
`Google::Cloud::Monitoring::V3::MetricService::Client` class, along with its
helpers and data types, is now part of the `google-cloud-monitoring-v3` gem.
Similarly, the `Google::Cloud::Monitoring::Dashboard::V1::DashboardsService::Client`
class is part of the `google-cloud-monitoring-dashboard-v1` gem.

For normal usage, you can continue to install the `google-cloud-monitoring` gem
(which will bring in the various client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will only
use `V3` of the base monitoring service, you can install `google-cloud-monitoring-v3` by
itself, and construct instances of the `Google::Cloud::Monitoring::V3::*` client
classes directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 1.0 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all Monitoring V3 MetricService clients:

```
Google::Cloud::Monitoring::V3::MetricService::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `create_metric_descriptor` call:

```
Google::Cloud::Monitoring::V3::MetricService::Client.configure do |config|
  config.rpcs.create_metric_descriptor.timeout = 20.0
end
```

Defaults for certain configurations can be set for all Monitoring versions and
services globally:

```
Google::Cloud::Monitoring.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the `new` method
of modules under `Google::Cloud::Monitoring`. For example, you might call
`Google::Cloud::Monitoring::Metric.new`. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

With the 1.0 release, use named class methods of `Google::Cloud::Monitoring` to
create a client object. For example, `Google::Cloud::Monitoring.metric_service`.
You may select a service version using the `:version` keyword argument.
However, other configuration parameters should be set in a configuration block
when you create the client.

Old:
```
client = Google::Cloud::Monitoring::Metric.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::Monitoring.metric_service do |config|
  config.credentials = "/path/to/credentials.json"
end
```

The configuration block is optional. If you do not provide it, or you do not
set some configuration parameters, then the default configuration is used. See
[Client Configuration](#client-configuration).

A similar change was made for the monitoring dashboards service:

Old:
```
client = Google::Cloud::Monitoring::Dashboard.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::Monitoring::Dashboard.dashboards_service do |config|
  config.credentials = "/path/to/credentials.json"
end
```

### Passing Arguments

In older releases, required arguments would be passed as positional method
arguments, while most optional arguments would be passed as keyword arguments.

With the 1.0 release, all RPC arguments are passed as keyword arguments,
regardless of whether they are required or optional. For example:

Old:
```
client = Google::Cloud::Monitoring::Metric.new

name = "projects/my-project"

# The required name argument is positional, while the optional page_size
# argument is a keyword argument
response = client.list_metric_descriptors name, page_size: 10
```

New:
```
client = Google::Cloud::Monitoring.metric_service

name = "projects/my-project"

# All arguments are keyword arguments
response = client.list_metric_descriptors name: name, page_size: 10
```

In the 1.0 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::Monitoring.metric_service

request = Google::Cloud::Monitoring::V3::ListMetricDescriptorsRequest.new(
  name: "projects/my-project",
  page_size: 10
)

# Pass a request object as a positional argument:
response = client.list_metric_descriptors request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
1.0 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::Monitoring::Metric.new

name = "projects/my-project"

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.list_metric_descriptors name, page_size: 10, options: options
```

New:
```
client = Google::Cloud::Monitoring.metric_service

name = "projects/my-project"

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.list_metric_descriptors(
  { name: name, page_size: 10 },
  timeout: 10.0)
```

### Resource Path Helpers

The client library includes helper methods for generating the resource path
strings passed to many calls. These helpers have changed in two ways:

* In older releases, they are _class_ methods on the client class. In the 1.0
  release, they are _instance_ methods on the client. They are also available
  on a separate paths module that you can include elsewhere for convenience.
* In older releases, arguments to a resource path helper are passed as
  _positional_ arguments. In the 1.0 release, they are passed as named _keyword_
  arguments. Some helpers also support different sets of arguments, each set
  corresponding to a different type of path.

Following is an example involving using a resource path helper.

Old:
```
client = Google::Cloud::Monitoring::UptimeCheck.new

# Call the helper on the client class
name = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.
         uptime_check_config_path("my-project", "my-uptime-check")

response = client.get_uptime_check_config name
```

New:
```
client = Google::Cloud::Monitoring.uptime_check_service

# Call the helper on the client instance, and use keyword arguments
name = client.uptime_check_config_path project: "my-project",
                                       uptime_check_config: "my-uptime-check"

response = client.get_uptime_check_config name: name
```

Because helpers take keyword arguments, some can now generate several different
variations on the path that were not available under earlier versions of the
library. For example, `get_uptime_check_config` can generate paths with either
a project, an organization, or a folder as the parent resource.

New:
```
client = Google::Cloud::Monitoring.uptime_check_service

# Create paths with different parent resource types
name = client.uptime_check_config_path project: "my-project",
                                       uptime_check_config: "my-uptime-check"
# => "projects/my-project/uptimeCheckConfigs/my-uptime-check"
name = client.uptime_check_config_path folder: "my-folder",
                                       uptime_check_config: "my-uptime-check"
# => "folders/my-folder/uptimeCheckConfigs/my-uptime-check"
```

Finally, in the 1.0 client, you can also use the paths module as a convenience module.

New:
```
# Bring the path helper methods into the current class
include Google::Cloud::Monitoring::V3::UptimeCheckService::Paths

def foo
  client = Google::Cloud::Monitoring.uptime_check_service

  # Call the included helper method
  name = uptime_check_config_path project: "my-project",
                                  uptime_check_config: "my-uptime-check"

  response = client.get_uptime_check_config name: name

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

The 1.0 client library now uses the `Google::Cloud::Error` exception hierarchy
for consistency across all the Google Cloud client libraries. In general, these
exceptions have the same name as their counterparts from older releases, but
are located in the `Google::Cloud` namespace rather than the `Google::Gax`
namespace.

Old:
```
client = Google::Cloud::Monitoring::Metric.new

name = "projects/my-project"

begin
  response = client.list_metric_descriptors name, page_size: 10
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New:
```
client = Google::Cloud::Monitoring.metric_service

name = "projects/my-project"

begin
  response = client.list_metric_descriptors name: name, page_size: 10
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```

### Class Namespaces

In older releases, some data type (protobuf) classes were located under the module
`Google::Monitoring`. In the 1.0 release, these classes have been moved into the
same `Google::Cloud::Monitoring` module by the client object, for consistency.

In older releases, the client object was of classes with names like:
`Google::Cloud::Monitoring::V3::MetricServiceClient`.
In the 1.0 release, the client object is of a different class:
`Google::Cloud::Monitoring::V3::MetricService::Client`.
Note that most users will use the factory methods such as
`Google::Cloud::Monitoring.metric_service` to create instances of the client object,
so you may not need to reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::Monitoring::V3::Credentials`.
In the 1.0 release, each service has its own credentials class, e.g.
`Google::Cloud::Monitoring::V3::MetricService::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).
