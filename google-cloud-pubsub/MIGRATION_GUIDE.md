# Ruby Pub/Sub V3 Migration Guide

This page summarizes the changes needed to migrate from `google-cloud-pubsub`
`v2.x` to `google-cloud-pubsub` `v3.x`.
In line with [Google's Breaking Change Policy](https://opensource.google/documentation/policies/library-breaking-change),
we plan to support the existing `v2.x` library until July 31st, 2026 (12 months from the `v3.x` release),
including bug and security patches, but it will not receive new features.

Note that this is a major version bump that includes breaking changes for the
Ruby library specifically, but the Pub/Sub API itself remains the same.

## Overview

This major version update involves several significant changes to the Ruby Pub/Sub client library:

1. **Removal of handwritten resource management APIs**:
The APIs for resource management, also known as admin operations, have been replaced with
auto-generated clients. Using these generated clients ensures you have access to the latest
features and updates to the API.
2. **Service Renaming**:
The `Publisher` and `Subscriber` services within the auto-generated layer have
been renamed to `TopicAdmin` and `SubscriptionAdmin`, respectively.
3. **Restructured Publishing and Subscribing**:
To better reflect their purpose, `Publisher` and `Subscriber` objects now exclusively
handle publishing and receiving messages. These operations were formerly handled
by `Topic` and `Subscription`.
4. **Auto-generated Client Exposure**:
The `TopicAdmin::Client`, `SubscriptionAdmin::Client`, and `SchemaService::Client` are now directly
accessible from `Google::Cloud::PubSub::Project`.

## Admin Operations

The Pub/Sub admin plane, also known as the control plane, handles the lifecycle of server-side
resources like topics, subscriptions, and schemas. This API consists of admin operations such
as creating, getting, updating, and deleting these resources.

One of the key differences between version `2.x` and `3.x` is the change to the admin API.
The handwritten methods have been removed, and the new way to make admin calls is through
auto-generated clients. You can access them directly from a `Google::Cloud::PubSub::Project` object.

```ruby
pubsub = Google::Cloud::PubSub.new

# Get the auto-generated client for managing topic resources
topic_admin = pubsub.topic_admin

# Get the auto-generated client for managing subscription resources
subscription_admin = pubsub.subscription_admin

# Get the auto-generated client for managing schema resources
schema_admin = pubsub.schema
```

There is a mostly one-to-one mapping of existing admin methods to the new admin methods.
A notable exception is that the auto-generated admin library does not provide an `exists?` method.
The recommended pattern is to optimistically perform an operation like `get_topic` and handle
the incoming error (e.g. `Google::Cloud::NotFoundError`) if the resource does not exist.

The new admin clients use a standard gRPC request/response format. A key difference is that requests
now require the fully qualified resource name instead of just the resource ID. 
It is easiest to use the provided helper methods (such as `topic_path`,
`subscription_path` and `schema_path`) to generate these names.

Here are examples of the differences between version `2.x` and `3.x`:

### Creating a Topic

`v2.x`:

```ruby
# topic_id = "your-topic-id"
pubsub = Google::Cloud::PubSub.new

topic = pubsub.create_topic topic_id
```

`v3.x`:

```ruby
# topic_id = "your-topic-id"
pubsub = Google::Cloud::PubSub.new

topic_admin = pubsub.topic_admin

topic = topic_admin.create_topic name: pubsub.topic_path(topic_id)
```

### Deleting a Topic

`v2.x`:

```ruby
# topic_id = "your-topic-id"
pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic topic_id

topic.delete
```

`v3.x`:

```ruby
pubsub = Google::Cloud::PubSub.new

topic_admin = pubsub.topic_admin

topic_admin.delete_topic topic: pubsub.topic_path(topic_id)
```

### Update RPCs

Update RPCs now require passing a `FieldMask` along with the resource you are modifying.
The service uses the field mask to know which fields should be updated.
The strings passed into the update field mask should be the `snake_case` name of the field
you are editing (e.g., `dead_letter_policy`).

If a field mask is not present, the operation applies to all fields and overrides
the entire resource. For more information on FieldMasks, refer to
[google.aip.dev/161](https://google.aip.dev/161).

`v2.x`:

```ruby
# subscription_id = "your-subscription-id"
pubsub = Google::Cloud::PubSub.new

subscription = pubsub.subscription subscription_id

subscription.remove_dead_letter_policy
```

`v3.x`:

```ruby
# subscription_id = "your-subscription-id"
pubsub = Google::Cloud::PubSub.new

subscription_admin = pubsub.subscription_admin

subscription = subscription_admin.get_subscription \
    subscription: pubsub.subscription_path(subscription_id)

subscription.dead_letter_policy = nil

subscription_admin.update_subscription subscription: subscription,
                                       update_mask: {
                                         paths: ["dead_letter_policy"]
                                       }
```

## Data Plane Operations

In contrast with admin operations that deal with resource management, the data plane handles
the movement of data, which in Pub/Sub is the publishing and receiving of messages.

In version 3.x, admin operations have been moved to separate auto-generated clients as illustrated
above. The data operations have not been moved, but a few of the class names have been modified to
clarify their intent.

### Publishing Messages

Instead of instantiating a `Topic` for data plane operations, you will now create a `Publisher`. 
The `publisher` method can accept either the resource ID (e.g., `"my-topic"`) or the fully qualified
resource name (e.g., `"projects/my-project/topics/my-topic"`) for convenience.

`v2.x`:

```ruby
pubsub = Google::Cloud::Pubsub.new

topic = pubsub.topic "my-topic"
topic.publish "This is a test message."
```

`v3.x`:

```ruby
pubsub = Google::Cloud::Pubsub.new

publisher = pubsub.publisher "my-topic"
publisher.publish "This is a test message."
```

### Receiving Messages

Similarly, a `Subscription` object no longer manages receiving messages; that action
is now performed by a `Subscriber`.

`v2.x`:

```ruby
pubsub = Google::Cloud::PubSub.new

subscription = pubsub.subscription "my-topic-sub"

subscriber = subscription.listen do |received_message|
  puts "Message: #{received_message.message.data}"
  received_message.acknowledge!
end

subscriber.start
```

`v3.x`:

```ruby
pubsub = Google::Cloud::PubSub.new

subscriber = pubsub.subscriber "my-topic-sub"

listener = subscriber.listen do |received_message|
  puts "Message: #{received_message.message.data}"
  received_message.acknowledge!
end

listener.start
```

Admin operations like `create_topic` no longer return an object that can perform data operations.
Consequently, after creating the topic resource, you must separately instantiate a `Publisher` client
to publish messages. The following example illustrates the new workflow:

```ruby
# topic_id = "your-topic-id"
pubsub = Google::Cloud::PubSub.new

# 1. Create the topic using the admin client
topic_admin = pubsub.topic_admin

topic = topic_admin.create_topic name: pubsub.topic_path(topic_id)

# 2. Instantiate a publisher to publish messages
publisher = pubsub.publisher topic.name

publisher.publish "This is a message."
```


## FAQs

### Why is the admin API surface changing?

One of the primary goals is to reduce confusion between the data plane and admin plane surfaces. 
Creating a topic is a server-side operation, while creating a publisher is a client-side
operation; this separation makes the library's behavior more explicit. 
Additionally, replacing handwritten admin operations with auto-generated clients ensures more
timely availability of the latest features.

### What is required for migration?

Migration primarily involves the following:

1. Replacing `topic` and `subscription` instantiations with `publisher` and `subscriber`
for publishing and receiving messages.
2. Rewriting admin operations (i.e. `create_topic`, `delete_subscription`, etc.) to use
the new admin clients (e.g. `topic_admin`, `subscription_admin`).
3. Updating code that creates a resource and then uses the returned object for data plane calls.
You will now need to instantiate a `Publisher` or `Subscriber` separately after the resource is created.

## Appendix: Method Mappings

The following tables provide a mapping from the `v2.x` methods to their `v3.x` equivalents.

### Topic

| `v2.x` | `v3.x` |
| ------ | ------ |
| name   | TopicAdmin::Client.get_topic |
| labels | TopicAdmin::Client.get_topic |
| labels= | TopicAdmin::Client.update_topic |
| kms_key | TopicAdmin::Client.get_topic |
| kms_key= | TopicAdmin::Client.update_topic |
| persistence_regions | TopicAdmin::Client.get_topic |
| persistence_regions= | TopicAdmin::Client.update_topic |
| schema_name	| TopicAdmin::Client.get_topic |
| message_encoding	| TopicAdmin::Client.get_topic |
| retention	| TopicAdmin::Client.get_topic |
| retention=	| TopicAdmin::Client.update_topic |
| delete	| TopicAdmin::Client.delete_topic |
| subscribe	| SubscriptionAdmin::Client.create_subscription |
| subscription	| SubscriptionAdmin::Client.get_subscription |
| subscriptions	| SubscriptionAdmin::Client.list_topic_subscriptions |


### Subscription

| `v2.x` | `v3.x` |
| ------ | ------ |
| name | SubscriptionAdmin::Client.get_subscription |
| topic	| TopicAdmin::Client.get_topic |
| deadline | SubscriptionAdmin::Client.get_subscription |
| deadline=	| SubscriptionAdmin::Client.update_subscription |
| retain_acked	| SubscriptionAdmin::Client.get_subscription |
| retain_acked=	| SubscriptionAdmin::Client.update_subscription |
| retention	| SubscriptionAdmin::Client.get_subscription |
| retention=	| SubscriptionAdmin::Client.update_subscription |
| topic_retention	| SubscriptionAdmin::Client.get_subscription |
| endpoint	| SubscriptionAdmin::Client.get_subscription |
| endpoint=	| SubscriptionAdmin::Client.modify_push_config |
| push_config	| SubscriptionAdmin::Client.update_subscription |
| bigquery_config	| SubscriptionAdmin::Client.update_subscription |
| labels	| SubscriptionAdmin::Client.get_subscription |
| labels=	| SubscriptionAdmin::Client.update_subscription |
| expires_in	| SubscriptionAdmin::Client.get_subscription |
| expires_in=	| SubscriptionAdmin::Client.update_subscription |
| filter	| SubscriptionAdmin::Client.get_subscription |
| dead_letter_topic |	SubscriptionAdmin::Client.get_subscription **then** TopicAdmin::Client.get_topic |
| dead_letter_topic=	| SubscriptionAdmin::Client.update_subscription |
| dead_letter_max_delivery_attempts	| SubscriptionAdmin::Client.get_subscription |
| dead_letter_max_delivery_attempts=	| SubscriptionAdmin::Client.update_subscription |
| remove_dead_letter_policy	| SubscriptionAdmin::Client.update_subscription |
| retry_policy	| SubscriptionAdmin::Client.get_subscription |
| retry_policy=	| SubscriptionAdmin::Client.update_subscription |
| message_ordering?	| SubscriptionAdmin::Client.get_subscription |
| detached?	| SubscriptionAdmin::Client.get_subscription |
| delete	| SubscriptionAdmin::Client.delete_subscription |
| detach	| TopicAdmin::Client.detach_subscription |
| acknowledge	| SubscriptionAdmin::Client.acknowledge |
| modify_ack_deadline	| SubscriptionAdmin::Client.modify_ack_deadline |
| create_snapshot	| SubscriptionAdmin::Client.create_snapshot |
| seek	| SubscriptionAdmin::Client.seek |

### Schema

| `v2.x` | `v3.x` |
| ------ | ------ |
| name | SchemaService::Client.get_schema |
| type | SchemaService::Client.get_schema |
| definition | SchemaService::Client.get_schema |
| revision_id | SchemaService::Client.get_schema |
| validate_message | SchemaService::Client.validate_message |
| delete | SchemaService::Client.delete_schema |
| commit | SchemaService::Client.commit_schema |
| resource_full? | SchemaService::Client.get_schema |


### Project

| `v2.x` | `v3.x` |
| ------ | ------ |
| topic | TopicAdmin::Client.get_topic |
| create_topic | TopicAdmin::Client.create_topic |
| topics | TopicAdmin::Client.list_topics |
| subscription | SubscriptionAdmin::Client.get_subscription |
| subscriptions | SubscriptionAdmin::Client.list_subscriptions |
| snapshots | SubscriptionAdmin::Client.list_snapshots |
| schema | SchemaService::Client.get_schema |
| create_schema | SchemaService::Client.create_schema |
| schemas | SchemaService::Client.list_schemas |
| valid_schema? | SchemaService::Client.validate_schema |
