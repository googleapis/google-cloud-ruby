# Google Cloud Pub/Sub

Google Cloud Pub/Sub is designed to provide reliable, many-to-many, asynchronous
messaging between applications. Publisher applications can send messages to a
"topic" and other applications can subscribe to that topic to receive the
messages. By decoupling senders and receivers, Google Cloud Pub/Sub allows
developers to communicate between independently written applications.

The goal of google-cloud is to provide an API that is comfortable to Rubyists.
Your authentication credentials are detected automatically in Google Cloud
Platform environments such as Google Compute Engine, Google App Engine and
Google Kubernetes Engine. In other environments you can configure authentication
easily, either directly in your code or via environment variables. Read more
about the options for connecting in the {file:AUTHENTICATION.md Authentication
Guide}.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
topic.publish "task completed"
```

To learn more about Pub/Sub, read the [Google Cloud Pub/Sub Overview
](https://cloud.google.com/pubsub/overview).

## Retrieving Topics

A Topic is a named resource to which messages are sent by publishers. A Topic is
found by its name. (See {Google::Cloud::Pubsub::Project#topic Project#topic})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new
topic = pubsub.topic "my-topic"
```

## Creating a Topic

A Topic is created from a Project. (See
{Google::Cloud::Pubsub::Project#create_topic Project#create_topic})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new
topic = pubsub.create_topic "my-topic"
```

## Retrieving Subscriptions

A Subscription is a named resource representing the stream of messages from a
single, specific Topic, to be delivered to the subscribing application. A
Subscription is found by its name. (See
{Google::Cloud::Pubsub::Topic#subscription Topic#subscription})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
subscription = topic.subscription "my-topic-subscription"
puts subscription.name
```

## Creating a Subscription

A Subscription is created from a Topic. (See
{Google::Cloud::Pubsub::Topic#subscribe Topic#subscribe})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
sub = topic.subscribe "my-topic-sub"
puts sub.name # => "my-topic-sub"
```

The subscription can be created that specifies the number of seconds to wait to
be acknowledged as well as an endpoint URL to push the messages to:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
sub = topic.subscribe "my-topic-sub",
                      deadline: 120,
                      endpoint: "https://example.com/push"
```

## Publishing Messages

Messages are published to a topic. Any message published to a topic without a
subscription will be lost. Ensure the topic has a subscription before
publishing. (See {Google::Cloud::Pubsub::Topic#publish Topic#publish})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
msg = topic.publish "task completed"
```

Messages can also be published with attributes:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
msg = topic.publish "task completed",
                    foo: :bar,
                    this: :that
```

Messages can also be published in batches asynchronously using `publish_async`.
(See {Google::Cloud::Pubsub::Topic#publish_async Topic#publish_async} and
{Google::Cloud::Pubsub::AsyncPublisher AsyncPublisher})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
topic.publish_async "task completed" do |result|
  if result.succeeded?
    log_publish_success result.data
  else
    log_publish_failure result.data, result.error
  end
end

topic.async_publisher.stop.wait!
```

Or multiple messages can be published in batches at the same time by passing a
block to `publish`. (See {Google::Cloud::Pubsub::BatchPublisher BatchPublisher})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
msgs = topic.publish do |batch|
  batch.publish "task 1 completed", foo: :bar
  batch.publish "task 2 completed", foo: :baz
  batch.publish "task 3 completed", foo: :bif
end
```

## Receiving messages

Messages can be streamed from a subscription with a subscriber object that is
created using `listen`. (See {Google::Cloud::Pubsub::Subscription#listen
Subscription#listen} and {Google::Cloud::Pubsub::Subscriber Subscriber})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"

subscriber = sub.listen do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop.wait!
```

Messages also can be pulled directly in a one-time operation. (See
{Google::Cloud::Pubsub::Subscription#pull Subscription#pull})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull
```

A maximum number of messages to pull can be specified:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull max: 10
```

## Acknowledging a Message

Messages that are received can be acknowledged in Pub/Sub, marking the message
to be removed so it cannot be pulled again.

A Message that can be acknowledged is called a ReceivedMessage. ReceivedMessages
can be acknowledged one at a time: (See
{Google::Cloud::Pubsub::ReceivedMessage#acknowledge!
ReceivedMessage#acknowledge!})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"

subscriber = sub.listen do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop.wait!
```

Or, multiple messages can be acknowledged in a single API call: (See
{Google::Cloud::Pubsub::Subscription#acknowledge Subscription#acknowledge})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull
sub.acknowledge received_messages
```

## Modifying a Deadline

A message must be acknowledged after it is pulled, or Pub/Sub will mark the
message for redelivery. The message acknowledgement deadline can delayed if more
time is needed. This will allow more time to process the message before the
message is marked for redelivery. (See
{Google::Cloud::Pubsub::ReceivedMessage#delay! ReceivedMessage#delay!})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"
subscriber = sub.listen do |received_message|
  puts received_message.message.data

  # Delay for 2 minutes
  received_message.modify_ack_deadline! 120
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop.wait!
```

The message can also be made available for immediate redelivery:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"
subscriber = sub.listen do |received_message|
  puts received_message.message.data

  # Mark for redelivery
  received_message.reject!
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop.wait!
```

Multiple messages can be delayed or made available for immediate redelivery:
(See {Google::Cloud::Pubsub::Subscription#delay Subscription#delay})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull
sub.modify_ack_deadline 120, received_messages
```

## Creating a snapshot and using seek

You can create a snapshot to retain the existing backlog on a subscription. The
snapshot will hold the messages in the subscription's backlog that are
unacknowledged upon the successful completion of the `create_snapshot`
operation.

Later, you can use `seek` to reset the subscription's backlog to the snapshot.

(See {Google::Cloud::Pubsub::Subscription#create_snapshot
Subscription#create_snapshot} and {Google::Cloud::Pubsub::Subscription#seek
Subscription#seek})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"

snapshot = sub.create_snapshot

received_messages = sub.pull
sub.acknowledge received_messages

sub.seek snapshot
```

## Listening for Messages

A subscriber object can be created using `listen`, which streams messages from
the backend and processes them as they are received. (See
{Google::Cloud::Pubsub::Subscription#listen Subscription#listen} and
{Google::Cloud::Pubsub::Subscriber Subscriber})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"

subscriber = sub.listen do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop.wait!
```

The subscriber object can be configured to control the number of concurrent
streams to open, the number of received messages to be collected, and the number
of threads each stream opens for concurrent calls made to handle the received
messages.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new

sub = pubsub.subscription "my-topic-sub"

subscriber = sub.listen threads: { callback: 16 } do |received_message|
  # store the message somewhere before acknowledging
  store_in_backend received_message.data # takes a few seconds
  received_message.acknowledge!
end

# Start background threads that will call the block passed to listen.
subscriber.start
```

## Working Across Projects

All calls to the Pub/Sub service use the same project and credentials provided
to the {Google::Cloud::Pubsub.new Pubsub.new} method. However, it is common to
reference topics or subscriptions in other projects, which can be achieved by
using the `project` option. The main credentials must have permissions to the
topics and subscriptions in other projects.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new # my-project

# Get a topic in the current project
my_topic = pubsub.topic "my-topic"
my_topic.name #=> "projects/my-project/topics/my-topic"
# Get a topic in another project
other_topic = pubsub.topic "other-topic", project: "other-project-id"
other_topic.name #=> "projects/other-project-id/topics/other-topic"
```

It is possible to create a subscription in the current project that pulls
from a topic in another project:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new # my-project

# Get a topic in another project
topic = pubsub.topic "other-topic", project: "other-project-id"
# Create a subscription in the current project that pulls from
# the topic in another project
sub = topic.subscribe "my-sub"
sub.name #=> "projects/my-project/subscriptions/my-sub"
sub.topic.name #=> "projects/other-project-id/topics/other-topic"
```

## Additional information

Google Cloud Pub/Sub can be configured to use an emulator or to enable gRPC's
logging. To learn more, see the {file:EMULATOR.md Emulator guide} and
{file:LOGGING.md Logging guide}.
