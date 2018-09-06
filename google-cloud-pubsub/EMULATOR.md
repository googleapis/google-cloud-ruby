# Google Cloud Pub/Sub Emulator

To develop and test your application locally, you can use the [Google Cloud
Pub/Sub Emulator](https://cloud.google.com/pubsub/emulator), which provides
[local emulation](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/)
of the production Google Cloud Pub/Sub environment. You can start the Google
Cloud Pub/Sub emulator using the `gcloud` command-line tool.

To configure your ruby code to use the emulator, set the `PUBSUB_EMULATOR_HOST`
environment variable to the host and port where the emulator is running. The
value can be set as an environment variable in the shell running the ruby code,
or can be set directly in the ruby code as shown below.

```ruby
require "google/cloud/pubsub"

# Make Pub/Sub use the emulator
ENV["PUBSUB_EMULATOR_HOST"] = "localhost:8918"

pubsub = Google::Cloud::Pubsub.new "emulator-project-id"

# Get a topic in the current project
my_topic = pubsub.new_topic "my-topic"
my_topic.name #=> "projects/emulator-project-id/topics/my-topic"
```

Or by providing the `emulator_host` argument:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new emulator_host: "localhost:8918"

# Get a topic in the current project
my_topic = pubsub.new_topic "my-topic"
my_topic.name #=> "projects/emulator-project-id/topics/my-topic"
```
