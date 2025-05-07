## Migrating to google-cloud-resource_manager 1.0

The 1.0 release of the google-cloud-resource_manager client is a significant
upgrade to add a number of new features in version V3 of the resource manager
service, and to bring the client interfaces and technology up to date with the
rest of Google's modern API clients. As part of this processs, substantial
interface changes were made, so existing code written for earlier versions of
this library will likely require updates to use this version. This document
describes the changes that have been made, and what you need to do to update
your usage.

To summarize:

 *  The client has been rewritten to use the new high-performance gRPC endpoint
    for the new version V3 of the service. (Earlier client versions used the
    HTTP/REST endpoint for version V1 of the service.)
 *  The library has been broken out into two libraries. The new gem
    `google-cloud-resource_manager-v3` contains the actual client classes for
    version V3 of the Resource Manager service, and  the gem
    `google-cloud-resource_manager` now simply provides a convenience wrapper.
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
 *  Nearly all classes have been redesigned and have different names. See
    [Class Design](#class-design) for more info.

### Library Structure

Older 0.x releases of the `google-cloud-resource_manager` gem provided the
entire client interface in one gem. This included major data types, and client
objects with methods for the various calls. These classes were in turn powered
by the `google-apis-cloudresourcemanager_v1` gem which handled lower-level REST
calls.

With the 1.0 release, the `google-cloud-resource_manager` gem itself provides
factory methods for obtaining client objects, but the client classes and data
types themselves are defined in a separate gem
`google-cloud-resource_manager-v3`. Normally, your app can continue to install
`google-cloud-resource_manager`, which will bring in the lower-level
`google-cloud-resource_manager-v3` gem as a dependency. It is also possible for
to install only `google-cloud-resource_manager-v3` if you know you will use
only V3 of the service.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 1.0 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all Resource Manager V3 projects clients:

```
Google::Cloud::ResourceManager::V3::Projects::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `list_projects` call:

```
Google::Cloud::ResourceManager::V3::Projects::Client.configure do |config|
  config.rpcs.list_projects.timeout = 20.0
end
```

Defaults for certain configurations can be set for all ResourceManager versions
globally:

```
Google::Cloud::ResourceManager.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the
`Google::Cloud::ResourceManager.new` class method. Keyword arguments were
available to configure parameters such as credentials and timeouts.

With the 1.0 release, use named class methods of
`Google::Cloud::ResourceManager` to create a client object. For example, use
`Google::Cloud::ResourceManager.projects` to create a client for
projects-related RPCs. You may select a service version using the `:version`
keyword argument. However, other configuration parameters should be set in a
configuration block when you create the client.

Old:
```
client = Google::Cloud::ResourceManager.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::ResourceManager.projects do |config|
  config.credentials = "/path/to/credentials.json"
end
```

The configuration block is optional. If you do not provide it, or you do not
set some configuration parameters, then the default configuration is used. See
[Client Configuration](#client-configuration).

### Passing Arguments

In older releases, required arguments would be passed as positional method
arguments, while most optional arguments would be passed as keyword arguments.

With the 1.0 release, all RPC arguments are passed as keyword arguments,
regardless of whether they are required or optional. Additionally, the
structure of some arguments may have changed: many arguments that were
previously "flattened" are now provided in the form of data structures, usually
the same data structures returned as responses. For example:

Old:
```
client = Google::Cloud::ResourceManager.new

# The project ID is a positional argument by itself, and optional arguments
# are separate keyword arguments.
response = client.create_project "my-project", name: "My great project"
```

New:
```
client = Google::Cloud::ResourceManager.projects

# Create a project data structure and pass it as a keyword argument.
project = {
  project_id: "my-project",
  name: "My great project"
}

response = client.create_project project: project
```

Additionally, in older releases, it was often difficult or impossible to
provide per-call options such as timeouts. In the 1.0 release, you can now
pass call options using a _second set_ of keyword arguments.

New:
```
client = Google::Cloud::ResourceManager.projects

project = {
  project_id: "my-project",
  name: "My great project"
}

# Use a hash to wrap the normal call arguments, and
# then add further keyword arguments for the call options.
response = client.create_project({ project: project }, timeout: 10.0)
```

### Class Design

In older releases, the main client object was of type
`Google::Cloud::ResourceManager::Project`, and included methods covering all
functionality for version V1 of the Resource Manager. In the 1.0 release,
several different client objects are provided, covering the various parts of
the expanded Resource Manager V3 functionality. These client classes include
`Google::Cloud::ResourceManager::V3::Projects::Client`,
`Google::Cloud::ResourceManager::V3::Projects::Organizations`,
`Google::Cloud::ResourceManager::V3::Projects::Folders`, and others. You can
construct instances of these classes using the provided class methods on the
`Google::Cloud::ResourceManager` module.

In older releases, certain data types were represented by Ruby classes under
the `Google::Cloud::ResourceManager` namespace, including
`Google::Cloud::ResourceMnaager::Policy` and
`Google::Cloud::ResourceManager::Resource`. The functionality in these data
types was extremely limited. In the 1.0 release, you will use protocol buffer
message types for all resources, such as
`Google::Cloud::ResourceManager::V3::Project` and
`Google::Cloud::ResourceManager::V3::Organization`.
