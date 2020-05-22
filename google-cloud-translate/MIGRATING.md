## Migrating to google-cloud-translate 3.0

The 3.0 release of the google-cloud-translate client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into three libraries. The new gems
    `google-cloud-translate-v2` and `google-cloud-translate-v3` contain the
    actual client classes for versions V2 and V3 of the Translation
    service, and the gem `google-cloud-translate` now simply provides a
    convenience wrapper. See [Library Structure](#library-structure) for more
    info.
 *  When creating V3 client objects, you customize the configuration in a block
    instead of passing arguments to the constructor. See
    [Creating Clients](#creating-clients) for more info. When creating V2
    clients, however, pass settings arguments as before.
 *  Previously, positional arguments were used to indicate required arguments.
    Now, in the V3 client, all method arguments are keyword arguments, with
    documentation that specifies whether they are required or optional.
    Additionally, you can pass a proto request object instead of separate
    arguments. See [Passing Arguments](#passing-arguments) for more info. V2
    client methods, however, remain unchanged.
 *  Previously, some V3 client classes included class methods for constructing
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

Older releases of the `google-cloud-translate` gem were all-in-one gems that
included potentially multiple clients for multiple versions of the Translation
service. The `Google::Cloud::Translate.new` factory method would
return you an instance of a `Google::Cloud::Translate::V2::Api`
object for the V2 version of the service, or a
`Google::Cloud::Translate::V3::TranslationServiceClient` object for the
V3 version of the service. All these classes were defined in the same gem.

With the 3.0 release, the `google-cloud-translate` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. The
`Google::Cloud::Translate::V2::Api` class, along with its
helpers and data types, is now part of the `google-cloud-translate-v2` gem.
Similarly, the `Google::Cloud::Translate::V3::TranslationService::Client`
class is part of the `google-cloud-translate-v3` gem. 

For normal usage, you can continue to install the `google-cloud-translate` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will use only
`V2` of the service, you can install `google-cloud-translate-v2` by itself, and
call `Google::Cloud::Translate::V2.new` to create V2 clients directly.

### Creating Clients

In older releases, to create a client object, you would use the
`Google::Cloud::Translate.new` class method. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts. Furthermore, you could configure default parameters using the
`Google::Cloud::Translate.configure` method.

In the 3.0 release, there are separate class methods for creating clients of the
modern (V3) and legacy (V2) Translation services. To create a V2 client, use the
`translation_v2_service` class method, which takes the same keyword arguments
you would have used previously. To create a V3 (or later) client, use the
`translation_service` class method and set options in a configuration block.

Old (V3):
```
client = Google::Cloud::Translate.new credentials: "/path/to/credentials.json"
```

Old (V2):
```
client = Google::Cloud::Translate.new version: :v2,
                                      credentials: "/path/to/credentials.json"
```

New (V3):
```
# Call the translation_service method to create a V3 client,
# and pass a block to configure the client.
client = Google::Cloud::Translate.translation_service do |config|
  config.credentials = "/path/to/credentials.json"
end

# You can omit the block if you're keeping the default configuration
default_client = Google::Cloud::Translate.translation_service
```

New (V2):
```
# Call the separate translation_v2_service method to create a legacy V2 client,
# and pass configuration as keyword arguments.
client = Google::Cloud::Translate.translation_v2_service(
  credentials: "/path/to/credentials.json")
```

### Passing Arguments

In older releases, required arguments would be passed as positional method
arguments, while most optional arguments would be passed as keyword arguments.

With the 3.0 release, the V2 client interface remains the same, but in the V3
client interface, all RPC arguments are passed as keyword arguments, regardless
of whether they are required or optional. For example:

Old (V3):
```
client = Google::Cloud::Translate.new

# Contents, target language, and project are positional arguments, but
# mime type is a keyword argument
response = client.translate_text ["Hello, world!"], "es", "my-project",
                                 mime_type: "text/plain"
```

New (V3):
```
client = Google::Cloud::Translate.translation_service

# All arguments are keyword arguments
response = client.translate_text content: ["Hello, world!"],
                                 target_language_code: "es",
                                 parent: "my-project",
                                 mime_type: "text/plain"
```

In the 3.0 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New (V3):
```
client = Google::Cloud::Translate.translation_service

request = Google::Cloud::Translate::V3::TranslateTextRequest.new(
  content: ["Hello, world!"],
  target_language_code: "es",
  parent: "my-project",
  mime_type: "text/plain"
)

# Pass a request object as a positional argument:
response = client.translate_text request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
3.0 release, pass call options using a _second set_ of keyword arguments.

Old (V3):
```
client = Google::Cloud::Translate.new

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.translate_text ["Hello, world!"], "es", "my-project",
                                 mime_type: "text/plain",
                                 options: options
```

New (V3):
```
client = Google::Cloud::Translate.translation_service

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.translate_text(
  { content: ["Hello, world!"], target_language_code: "es",
    parent: "my-project", mime_type: "text/plain" },
  timeout: 10.0
)
```

### Resource Path Helpers

The client library for the V3 service includes helper methods for generating
the resource path strings passed to many calls. These helpers have changed in
two ways:

* In older releases, they are _class_ methods on the client class. In the 1.0
  release, they are _instance_ methods on the client. They are also available
  on a separate paths module that you can include elsewhere for convenience.
* In older releases, arguments to a resource path helper are passed as
  _positional_ arguments. In the 3.0 release, they are passed as named _keyword_
  arguments.

Following is an example involving using a resource path helper.

Old (V3):
```
client = Google::Cloud::Translate.new

# Call the helper on the client class
name = Google::Cloud::Translate::V3::TranslationServiceClient.glossary_path(
  "my-project", "my-location", "my-glossary"
)

response = client.get_glossary name
```

New (V3):
```
client = Google::Cloud::Translate.translation_service

# Call the helper on the client instance, and use keyword arguments
name = client.glossary_path project: "my-project", location: "my-location",
                            glossary: "my-glossary"

response = client.get_glossary name: name
```

In the 3.0 client, you can also use the paths module as a convenience module.

New (V3):
```
# Bring the path methods into the current class
include Google::Cloud::Translate::V3::TranslationService::Paths

def foo
  client = Google::Cloud::Translate.translation_service

  # Call the included helper method
  name = glossary_path project: "my-project", location: "my-location",
                       glossary: "my-glossary"

  response = client.get_glossary name: name

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

The 3.0 client library now uses the `Google::Cloud::Error` exception hierarchy,
for consistency across all the Google Cloud client libraries. In general, these
exceptions have the same name as their counterparts from older releases, but
are located in the `Google::Cloud` namespace rather than the `Google::Gax`
namespace.

Old (V3):
```
client = Google::Cloud::Translate.new

begin
  response = client.translate_text ["Hello, world!"], "es", "my-project",
                                   mime_type: "text/plain"
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New (V3):
```
client = Google::Cloud::Translate.translation_service

begin
  response = client.translate_text content: ["Hello, world!"],
                                  target_language_code: "es",
                                  parent: "my-project",
                                  mime_type: "text/plain"
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```

### Class Namespaces

In older releases, the client object for V3 was of class
`Google::Cloud::Translate::V3::TranslationServiceClient`.
In the 3.0 release, the client object is of class
`Google::Cloud::Translate::V3::TranslationService::Client`.
Note that most users will use the `Google::Cloud::Translate.translation_service`
factory method to create instances of the client object, so you may not need to
reference the actual class directly. See [Creating Clients](#creating-clients).

In older releases, the V3 credentials object was of class
`Google::Cloud::Translate::V3::Credentials`.
In the 3.0 release, the credentials object is of class
`Google::Cloud::Translate::V3::TranslationService::Credentials`.
Again, most users will not need to reference this class directly.

The V2 classes have not been renamed.
