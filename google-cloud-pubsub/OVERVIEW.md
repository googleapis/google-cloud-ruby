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

publisher = pubsub.publisher "my-topic"
publisher.publish "topic-message"

subscriber = pubsub.subscriber "my-topic-sub"
subscriber.listen do |received_message|
  puts "Message: #{received_message.message.data}"
  received_message.acknowledge!
end
```

This guide provides an overview of the client library's operations, which are categorized
into Admin Operations and Data Plane Operations.

* **Admin Operations**: Used for creating, configuring, and managing Pub/Sub resources (topics, subscriptions, schemas).
* **Data Plane Operations**: For the core functionality of publishing and receiving messages.

To learn more about Pub/Sub, read the [Google Cloud Pub/Sub Overview
](https://cloud.google.com/pubsub/overview).

## Admin Operations

### Topic Admin Client

Manages topic resources.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new project_id: "my-project-id"
topic_admin = pubsub.topic_admin
```

#### Creating a Topic

A Topic is a named resource to which messages are sent by publishers. The resource must be created using
a topic admin client before it can be used.

```ruby
topic_path = pubsub.topic_path "my-topic"
topic = topic_admin.create_topic name: topic_path

puts "Topic #{topic.name} created."
```

#### Retrieving a Topic

A Topic is found by its full name.

```ruby
topic_name = "my-topic"
topic_path = pubsub.topic_path topic_name # Format is `projects/#{project_id}/topics/#{topic_name}`
topic = topic_admin.get_topic topic: topic_path

puts "Topic: #{topic.name}."
```

### Subscription Admin Client

Manages subscription and snapshot resources.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new project_id: "my-project-id"
subscription_admin = pubsub.subscription_admin
```


#### Creating a Subscription

A Subscription is a named resource representing the stream of messages from a
single, specific Topic, to be delivered to the subscribing application.

```ruby
topic_path = pubsub.topic_path "my-topic" # Already created Topic resource
subscription_path = pubsub.subscription_path "my-topic-subscription"
subscription = subscription_admin.create_subscription name: subscription_path, topic: topic_path
```

The subscription can be created that specifies the number of seconds to wait to
be acknowledged as well as an endpoint URL to push the messages to:

```ruby
topic_path = pubsub.topic_path "my-topic" # Already created Topic resource
subscription_path = pubsub.subscription_path "my-topic-subscription"
push_config = Google::Cloud::PubSub::V1::PushConfig.new push_endpoint: "https://example.com/push"
subscription = subscription_admin.create_subscription name: subscription_path, topic: topic_path,
                                                      push_config: push_config,
                                                      ack_deadline_seconds: 120
```

#### Retrieving Subscriptions

A Subscription is found by its name.

```ruby
subscription_path = pubsub.subscription_path "my-topic-subscription"
subscription = subscription_admin.get_subscription subscription: subscription_path
```

## Data Plane Operations

### Publisher Client

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new project_id: "my-project-id"
publisher = pubsub.publisher "my-topic"
```

#### Publishing Messages

Messages are published to a topic. Any message published to a topic without a
subscription will be lost. Ensure the topic has a subscription before
publishing.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

publisher = pubsub.publisher "my-topic"
msg = publisher.publish "task completed"
```

Messages can also be published with attributes:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

publisher = pubsub.publisher "my-topic"
msg = publisher.publish "task completed",
                    foo: :bar,
                    this: :that
```

Messages can also be published in batches asynchronously using `publish_async`.
(See {Google::Cloud::PubSub::Publisher#publish_async Publisher#publish_async} and
{Google::Cloud::PubSub::AsyncPublisher AsyncPublisher})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

publisher = pubsub.publisher "my-topic"
publisher.publish_async "task completed" do |result|
  if result.succeeded?
    log_publish_success result.data
  else
    log_publish_failure result.data, result.error
  end
end

publisher.async_publisher.stop!
```

Or multiple messages can be published in batches at the same time by passing a
block to `publish`. (See {Google::Cloud::PubSub::BatchPublisher BatchPublisher})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

publisher = pubsub.publisher "my-topic"
msgs = publisher.publish do |batch|
  batch.publish "task 1 completed", foo: :bar
  batch.publish "task 2 completed", foo: :baz
  batch.publish "task 3 completed", foo: :bif
