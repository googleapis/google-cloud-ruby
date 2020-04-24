## Migrating to google-cloud-bigquery-data_transfer 1.0

The 1.0 release of the google-cloud-bigquery-data_transfer client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into multiple libraries. The new gem
    `google-cloud-bigquery-data_transfer-v1` contains the
    actual client classes for version V1 of the BigQuery DataTransfer service,
    and the gem `google-cloud-bigquery-data_transfer` now simply provides a convenience wrapper.
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
 *  Some classes have moved into different namespaces. See
    [Class Namespaces](#class-namespaces) for more info.

### Library Structure

Older 0.x releases of the `google-cloud-bigquery-data_transfer` gem were all-in-one gems
that included potentially multiple clients for multiple versions of the BigQuery
DataTransfer service. The `Google::Cloud::Bigquery::DataTransfer.new` factory method would
return you an instance of a `Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient`
object for the V1 version of the service. All these classes were defined in the same gem.

With the 1.0 release, the `google-cloud-bigquery-data_transfer` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. The
`Google::Cloud::Bigquery::DataTransfer::V1::DataTransferService::Client` class, along with its
helpers and data types, is now part of the `google-cloud-bigquery-data_transfer-v1` gem.
Future versions will similarly be located in additional gems.

For normal usage, you can continue to install the `google-cloud-bigquery-data_transfer` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will only
use `V1` of the service, you can install `google-cloud-bigquery-data_transfer-v1` by
itself, and construct instances of the
`Google::Cloud::Bigquery::DataTransfer::V1::DataTransferService::Client` client class directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 1.0 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all BigQuery DataTransfer V1 clients:

```
Google::Cloud::Bigquery::DataTransfer::V1::DataTransferService::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `get_data_source` call:

```
Google::Cloud::Bigquery::DataTransfer::V1::DataTransferService::Client.configure do |config|
  config.rpcs.get_data_source.timeout = 20.0
end
```

Defaults for certain configurations can be set for all BigQuery DataTransfer versions and
services globally:

```
Google::Cloud::Bigquery::DataTransfer.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the
`Google::Cloud::Bigquery::DataTransfer.new` class method. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

With the 1.0 release, use the `Google::Cloud::Bigquery::DataTransfer.data_transfer_service` class
method to create a client object. You may select a service version using the
`:version` keyword argument. (Currently `:v1` is the only supported version.)
However, other configuration parameters should be set in a configuration block when you create the client.

Old:
```
client = Google::Cloud::Bigquery::DataTransfer.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::Bigquery::DataTransfer.data_transfer_service do |config|
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
regardless of whether they are required or optional. For example:

Old:
```
client = Google::Cloud::Bigquery::DataTransfer.new

name = "projects/my-project/dataSources/my-source"

# Name is a positional argument
response = client.get_data_source name
```

New:
```
client = Google::Cloud::Bigquery::DataTransfer.data_transfer_service

name = "projects/my-project/dataSources/my-source"

# Name is a keyword argument
response = client.get_data_source name: name
```

In the 1.0 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::Bigquery::DataTransfer.data_transfer_service

request = Google::Cloud::Bigquery::DataTransfer::V1::GetDataSourceRequest.new(
  name: "projects/my-project/dataSources/my-source"
)

# Pass a request object as a positional argument:
response = client.get_data_source request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
1.0 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::Bigquery::DataTransfer.new

name = "projects/my-project/dataSources/my-source"

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.get_data_source name, options: options
```

New:
```
client = Google::Cloud::Bigquery::DataTransfer.data_transfer_service

name = "projects/my-project/dataSources/my-source"

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.get_data_source({ name: name }, timeout: 10.0)
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
client = Google::Cloud::Bigquery::DataTransfer.new

# Call the helper on the client class
name = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.data_source_path(
  "my-project", "my-source"
)

response = client.get_data_source name
```

New:
```
client = Google::Cloud::Bigquery::DataTransfer.data_transfer_service

# Call the helper on the client instance, and use keyword arguments
name = client.data_source_path project: "my-project", data_source: "my-source"

response = client.get_data_source name: name
```

Because IDs are passed as keyword arguments, some closely related paths
have been combined. For example, `data_source_path` and `location_data_source_path`
used to be separate helpers, one that took a location argument and one that did not.
In the 1.0 client, use `data_source_path` for both cases, and either pass or
omit the `location:` keyword argument.

Old:
```
name1 = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.data_source_path(
  "my-project", "my-source"
)
name2 = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.location_data_source_path(
  "my-project", "my-location", "my-source"
)
```

New:
```
client = Google::Cloud::Dlp.dlp_service
name1 = client.data_source_path project: "my-project",
                                data_source: "my-source"
name2 = client.data_source_path project: "my-project",
                                location: "my-location",
                                data_source: "my-source"
```

Finally, in the 1.0 client, you can also use the paths module as a convenience module.

New:
```
# Bring the data_source_path method into the current class
include Google::Cloud::Bigquery::DataTransfer::V1::DataTransferService::Paths

def foo
  client = Google::Cloud::Bigquery::DataTransfer.data_transfer_service

  # Call the included helper method
  name = data_source_path project: "my-project", data_source: "my-source"

  response = client.get_data_source name: name

  # Do something with response...
end
```

### Class Namespaces

In older releases, data type classes were generally located under the module
`Google::Cloud::Bigquery::Datatransfer::V1`. (Note the lower-case "t" in
"Datatransfer".) In the 1.0 release, these classes have been moved into the
same `Google::Cloud::Bigquery::DataTransfer::V1` (upper-case "T") module used
by the client object, for consistency.

In older releases, the client object was of classes with names like:
`Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient`.
In the 1.0 release, the client object is of a different class:
`Google::Cloud::Bigquery::DataTransfer::V1::DataTransferService::Client`.
Note that most users will use the factory methods such as
`Google::Cloud::Bigquery::DataTransfer.data_transfer_service` to create instances of the client object,
so you may not need to reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::Bigquery::DataTransfer::V1::Credentials`.
In the 1.0 release, each service has its own credentials class, e.g.
`Google::Cloud::Bigquery::DataTransfer::V1::DataTransferService::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).
