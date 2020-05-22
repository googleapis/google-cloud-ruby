## Migrating to google-cloud-vision 1.0

The 1.0 release of the google-cloud-vision client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into multiple libraries. The new gems
    `google-cloud-vision-v1` and `google-cloud-vision-v1p3beta1` contain the
    actual client classes for versions V1 and V1p3beta1 of the Vision service,
    and the gem `google-cloud-vision` now simply provides a convenience wrapper.
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
 *  Previously, the client included a number of high-level convenience methods,
    such as `face_detection`, for detecting particular types of features. These
    methods are still present, but a few of the parameter types (relating to
    call configuration) have changed. See
    [High Level Detection Methods](#high-level-detection-methods) for more info.
 *  Previously, clients reported RPC errors by raising instances of
    `Google::Gax::GaxError` and its subclasses. Now, RPC exceptions are of type
    `Google::Cloud::Error` and its subclasses. See
    [Handling Errors](#handling-errors) for more info.
 *  Some classes have moved into different namespaces. See
    [Class Namespaces](#class-namespaces) for more info.

### Library Structure

Older 0.x releases of the `google-cloud-vision` gem were all-in-one gems
that included potentially multiple clients for multiple versions of the Vision
service. Factory methods such as `Google::Cloud::Vision::ImageAnnotator.new`
would return you instances of client classes such as
`Google::Cloud::Vision::V1::ImageAnnotatorClient` or
`Google::Cloud::Vision::V1p3beta1::ImageAnnotatorClient`, depending on which
version of the API requested. These classes were all defined in the same gem.

With the 1.0 release, the `google-cloud-vision` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. The
`Google::Cloud::Vision::V1::ImageAnnotator::Client` class, along with its
helpers and data types, is now part of the `google-cloud-vision-v1` gem.
Similarly, the `Google::Cloud::Vision::V1p3beta1::ImageAnnotator::Client`
class is part of the `google-cloud-vision-v1p3beta1` gem.

For normal usage, you can continue to install the `google-cloud-vision` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will only
use `V1` of the service, you can install `google-cloud-vision-v1` by
itself, and construct instances of the
`Google::Cloud::Vision::V1::ImageAnnotator::Client` client class directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 1.0 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all Vision V1 image annotator clients:

```
Google::Cloud::Vision::V1::ImageAnnotator::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `batch_annotate_images` call:

```
Google::Cloud::Vision::V1::ImageAnnotator::Client.configure do |config|
  config.rpcs.batch_annotate_images.timeout = 20.0
end
```

Defaults for certain configurations can be set for all Vision versions and
services globally:

```
Google::Cloud::Vision.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the `new` method
of modules under `Google::Cloud::Vision`. For example, you might call
`Google::Cloud::Vision::ImageAnnotator.new`. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

With the 1.0 release, use named class methods of `Google::Cloud::Vision` to
create a client object. For example, `Google::Cloud::Vision.image_annotator`.
You may select a service version using the `:version` keyword argument.
However, other configuration parameters should be set in a configuration block
when you create the client.

Old:
```
client = Google::Cloud::Vision::ImageAnnotator.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::Vision.image_annotator do |config|
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
client = Google::Cloud::Vision::ImageAnnotator.new

requests = my_create_requests

# requests is a positional argument
response = client.batch_annotate_images requests
```

New:
```
client = Google::Cloud::Vision.image_annotator

requests = my_create_requests

# requests is a keyword argument
response = client.batch_annotate_images requests: requests
```

In the 1.0 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::Vision.image_annotator

request_object = Google::Cloud::Vision::V1::BatchAnnotateImagesRequest.new(
  requests: my_create_requests
)

# Pass a request object as a positional argument:
response = client.batch_annotate_images request_object
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
1.0 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::Vision::ImageAnnotator.new

requests = my_create_requests

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.batch_annotate_images requests, options: options
```

New:
```
client = Google::Cloud::Vision.image_annotator

requests = my_create_requests

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.batch_annotate_images({ requests: requests }, timeout: 10.0)
```

### Resource Path Helpers

The client library includes helper methods for generating the resource path
strings passed to many calls. These helpers have changed in two ways:

* In older releases, they are _class_ methods on the client class. In the 1.0
  release, they are _instance_ methods on the client. They are also available
  on a separate paths module that you can include elsewhere for convenience.
* In older releases, arguments to a resource path helper are passed as
  _positional_ arguments. In the 1.0 release, they are passed as named _keyword_
  arguments.

Following is an example involving using a resource path helper.

Old:
```
client = Google::Cloud::Vision::ProductSearch.new

# Call the helper on the client class
location = Google::Cloud::Vision::V1::ProductSearchClient.location_path(
  "my-project", "my-location"
)

product = my_build_product
response = client.create_product location, product
```

New:
```
client = Google::Cloud::Vision.product_search

# Call the helper on the client instance, and use keyword arguments
location = client.location_path project: "my-project", location: "my-location"

product = my_build_product
response = client.create_product parent: location, product: product
```

In the 1.0 client, you can also use the paths module as a convenience module.

New:
```
# Bring the path helper methods into the current class
include Google::Cloud::Vision::V1::ProductSearch::Paths

def foo
  client = Google::Cloud::Vision.product_search

  # Call the included helper method
  location = location_path project: "my-project", location: "my-location"

  product = my_build_product
  response = client.create_product parent: location, product: product

  # Do something with response...
end
```

### High Level Detection Methods

The client library includes some high-level convenience methods, with names
such as `face_detection`, for detecting certain types of features. These
methods are still present, but a few of the argument types have changed.

 *  The `options` keyword argument is used to pass call options such as timeout
    and retry. Older versions of the library took an object of type
    `Google::Gax::CallOptions`. Version 1.0 takes an object of type
    `Gapic::CallOptions`, which is defined in the `gapic-common` gem. Note that
    you can also pass a hash with the same keys that the older library accepted.
 *  If `async` is set to `true`, older versions of the library returned an
    object of type `Google::Gax::Operation`. Version 1.0 returns an object of
    type `Gapic::Operation`, which is defined in the `gapic-common` gem. Most
    methods on this object are the same as the older object.

### Handling Errors

The client reports standard
[gRPC error codes](https://github.com/grpc/grpc/blob/master/doc/statuscodes.md)
by raising exceptions. In older releases, these exceptions were located in the
`Google::Gax` namespace and were subclasses of the `Google::Gax::GaxError` base
exception class, defined in the `google-gax` gem. However, these classes were
different from the standard exceptions (subclasses of `Google::Cloud::Error`)
thrown by other client libraries such as `google-cloud-storage`.

The 1.0 client library now uses the `Google::Cloud::Error` exception hierarchy,
for consistency across all the Google Cloud client libraries. In general, these
exceptions have the same name as their counterparts from older releases, but
are located in the `Google::Cloud` namespace rather than the `Google::Gax`
namespace.

Old:
```
client = Google::Cloud::Vision::ImageAnnotator.new

requests = my_create_requests

begin
  response = client.batch_annotate_images requests
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New:
```
client = Google::Cloud::Vision.image_annotator

requests = my_create_requests

begin
  response = client.batch_annotate_images requests: requests
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```

### Class Namespaces

In older releases, the client object was of classes with names like:
`Google::Cloud::Vision::V1::ProductSearchClient`.
In the 1.0 release, the client object is of a different class:
`Google::Cloud::Vision::V1::ProductSearch::Client`.
Note that most users will use the factory methods such as
`Google::Cloud::Vision.product_search` to create instances of the client object,
so you may not need to reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::Vision::V1::Credentials`.
In the 1.0 release, each service has its own credentials class, e.g.
`Google::Cloud::Vision::V1::ProductSearch::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).
