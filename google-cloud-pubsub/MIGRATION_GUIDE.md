# Ruby Pub/Sub V3 Migration Guide

This guide is primarily for users with prior `google-cloud-pubsub` **v2** experience who want to learn about the changes
between the former version and `google-cloud-pubsub` **v3**. The recommended way to start learning about the Ruby Pub/Sub
library is by reading the documentation in [OVERVIEW.md](OVERVIEW.md).

## Changes Overview

This major version update involves several significant changes to the Ruby Pub/Sub client library:

1. **Service Renaming**: The Publisher and Subscriber services within the auto-generated gRPC surface (`google-cloud-pubsub-v1`)
have been renamed to `TopicAdmin` and `SubscriptionAdmin`, respectively.
2. **Removal of handwritten resource management APIs**: These existing APIs will be replaced with the 
gRPC-based clients in `google-cloud-pubsub-v1`. This deprecation includes CRUDL operations for topics, subscriptions,
and schemas as well as IAM.
    1. Handwritten classes such as Snapshot, Schema, and ReceivedMessage are removed in favor of their auto-generated counterparts.
3. **Restructed Publishing and Subscribing**:
    1. To better reflect their purpose, the Publisher and Subscriber objects now exclusively handle the publishing and receiving
    of messages. These were formerly done via Topic and Subscription, respectively.
    2. The existing Subscriber class was renamed MessageListener.
4. **gRPC Client Exposure**: As a result of removing handwritten admin operations, `TopicAdmin::Client`, `SubscriptionAdmin::Client`
and `SchemaService::Client` are now accessible directly from `Google::Cloud::PubSub::Project`.

## Legacy Support

The existing `google-cloud-pubsub` (henceforth known as the v2 library) will be supported for one year from when the `google-cloud-pubsub` v3
is released, giving developers proper time to migrate. Features will be prioritized in the new library, while still providing security and
bug fixes in v2.

## Data Plane Operations: Publishing and Receiving Messages

In the new version of the library, publishing and receiving messages are handled separately from managing resources.

### Publishing messages

Previously, publishing was performed by retrieving a Topic object and calling publish on it. This is now done by performing the
same action on a Publisher.

```ruby
# Before
pubsub = Google::Cloud::Pubsub.new project_id: project_id

topic = pubsub.topic "my-topic"

topic.publish "This is a test message."
```

```ruby
# After
pubsub = Google::Cloud::Pubsub.new project_id: project_id

publisher = pubsub.publisher "my-topic"

publisher.publish "This is a test message."
```


### Receiving Messages

Similarly, a Subscription object no longer manages receiving messages; that action is now performed by a Subscriber.

```ruby
# Before
pubsub = Google::Cloud::PubSub.new project_id: project_id

subscription = pubsub.subscription "my-topic-sub"

subscriber = subscription.listen do |received_message|
  puts "Message: #{received_message.message.data}"
  received_message.acknowledge!
end

subscriber.start

```

```ruby
# After
pubsub = Google::Cloud::PubSub.new project_id: project_id

subscriber = pubsub.subscriber "my-topic-sub"

listener = subscriber.listen do |received_message|
  puts "Message: #{received_message.message.data}"
  received_message.acknowledge!
end

listener.start
```

## Admin Plane Operations: Managing Resources

With the removal of all hand-written resource management methods, users will now rely on using the auto-generated gRPC clients for all administrative tasks.

The following tables provide a mapping from the v2 methods to their v3 equivalents. The methods are categorized based on their former
class structure (`Topic`, `Subscription`, `Schema`, and `Project`) for easier reference.

### Topic

| v2 Method | v3 Method |
| --------- | --------- |
| name   | TopicAdmin::Client.get_topic |
| labels | TopicAdmin::Client.get_topic |
| labels= | TopicAdmin::Client.update_topic |
| kms_key | TopicAdmin::Client.get_topic |
| kms_key= | TopicAdmin::Client.update_topic |
| persistance_regions | TopicAdmin::Client.get_topic |
| persistance_regions= | TopicAdmin::Client.update_topic |
| schema_name	| TopicAdmin::Client.get_topic |
| message_encoding	| TopicAdmin::Client.get_topic |
| retention	| TopicAdmin::Client.get_topic |
| retention=	| TopicAdmin::Client.update_topic |
| delete	| TopicAdmin::Client.delete_topic |
| subscribe	| SubscriptionAdmin::Client.create_subscription |
| subscription	| SubscriptionAdmin::Client.get_subscription |
| subscriptions	| SubscriptionAdmin::Client.list_topic_subscriptions |


