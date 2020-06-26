## Migrating to google-cloud-dialogflow 1.0

The 1.0 release of the google-cloud-dialogflow client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into two libraries. The new gem
    `google-cloud-dialogflow-v2` contains the actual client classes for version
    V2 of the Dialogflow service, and the gem `google-cloud-dialogflow` now
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
 *  Previously, the client included a method supporting bidirectional streaming
    recognition requests, both incremental audio and incremental results. The
    current client retains this method, but improves it with a more powerful
    interface to match streaming methods in other Ruby clients. See
    [Streaming Interface](#streaming-interface) for more info.
 *  Previously, clients reported RPC errors by raising instances of
    `Google::Gax::GaxError` and its subclasses. Now, RPC exceptions are of type
    `Google::Cloud::Error` and its subclasses. See
    [Handling Errors](#handling-errors) for more info.
 *  Some classes have moved into different namespaces. See
    [Class Namespaces](#class-namespaces) for more info.

### Library Structure

Older 0.x releases of the `google-cloud-dialogflow` gem were all-in-one gems
that included potentially multiple clients for multiple versions of the
Dialogflow service. Factory methods such as `Google::Cloud::Dialogflow::Agents.new`
would return you instances of client classes such as
`Google::Cloud::Dialogflow::V2::AgentsClient`. These classes were all defined
in the same gem.

With the 1.0 release, the `google-cloud-dialogflow` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. Currently,
Dialogflow has one version, V2. The
`Google::Cloud::Dialogflow::V2::Agents::Client` class, along with its
helpers and data types, is now part of the `google-cloud-dialogflow-v2` gem.

For normal usage, you can continue to install the `google-cloud-dialogflow` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will only
use `V2` of the service, you can install `google-cloud-dialogflow-v2` by
itself, and construct instances of the
`Google::Cloud::Dialogflow::V2::Agents::Client` client class directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 1.0 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all Dialogflow V2 sessions clients:

```
Google::Cloud::Dialogflow::V2::Sessions::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `detect_intent` call:

```
Google::Cloud::Dialogflow::V2::Sessions::Client.configure do |config|
  config.rpcs.detect_intent.timeout = 20.0
end
```

Defaults for certain configurations can be set for all Dialogflow versions and
services globally:

```
Google::Cloud::Dialogflow.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the `new` method
of modules under `Google::Cloud::Dialogflow`. For example, you might call
`Google::Cloud::Dialogflow::Agents.new`. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

With the 1.0 release, use named class methods of `Google::Cloud::Dialogflow` to
create a client object. For example, `Google::Cloud::Dialogflow.sessions`.
You may select a service version using the `:version` keyword argument.
However, other configuration parameters should be set in a configuration block
when you create the client.

Old:
```
client = Google::Cloud::Dialogflow::Agents.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::Dialogflow.agents do |config|
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
client = Google::Cloud::Dialogflow::Sessions.new

session = "projects/my-project/agent/sessions/my-session"
query = { text: { text: "book a meeting room", language_code: "en-US" } }

# Session and query are positional arguments
response = client.detect_intent session, query
```

New:
```
client = Google::Cloud::Dialogflow.sessions

session = "projects/my-project/agent/sessions/my-session"
query = { text: { text: "book a meeting room", language_code: "en-US" } }

# Session and query are keyword arguments
response = client.detect_intent session: session, query_input: query
```

In the 1.0 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::Dialogflow.sessions

request = Google::Cloud::Dialogflow::V2::DetectIntentRequest.new(
  session: "projects/my-project/agent/sessions/my-session",
  query_input: {
    text: {
      text: "book a meeting room",
      language_code: "en-US"
    }
  }
)

# Pass a request object as a positional argument:
response = client.detect_intent request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
1.0 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::Dialogflow::Sessions.new

session = "projects/my-project/agent/sessions/my-session"
query = { text: { text: "book a meeting room", language_code: "en-US" } }

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.detect_intent session, query, options: options
```

New:
```
client = Google::Cloud::Dialogflow.sessions

session = "projects/my-project/agent/sessions/my-session"
query = { text: { text: "book a meeting room", language_code: "en-US" } }

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.detect_intent(
  { session: session, query_input: query },
  timeout: 10.0
)
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
client = Google::Cloud::Dialogflow::Sessions.new

# Call the helper on the client class
session = Google::Cloud::Dialogflow::V2::SessionsClient.session_path(
  "my-project", "my-session"
)

query = { text: { text: "book a meeting room", language_code: "en-US" } }
response = client.detect_intent session, query
```

New:
```
client = Google::Cloud::Dialogflow.sessions

# Call the helper on the client instance, and use keyword arguments
session = client.session_path project: "my-project", session: "my-session"

query = { text: { text: "book a meeting room", language_code: "en-US" } }
response = client.detect_intent session: session, query_input: query
```

Because helpers take keyword arguments, some can now generate several different
variations on the path that were not available under earlier versions of the
library. For example, `session_path` can generate paths with the `environment`
and `user` sections omitted or present.

New:
```
client = Google::Cloud::Dialogflow.sessions
# Create paths with different parent resource types
name1 = client.session_path project: "my-project", session: "my-session"
# => "projects/my-project/agent/sessions/my-session"
name2 = client.session_path project: "my-project", session: "my-session",
                            environment: "my-env", user: "my-user"
# => "projects/my-project/agent/environments/my-env/user/my-user/session/my-session"
```

Finally, in the 1.0 client, you can also use the paths module as a convenience module.

New:
```
# Bring the path helper methods into the current class
include Google::Cloud::Dialogflow::V2::Sessions::Paths

def foo
  client = Google::Cloud::Dialogflow.sessions

  # Call the included helper method
  session = session_path project: "my-project", session: "my-session"

  query = { text: { text: "book a meeting room", language_code: "en-US" } }
  response = client.detect_intent session: session, query_input: query

  # Do something with response...
end
```

### Streaming Interface

The client library includes one special streaming method `streaming_detect_intent`.
In the older client, this method provided only a very basic Enumerable-based
interface, and required you to write wrappers if you wanted more flexibility.
In version 1.0, we have standardized the streaming interfaces across the various
Ruby client libraries. The `streaming_detect_intent` call takes an input stream
object that can be written to incrementally, and returns a lazy enumerable that
you can query for incremental results.

Old:
```
client = Google::Cloud::Dialogflow::Sessions.new

# Build requests
session = "projects/my-project/agent/sessions/my-session"
header = {
  session: session,
  query_input: {
    audio_config: {
      audio_encoding: Google::Cloud:Dialogflow::V2::AudioEncoding::AUDIO_ENCODING_FLAC,
      sample_rate_hertz: 44_000,
      language_code: "en-US
    }
  }
}
data1 = {
  session: session,
  input_audio: File.read("data1.flac", mode: "rb")
}
data2 = {
  session: session,
  input_audio: File.read("data2.flac", mode: "rb")
}

# Issue the call
responses = client.streaming_detect_intent [header, data1, data2]

# Handle responses as they arrive
responses.each do |response|
  puts "received: #{response}"
end
```

New:
```
client = Google::Cloud::Dialogflow.sessions

# Create a request stream, initiate the call, and get a response stream.
request_stream = Gapic::StreamInput.new
response_stream = client.streaming_detect_intent request_stream

# You can now interact with both streams, even concurrently.
# For example, you can handle responses in a background thread.
response_thread = Thread.new
  response_stream.each do |response|
    puts "received: #{response}"
  end
end

# Send requests on the stream
session = "projects/my-project/agent/sessions/my-session"
request_stream << {
  session: session,
  query_input: {
    audio_config: {
      audio_encoding: Google::Cloud:Dialogflow::V2::AudioEncoding::AUDIO_ENCODING_FLAC,
      sample_rate_hertz: 44_000,
      language_code: "en-US
    }
  }
}
request_stream << {
  session: session,
  input_audio: File.read("data1.flac", mode: "rb")
}
request_stream << {
  session: session,
  input_audio: File.read("data2.flac", mode: "rb")
}

# Close the request stream when finished.
request_stream.close

# Wait for the response handling to finish
response_thread.join
```

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
client = Google::Cloud::Dialogflow::Sessions.new

session = "projects/my-project/agent/sessions/my-session"
query = { text: { text: "book a meeting room", language_code: "en-US" } }

begin
  response = client.detect_intent session, query
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New:
```
client = Google::Cloud::Dialogflow.sessions

session = "projects/my-project/agent/sessions/my-session"
query = { text: { text: "book a meeting room", language_code: "en-US" } }

begin
  response = client.detect_intent session: session, query_input: query
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```

### Class Namespaces

In older releases, the client object was of classes with names like:
`Google::Cloud::Dialogflow::V2::AgentsClient`.
In the 1.0 release, the client object is of a different class:
`Google::Cloud::Dialogflow::V2::Agents::Client`.
Note that most users will use the factory methods such as
`Google::Cloud::Dialogflow.agents` to create instances of the client object,
so you may not need to reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::Dialogflow::V2::Credentials`.
In the 1.0 release, each service has its own credentials class, e.g.
`Google::Cloud::Dialogflow::V2::Agents::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).
