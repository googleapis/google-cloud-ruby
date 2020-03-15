## Migrating to google-cloud-dialogflow 1.0

The 1.0 release of the google-cloud-dialogflow client is a significant upgrade
based on a next-gen code generator. If you have used earlier versions of this
library, there have been a number of significant changes that may require
updates to calling code. This document will describe the changes that have been
made, and what you need to do to update your usage.

To summarize:

 *  The library has been broken out into two libraries. The new gem
    `google-cloud-dialogflow-v2` contains the actual client classes for version
    V2 of the Dialogflow service, and the gem `google-cloud-dialogflow` now
    simply provides a convenience wrapper. See
    [Library Structure](#library-structure) for more info.
 *  This library uses a new configuration mechanism giving you closer control
    over endpoint address, network timeouts, and retry. See
    [Client Configuration](#client-configuration) for more info. Furthermore,
    when creating a client object, you can customize its configuration in a
    block rather than passing arguments to the constructor. See
    [Creating Clients](#creating-clients) for more info.
 *  Previously, methods typically had at least one positional argument. Now,
    all arguments are keyword arguments. Additionally, you can pass a proto
    request object instead of separate arguments. See
    [Passing Arguments](#passing-arguments) for more info.
 *  Previously, some client classes included class methods for constructing
    resource paths. These paths are now instance methods, and are also
    available in a separate paths module. See
    [Resource Path Helpers](#resource-path-helpers) for more info.
 *  Some classes have moved into different namespaces. See
    [Class Namespaces](#class-namespaces) for more info.

### Library Structure

Older 0.x releases of the `google-cloud-dialogflow` gem were all-in-one gems that
included potentially multiple clients for multiple versions of the Dialogflow
service. Factory methods such as `Google::Cloud::Dialogflow::Agents.new()` would
return you client instances such as `Google::Cloud::Dialogflow::V2::AgentsClient`.
These classes were all defined in the same gem.

With the 1.0 release, the `google-cloud-dialogflow` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, on per service version. Currently,
Dialogflow has one version, V2. The
`Google::Cloud::Dialogflow::V2::Agents::Client` class, along with its
helpers and data types, are now part of the `google-cloud-dialogflow-v2` gem.

For normal usage, you can continue to install the `google-cloud-dialogflow` gem
and continue to use factory methods to create clients. This will remain the
easiest way to use the Dialogflow client. However, you may alternatively
choose to install only one of the versioned gems. For example, if you know you
will only use `V2` of the service, you can install `google-cloud-dialogflow-v2`
by itself, and construct instances of the
`Google::Cloud::Dialogflow::V2::Agents::Client` client class directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 1.0 release, a configuration interface provides access to these
parameters, both global defaults and per-client settings. For example, to set
global credentials and default timeout for all Dialogflow V2 sessions clients:

```
Google::Cloud::Dialogflow::V2::Sessions::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10_000
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `detect_intent` call:

```
Google::Cloud::Dialogflow::V2::Sessions::Client.configure do |config|
  config.rpcs.detect_intent.timeout = 20_000
end
```

You can also set certain configuration defaults for all Dialogflow versions and
services globally:

```
Google::Cloud::Dialogflow.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10_000
end
```

### Creating Clients

In older releases, to create a client object, you would use the `new` method
of modules under `Google::Cloud::Dialogflow`. For example, you might call
`Google::Cloud::Dialogflow::Agents.new`. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

Wiht the 1.0 release, use named class methods of `Google::Cloud::Dialogflow` to
create a client object. For example, `Google::Cloud::Dialogflow.sessions()`.
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

In older releases, certain required arguments would be passed as positional
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

options = Google::Gax::CallOptions.new timeout: 10_000

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
  timeout: 10_000
)
```

### Resource Path Helpers

The client library includes helper methods for the generating resource path
strings passed to many calls. These helpers have changed in two ways:

* In older releases, they are _class_ methods on the client class. In the 1.0
  release, they are _instance_ methods on the client. They are also available
  on a separate paths module that you can include elsewhere for convenience.
* In older releases, arguments to a resource path helper are passed as
  positional arguments. In the 1.0 release, they are passed as named keyword
  arguments. Some helpers also cover several related paths, with different sets
  of arguments. The class reference documentation provides details.

Here is example usage under older releases:
```
client = Google::Cloud::Dialogflow::Sessions.new

# Call the helper on the client class
session = Google::Cloud::Dialogflow::V2::SessionsClient.session_path(
  "my-project", "my-session"
)

query = { text: { text: "book a meeting room", language_code: "en-US" } }
response = client.detect_intent session, query
```

Here is the corresponding code in the 1.0 client:
```
client = Google::Cloud::Dialogflow.sessions

# Call the helper on the client instance
session = client.session_path project: "my-project", session: "my-session"

query = { text: { text: "book a meeting room", language_code: "en-US" } }
response = client.detect_intent session: session, query_input: query
```

An alternative usage of the 1.0 client involving including the paths module:
```
# Bring the session_path method into the current class
include Google::Cloud::Dialogflow::V2::Sessions::Paths

def foo
  client = Google::Cloud::Dialogflow.sessions

  # Call the included helper method
  session = session_path project: "my-project", session: "my-session"

  query = { text: { text: "book a meeting room", language_code: "en-US" } }
  response = client.detect_intent session: session, query_input: query
  # Do something with response
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

In older releases, the credentials object was of class
`Google::Cloud::Dialogflow::V2::Credentials`.
In the 1.0 release, each service has its own credentials class, e.g.
`Google::Cloud::Dialogflow::V2::Agents::Credentials`.
Again, most users will not need to reference this class directly.