### Subscription
| v2 Method | v3 Method |
| --------- | --------- |
| name | SubscriptionAdmin::Client.get_subscription |
| topic	| TopicAdmin::Client.get_topic |
| deadline | SubscriptionAdmin::Client.get_subscription |
| deadline=	| SubscriptionAdmin::Client.update_subscription |
| retain_acked	| SubscriptionAdmin::Client.get_subscription |
| retain_acked=	| SubscriptionAdmin::Client.update_subscription |
| retention	| SubscriptionAdmin::Client.get_subscription(message_retention_duration) |
| retention=	| SubscriptionAdmin::Client.update_subscription |
| topic_retention	| SubscriptionAdmin::Client.get_subscription(topic_message_retention_duration) |
| endpoint	| SubscriptionAdmin::Client.get_subscription(push_config.push_endpoint) |
| endpoint=	| SubscriptionAdmin::Client.modify_push_config |
| push_config	| SubscriptionAdmin::Client.update_subscription |
| bigquery_config	| SubscriptionAdmin::Client.update_subscription |
| labels	| SubscriptionAdmin::Client.get_subscription(labels) |
| labels=	| SubscriptionAdmin::Client.update_subscription |
| expires_in	| SubscriptionAdmin::Client.get_subscription(expiration_policy) |
| expires_in=	| SubscriptionAdmin::Client.update_subscription |
| filter	| SubscriptionAdmin::Client.get_subscription(filter) |
| dead_letter_topic |	SubscriptionAdmin::Client.get_subscription **then** TopicAdmin::Client.get_topic |
| dead_letter_topic=	| SubscriptionAdmin::Client.update_subscription |
| dead_letter_max_delivery_attempts	| SubscriptionAdmin::Client.get_subscription(dead_letter_policy) |
| dead_letter_max_delivery_attempts=	| SubscriptionAdmin::Client.update_subscription |
| remove_dead_letter_policy	| SubscriptionAdmin::Client.update_subscription |
| retry_policy	| SubscriptionAdmin::Client.get_subscription(retry_policy) |
| retry_policy=	| SubscriptionAdmin::Client.update_subscription |
| message_ordering?	| SubscriptionAdmin::Client.get_subscription(enable_message_ordering) |
| detached?	| SubscriptionAdmin::Client.get_subscription(detached) |
| delete	| SubscriptionAdmin::Client.delete_subscription |
| detach	| TopicAdmin::Client.detach_subscription |
| acknowledge	| SubscriptionAdmin::Client.acknowledge |
| modify_ack_deadline	| SubscriptionAdmin::Client.modify_ack_deadline |
| create_snapshot	| SubscriptionAdmin::Client.create_snapshot |
| seek	| SubscriptionAdmin::Client.seek |

### Schema

| v2 Method | v3 Method |
| --------- | --------- |
| name | SchemaAdminClient.get_schema |
| type | SchemaAdminClient.get_schema |
| definition | SchemaAdminClient.get_schema |
| revision_id | SchemaAdminClient.get_schema |
| validate_message | SchemaAdminClient.validate_message |
| delete | SchemaAdminClient.delete_schema |
| commit | SchemaAdminClient.commit_schema |
| resource_full? | SchemaAdminClient.get_schema |


### Project
| v2 Method | v3 Method |
| --------- | --------- |
| topic | TopicAdminClient.get_topic |
| create_topic | TopicAdminClient.create_topic |
| topics | TopicAdminClient.list_topics |
| subscription | SubscriptionAdminClient.get_subscription |
| subscriptions | SubscriptionAdminClient.list_subscriptions |
| snapshots | SubscriptionAdminClient.list_snapshots |
| schema | SchemaClient.get_schema |
| create_schema | SchemaClient.create_schema |
| schemas | SchemaClient.list_schemas |
| valid_schema? | SchemaClient.validate_schema |
