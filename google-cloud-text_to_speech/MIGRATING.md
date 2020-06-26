## Migrating to google-cloud-text_to_speech 1.0

The 1.0 release of the google-cloud-text_to_speech client is a significant upgrade
based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
and includes substantial interface changes. Existing code written for earlier
versions of this library will likely require updates to use this version.
This document describes the changes that have been made, and what you need to
do to update your usage.

To summarize:

 *  The library has been broken out into three libraries. The new gems
    `google-cloud-text_to_speech-v1` and `google-cloud-text_to_speech-v1beta1` contain the
    actual client classes for versions V1 and V1beta1 of the Text To Speech
    service, and the gem `google-cloud-text_to_speech` now simply provides a
    convenience wrapper. See [Library Structure](#library-structure) for more
    info.
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
 *  Some classes have moved into different namespaces. See
    [Class Namespaces](#class-namespaces) for more info.

### Library Structure

Older 0.x releases of the `google-cloud-text_to_speech` gem were all-in-one gems that
included potentially multiple clients for multiple versions of the Text To
Speech service. The `Google::Cloud::TextToSpeech.new` factory method would
return you an instance of a `Google::Cloud::TextToSpeech::V1::TextToSpeechClient`
object for the V1 version of the service, or a
`Google::Cloud::TextToSpeech::V1beta1::TextToSpeechClient` object for the
V1beta1 version of the service. All these classes were defined in the same gem.

With the 1.0 release, the `google-cloud-text_to_speech` gem still provides factory
methods for obtaining clients. (The method signatures will have changed. See
[Creating Clients](#creating-clients) for details.) However, the actual client
classes have been moved into separate gems, one per service version. The
`Google::Cloud::TextToSpeech::V1::TextToSpeech::Client` class, along with its
helpers and data types, is now part of the `google-cloud-text_to_speech-v1` gem.
Similarly, the `Google::Cloud::TextToSpeech::V1beta1::TextToSpeech::Client`
class is part of the `google-cloud-text_to_speech-v1beta1` gem. 

For normal usage, you can continue to install the `google-cloud-text_to_speech` gem
(which will bring in the versioned client gems as dependencies) and continue to
use factory methods to create clients. However, you may alternatively choose to
install only one of the versioned gems. For example, if you know you will use only
`V1` of the service, you can install `google-cloud-text_to_speech-v1` by itself, and
construct instances of the
`Google::Cloud::TextToSpeech::V1::TextToSpeech::Client` client class directly.

### Client Configuration

In older releases, if you wanted to customize performance parameters or
low-level behavior of the client (such as credentials, timeouts, or
instrumentation), you would pass a variety of keyword arguments to the client
constructor. It was also extremely difficult to customize the default settings.

With the 1.0 release, a configuration interface provides control over these
parameters, including defaults for all instances of a client, and settings for
each specific client instance. For example, to set default credentials and
timeout for all Text To Speech V1 clients:

```
Google::Cloud::TextToSpeech::V1::TextToSpeech::Client.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Individual RPCs can also be configured independently. For example, to set the
timeout for the `list_voices` call:

```
Google::Cloud::TextToSpeech::V1::TextToSpeech::Client.configure do |config|
  config.rpcs.list_voices.timeout = 20.0
end
```

Defaults for certain configurations can be set for all Text To Speech versions
globally:

```
Google::Cloud::TextToSpeech.configure do |config|
  config.credentials = "/path/to/credentials.json"
  config.timeout = 10.0
end
```

Finally, you can override the configuration for each client instance. See the
next section on [Creating Clients](#creating-clients) for details.

### Creating Clients

In older releases, to create a client object, you would use the
`Google::Cloud::TextToSpeech.new` class method. Keyword arguments were available to
select a service version and to configure parameters such as credentials and
timeouts.

With the 1.0 release, use the `Google::Cloud::TextToSpeech.text_to_speech` class
method to create a client object. You may select a service version using the
`:version` keyword argument. However, other configuration parameters should be
set in a configuration block when you create the client.

Old:
```
client = Google::Cloud::TextToSpeech.new credentials: "/path/to/credentials.json"
```

New:
```
client = Google::Cloud::TextToSpeech.text_to_speech do |config|
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
client = Google::Cloud::TextToSpeech.new

input = { text: "Hello, world!" }
voice = { language_code: "en-US" }
audio = { audio_encoding: Google::Cloud::Texttospeech::V1::AudioEncoding::MP3 }

# The three arguments are all positional.
response = client.synthesize_speech input, voice, audio
```

New:
```
client = Google::Cloud::TextToSpeech.text_to_speech

input = { text: "Hello, world!" }
voice = { language_code: "en-US" }
audio = { audio_encoding: Google::Cloud::TextToSpeech::V1::AudioEncoding::MP3 }

# The three arguments are all keyword arguments.
response = client.synthesize_speech input: input, voice: voice, audio_config: audio
```

In the 1.0 release, it is also possible to pass a request object, either
as a hash or as a protocol buffer.

New:
```
client = Google::Cloud::TextToSpeech.text_to_speech

request = Google::Cloud::TextToSpeech::V1::SynthesizeSpeechRequest.new(
  input: { text: "Hello, world!" },
  voice: { language_code: "en-US" },
  audio: { audio_encoding: Google::Cloud::TextToSpeech::V1::AudioEncoding::MP3 }
)

# Pass a request object as a positional argument:
response = client.synthesize_speech request
```

Finally, in older releases, to provide call options, you would pass a
`Google::Gax::CallOptions` object with the `:options` keyword argument. In the
1.0 release, pass call options using a _second set_ of keyword arguments.

Old:
```
client = Google::Cloud::TextToSpeech.new

input = { text: "Hello, world!" }
voice = { language_code: "en-US" }
audio = { audio_encoding: Google::Cloud::TextToSpeech::V1::AudioEncoding::MP3 }

options = Google::Gax::CallOptions.new timeout: 10.0

response = client.synthesize_speech input, voice, audio, options: options
```

New:
```
client = Google::Cloud::TextToSpeech.text_to_speech

input = { text: "Hello, world!" }
voice = { language_code: "en-US" }
audio = { audio_encoding: Google::Cloud::TextToSpeech::V1::AudioEncoding::MP3 }

# Use a hash to wrap the normal call arguments (or pass a request object), and
# then add further keyword arguments for the call options.
response = client.synthesize_speech(
  { input: input, voice: voice, audio_config: audio },
  timeout: 10.0
)
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
client = Google::Cloud::TextToSpeech.new

input = { text: "Hello, world!" }
voice = { language_code: "en-US" }
audio = { audio_encoding: Google::Cloud::Texttospeech::V1::AudioEncoding::MP3 }

begin
  response = client.synthesize_speech input, voice, audio
rescue Google::Gax::Error => e
  # Handle exceptions that subclass Google::Gax::Error
end
```

New:
```
client = Google::Cloud::TextToSpeech.text_to_speech

input = { text: "Hello, world!" }
voice = { language_code: "en-US" }
audio = { audio_encoding: Google::Cloud::TextToSpeech::V1::AudioEncoding::MP3 }

begin
  response = client.synthesize_speech input: input, voice: voice,
                                      audio_config: audio
rescue Google::Cloud::Error => e
  # Handle exceptions that subclass Google::Cloud::Error
end
```

### Class Namespaces

In older releases, some data type (protobuf) classes were located under the module
`Google::Cloud::Texttospeech`. In the 1.0 release, these classes have been moved into the
same `Google::Cloud::TextToSpeech` module by the client object, for consistency.

In older releases, the client object was of class
`Google::Cloud::TextToSpeech::V1::TextToSpeechClient`.
In the 1.0 release, the client object is of class
`Google::Cloud::TextToSpeech::V1::TextToSpeech::Client`.
Note that most users will use the `Google::Cloud::TextToSpeech.text_to_speech`
factory method to create instances of the client object, so you may not need to
reference the actual class directly.
See [Creating Clients](#creating-clients).

In older releases, the credentials object was of class
`Google::Cloud::TextToSpeech::V1::Credentials`.
In the 1.0 release, the credentials object is of class
`Google::Cloud::TextToSpeech::V1::TextToSpeech::Credentials`.
Again, most users will not need to reference this class directly.
See [Client Configuration](#client-configuration).
