# Google Cloud Pub/Sub

Google Cloud Pub/Sub is designed to provide reliable, many-to-many, asynchronous
messaging between applications. Publisher applications can send messages to a
"topic" and other applications can subscribe to that topic to receive the
messages. By decoupling senders and receivers, Google Cloud Pub/Sub allows
developers to communicate between independently written applications.

The goal of google-cloud is to provide an API that is comfortable to Rubyists.
Your authentication credentials are detected automatically in Google Cloud
Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine
(GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run. In
other environments you can configure authentication easily, either directly in
your code or via environment variables. Read more about the options for
connecting in the [Authentication Guide](AUTHENTICATION.md).

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
topic.publish "task completed"
```

To learn more about Pub/Sub, read the [Google Cloud Pub/Sub Overview
](https://cloud.google.com/pubsub/overview).

## Retrieving Topics

A Topic is a named resource to which messages are sent by publishers. A Topic is
found by its name. (See {Google::Cloud::PubSub::Project#topic Project#topic})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new
topic = pubsub.topic "my-topic"
```

## Creating a Topic

A Topic is created from a Project. (See
{Google::Cloud::PubSub::Project#create_topic Project#create_topic})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new
topic = pubsub.create_topic "my-topic"
```

## Retrieving Subscriptions

A Subscription is a named resource representing the stream of messages from a
single, specific Topic, to be delivered to the subscribing application. A
Subscription is found by its name. (See
{Google::Cloud::PubSub::Topic#subscription Topic#subscription})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
subscription = topic.subscription "my-topic-subscription"
puts subscription.name
```

## Creating a Subscription

A Subscription is created from a Topic. (See
{Google::Cloud::PubSub::Topic#subscribe Topic#subscribe})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
sub = topic.subscribe "my-topic-sub"
puts sub.name # => "my-topic-sub"
```

The subscription can be created that specifies the number of seconds to wait to
be acknowledged as well as an endpoint URL to push the messages to:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
sub = topic.subscribe "my-topic-sub",
                      deadline: 120,
                      endpoint: "https://example.com/push"
```

## Publishing Messages

Messages are published to a topic. Any message published to a topic without a
subscription will be lost. Ensure the topic has a subscription before
publishing. (See {Google::Cloud::PubSub::Topic#publish Topic#publish})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
msg = topic.publish "task completed"
```

Messages can also be published with attributes:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
msg = topic.publish "task completed",
                    foo: :bar,
                    this: :that
```

Messages can also be published in batches asynchronously using `publish_async`.
(See {Google::Cloud::PubSub::Topic#publish_async Topic#publish_async} and
{Google::Cloud::PubSub::AsyncPublisher AsyncPublisher})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
topic.publish_async "task completed" do |result|
  if result.succeeded?
    log_publish_success result.data
  else
    log_publish_failure result.data, result.error
  end
end

topic.async_publisher.stop!
```

Or multiple messages can be published in batches at the same time by passing a
block to `publish`. (See {Google::Cloud::PubSub::BatchPublisher BatchPublisher})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-topic"
msgs = topic.publish do |batch|
  batch.publish "task 1 completed", foo: :bar
  batch.publish "task 2 completed", foo: :baz
  batch.publish "task 3 completed", foo: :bif
end
```

## Receiving Messages

Messages can be streamed from a subscription with a subscriber object that is
created using `listen`. (See {Google::Cloud::PubSub::Subscription#listen
Subscription#listen} and {Google::Cloud::PubSub::Subscriber Subscriber})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"

# Create a subscriber to listen for available messages.
# By default, this block will be called on 8 concurrent threads
# but this can be tuned with the `threads` option.
# The `streams` and `inventory` parameters allow further tuning.
subscriber = sub.listen threads: { callback: 16 } do |received_message|
  # process message
  puts "Data: #{received_message.message.data}, published at #{received_message.message.published_at}"
  received_message.acknowledge!
end

# Handle exceptions from listener
subscriber.on_error do |exception|
  puts "Exception: #{exception.class} #{exception.message}"
end

# Gracefully shut down the subscriber on program exit, blocking until
# all received messages have been processed or 10 seconds have passed
at_exit do
  subscriber.stop!(10)
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Block, letting processing threads continue in the background
sleep
```

Messages also can be pulled directly in a one-time operation. (See
{Google::Cloud::PubSub::Subscription#pull Subscription#pull})

The `immediate: false` option is recommended to avoid adverse impacts on the
performance of pull operations.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull immediate: false
```

A maximum number of messages to pull can be specified:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull immediate: false, max: 10
```

## Acknowledging a Message

Messages that are received can be acknowledged in Pub/Sub, marking the message
to be removed so it cannot be pulled again.

A Message that can be acknowledged is called a ReceivedMessage. ReceivedMessages
can be acknowledged one at a time: (See
{Google::Cloud::PubSub::ReceivedMessage#acknowledge!
ReceivedMessage#acknowledge!})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"

subscriber = sub.listen do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop!
```

Or, multiple messages can be acknowledged in a single API call: (See
{Google::Cloud::PubSub::Subscription#acknowledge Subscription#acknowledge})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull immediate: false
sub.acknowledge received_messages
```

## Modifying a Deadline

A message must be acknowledged after it is pulled, or Pub/Sub will mark the
message for redelivery. The message acknowledgement deadline can delayed if more
time is needed. This will allow more time to process the message before the
message is marked for redelivery. (See
{Google::Cloud::PubSub::ReceivedMessage#modify_ack_deadline!
ReceivedMessage#modify_ack_deadline!})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"
subscriber = sub.listen do |received_message|
  puts received_message.message.data

  # Delay for 2 minutes
  received_message.modify_ack_deadline! 120
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop!
```

The message can also be made available for immediate redelivery:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"
subscriber = sub.listen do |received_message|
  puts received_message.message.data

  # Mark for redelivery
  received_message.reject!
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop!
```

Multiple messages can be delayed or made available for immediate redelivery:
(See {Google::Cloud::PubSub::Subscription#modify_ack_deadline
Subscription#modify_ack_deadline})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"
received_messages = sub.pull immediate: false
sub.modify_ack_deadline 120, received_messages
```

## Using Ordering Keys

Google Cloud Pub/Sub ordering keys provide the ability to ensure related
messages are sent to subscribers in the order in which they were published.
Messages can be tagged with an ordering key, a string that identifies related
messages for which publish order should be respected. The service guarantees
that, for a given ordering key and publisher, messages are sent to subscribers
in the order in which they were published. Ordering does not require sacrificing
high throughput or scalability, as the service automatically distributes
messages for different ordering keys across subscribers.

Note: At the time of this release, ordering keys are not yet publicly enabled
and requires special project enablements.

### Publishing Ordered Messages

To use ordering keys when publishing messages, a call to
{Google::Cloud::PubSub::Topic#enable_message_ordering!
Topic#enable_message_ordering!} must be made and the `ordering_key` argument
must be provided when calling {Google::Cloud::PubSub::Topic#publish_async
Topic#publish_async}.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

topic = pubsub.topic "my-ordered-topic"

# Ensure that message ordering is enabled.
topic.enable_message_ordering!

# Publish an ordered message with an ordering key.
topic.publish_async "task completed",
                    ordering_key: "task-key"

# Shut down the publisher when ready to stop publishing messages.
topic.async_publisher.stop!
```

### Handling errors with Ordered Keys

Ordered messages that fail to publish to the Pub/Sub API due to error will put
the `ordering_key` in a failed state, and future calls to
{Google::Cloud::PubSub::Topic#publish_async Topic#publish_async} with the
`ordering_key` will raise {Google::Cloud::PubSub::OrderingKeyError
OrderingKeyError}. To allow future messages with the `ordering_key` to be
published, the `ordering_key` must be passed to
{Google::Cloud::PubSub::Topic#resume_publish Topic#resume_publish}.

### Receiving Ordered Messages

To use ordering keys when subscribing to messages, the subscription must be
created with message ordering enabled (See
{Google::Cloud::PubSub::Topic#subscribe Topic#subscribe} and
{Google::Cloud::PubSub::Subscription#message_ordering?
Subscription#message_ordering?}) before calling
{Google::Cloud::PubSub::Subscription#listen Subscription#listen}. When enabled,
the subscriber will deliver messages with the same `ordering_key` in the order
they were published.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-ordered-topic-sub"
sub.message_ordering? #=> true

subscriber = sub.listen do |received_message|
  # Messsages with the same ordering_key are received
  # in the order in which they were published.
  received_message.acknowledge!
end

# Start background threads that will call block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop!
```

## Minimizing API calls before receiving and acknowledging messages

A subscription object can be created without making any API calls by providing
the `skip_lookup` argument to {Google::Cloud::PubSub::Project#subscription
Project#subscription} or {Google::Cloud::PubSub::Topic#subscription
Topic#subscription}. A subscriber object can also be created without an API call
by providing the `deadline` optional argument to
{Google::Cloud::PubSub::Subscription#listen Subscription#listen}:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

# No API call is made to retrieve the subscription resource.
sub = pubsub.subscription "my-topic-sub", skip_lookup: true

# No API call is made to retrieve the subscription deadline.
subscriber = sub.listen deadline: 60 do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop!
```

Skipping API calls may be used to avoid `Google::Cloud::PermissionDeniedError`
if your account has limited access to the Pub/Sub API. In particular, the role
`roles/pubsub.subscriber` does not have the permission
`pubsub.subscriptions.get`, which is required to retrieve a subscription
resource. See [Access Control -
Roles](https://cloud.google.com/pubsub/docs/access-control#roles) for the
complete list of Pub/Sub roles and permissions.

## Creating a snapshot and using seek

You can create a snapshot to retain the existing backlog on a subscription. The
snapshot will hold the messages in the subscription's backlog that are
unacknowledged upon the successful completion of the `create_snapshot`
operation.

Later, you can use `seek` to reset the subscription's backlog to the snapshot.

(See {Google::Cloud::PubSub::Subscription#create_snapshot
Subscription#create_snapshot} and {Google::Cloud::PubSub::Subscription#seek
Subscription#seek})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

sub = pubsub.subscription "my-topic-sub"

snapshot = sub.create_snapshot

received_messages = sub.pull immediate: false
sub.acknowledge received_messages

sub.seek snapshot
```

## Working Across Projects

All calls to the Pub/Sub service use the same project and credentials provided
to the {Google::Cloud::PubSub.new PubSub.new} method. However, it is common to
reference topics or subscriptions in other projects, which can be achieved by
using the `project` option. The main credentials must have permissions to the
topics and subscriptions in other projects.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new # my-project

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

pubsub = Google::Cloud::PubSub.new # my-project

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
logging. To learn more, see the [Emulator guide](EMULATOR.md) and
[Logging guide](LOGGING.md).