end
```

### Subscriber Client

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new project_id: "my-project-id"
subscriber = pubsub.subscriber "my-topic-subscription"

```

#### Receiving Messages

Messages can be streamed from a subscription with a subscriber object that is
created using `listen`. (See {Google::Cloud::PubSub::Subscriber#listen
Subscriber#listen} and {Google::Cloud::PubSub::MessageListener MessageListener})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"

# Create a MessageListener to listen for available messages.
# By default, this block will be called on 8 concurrent threads
# but this can be tuned with the `threads` option.
# The `streams` and `inventory` parameters allow further tuning.
listener = subscriber.listen threads: { callback: 16 } do |received_message|
  # process message
  puts "Data: #{received_message.message.data}, published at #{received_message.message.published_at}"
  received_message.acknowledge!
end

# Handle exceptions from listener
listener.on_error do |exception|
  puts "Exception: #{exception.class} #{exception.message}"
end

# Gracefully shut down the subscriber on program exit, blocking until
# all received messages have been processed or 10 seconds have passed
at_exit do
  listener.stop!(10)
end

# Start background threads that will call the block passed to listen.
listener.start

# Block, letting processing threads continue in the background
sleep
```

Messages also can be pulled directly in a one-time operation. (See
{Google::Cloud::PubSub::Subscriber#pull Subscriber#pull})

The `immediate: false` option is recommended to avoid adverse impacts on the
performance of pull operations.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"
received_messages = subscriber.pull immediate: false
```

A maximum number of messages to pull can be specified:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"
received_messages = subscriber.pull immediate: false, max: 10
```

#### Acknowledging a Message

Messages that are received can be acknowledged in Pub/Sub, signaling the server
not to deliver them again.

A Message that can be acknowledged is called a ReceivedMessage. ReceivedMessages
can be acknowledged one at a time: (See
{Google::Cloud::PubSub::ReceivedMessage#acknowledge!
ReceivedMessage#acknowledge!})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"

listener = subscriber.listen do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call the block passed to listen.
listener.start

# Shut down the subscriber when ready to stop receiving messages.
listener.stop!
```

Or, multiple messages can be acknowledged in a single API call: (See
{Google::Cloud::PubSub::Subscriber#acknowledge Subscriber#acknowledge})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"
received_messages = subscriber.pull immediate: false
subscriber.acknowledge received_messages
```

#### Modifying a Deadline

A message must be acknowledged after it is pulled, or Pub/Sub will mark the
message for redelivery. The message acknowledgement deadline can delayed if more
time is needed. This will allow more time to process the message before the
message is marked for redelivery. (See
{Google::Cloud::PubSub::ReceivedMessage#modify_ack_deadline!
ReceivedMessage#modify_ack_deadline!})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"
listener = subscriber.listen do |received_message|
  puts received_message.message.data

  # Delay for 2 minutes
  received_message.modify_ack_deadline! 120
end

# Start background threads that will call the block passed to listen.
listener.start

# Shut down the subscriber when ready to stop receiving messages.
listener.stop!
```

The message can also be made available for immediate redelivery:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"
listener = subscriber.listen do |received_message|
  puts received_message.message.data

  # Mark for redelivery
  received_message.reject!
end

# Start background threads that will call the block passed to listen.
listener.start

# Shut down the subscriber when ready to stop receiving messages.
listener.stop!
```

Multiple messages can be delayed or made available for immediate redelivery:
(See {Google::Cloud::PubSub::Subscriber#modify_ack_deadline
Subscriber#modify_ack_deadline})

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"
received_messages = subscriber.pull immediate: false
subscriber.modify_ack_deadline 120, received_messages
```

### Using Ordering Keys

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

#### Publishing Ordered Messages

To use ordering keys when publishing messages, a call to
{Google::Cloud::PubSub::Publisher#enable_message_ordering!
Publisher#enable_message_ordering!} must be made and the `ordering_key` argument
must be provided when calling {Google::Cloud::PubSub::Publisher#publish_async
Publisher#publish_async}.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

publisher = pubsub.publisher "my-ordered-topic"

# Ensure that message ordering is enabled.
publisher.enable_message_ordering!

# Publish an ordered message with an ordering key.
publisher.publish_async "task completed",
                    ordering_key: "task-key"

# Shut down the publisher when ready to stop publishing messages.
publisher.async_publisher.stop!
```

#### Handling errors with Ordered Keys

Ordered messages that fail to publish to the Pub/Sub API due to error will put
the `ordering_key` in a failed state, and future calls to
{Google::Cloud::PubSub::Publisher#publish_async Publisher#publish_async} with the
`ordering_key` will raise {Google::Cloud::PubSub::OrderingKeyError
OrderingKeyError}. To allow future messages with the `ordering_key` to be
published, the `ordering_key` must be passed to
{Google::Cloud::PubSub::Publisher#resume_publish Publisher#resume_publish}.

#### Receiving Ordered Messages

To use ordering keys when subscribing to messages, the subscription must be
created with message ordering enabled before calling
{Google::Cloud::PubSub::Subscriber#listen Subscriber#listen}. When enabled,
the subscriber will deliver messages with the same `ordering_key` in the order
they were published.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscription = ... # "my-ordered-topic-sub" subscription with message ordering enabled
puts subscription.enable_message_ordering #=> true

subscriber = pubsub.subscriber "my-ordered-topic-sub"

listener = subscriber.listen do |received_message|
  # Messsages with the same ordering_key are received
  # in the order in which they were published.
  received_message.acknowledge!
end

# Start background threads that will call block passed to listen.
listener.start

# Shut down the subscriber when ready to stop receiving messages.
listener.stop!
```

### Minimizing API calls before receiving and acknowledging messages

A subscriber object can be created without making any API calls by providing
the `skip_lookup` argument to {Google::Cloud::PubSub::Project#subscriber
Project#subscriber}. A MessageListener object can also be created without an API
call by providing the `deadline` optional argument to
{Google::Cloud::PubSub::Subscriber#listen Subscriber#listen}

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

# No API call is made to retrieve the subscription resource.
subscriber = pubsub.subscriber "my-topic-sub", skip_lookup: true

# No API call is made to retrieve the subscription deadline.
listener = subscriber.listen deadline: 60 do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call block passed to listen.
listener.start

# Shut down the subscriber when ready to stop receiving messages.
listener.stop!
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

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new

subscription_admin = pubsub.subscription_admin
snapshot_path = pubsub.snapshot_path "my-snapshot"
subscription = ... # Already created Google::Cloud::PubSub::V1::Subscription
snapshot = subscription_admin.create_snapshot name: snapshot_path, subscription: subscription.name

subscriber = pubsub.subscriber "my-topic-sub"
received_messages = sub.pull immediate: false
subscriber.acknowledge received_messages

subcription_admin.seek subscription: subscription.name, snapshot: snapshot.name
```

## Working Across Projects

All calls to the Pub/Sub service use the same project and credentials provided
to the {Google::Cloud::PubSub.new PubSub.new} method. However, it is common to
reference publishers or subscribers in other projects, which can be achieved by
using the `project` option. The main credentials must have permissions to the
topics and subscriptions in other projects.

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new # my-project

# Get a Publisher for a topic in the current project
publisher = pubsub.publisher "my-topic"
publisher.name #=> "projects/my-project/topics/my-topic"

# Get a Publisher for a topic in another project
other_publisher = pubsub.publisher "other-topic", project: "other-project-id"
other_publisher.name #=> "projects/other-project-id/topics/other-topic"
```

It is possible to create a subscription in the current project that pulls
from a topic in another project:

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new # my-project
subscription_admin = pubsub.subscription_admin

# Get a Publisher for a topic in another project
publisher = pubsub.publisher "other-topic", project: "other-project-id"
# Create a subscription in the current project that pulls from
# the topic in another project
subscription_path = pubsub.subscription_path "my-sub"
subscription = subscription_admin.create_subscription name: subscription_path, topic: publisher.name

subscription.name #=> "projects/my-project/subscriptions/my-sub"
publisher.name #=> "projects/other-project-id/topics/other-topic"
```

## Additional information

Google Cloud Pub/Sub can be configured to use an emulator or to enable gRPC's
logging. To learn more, see the [Emulator guide](EMULATOR.md) and
[Logging guide](LOGGING.md).
