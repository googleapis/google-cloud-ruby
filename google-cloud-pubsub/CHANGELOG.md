# Release History

### 2.8.1 / 2021-09-22

#### Bug Fixes

* Change IAM and Schema client metadata hash keys to symbols

#### Documentation

* Fix typo in Emulator guide links

### 2.8.0 / 2021-08-30

#### Features

* Add Pub/Sub topic retention fields
  * Add retention to Project#create_topic
  * Add Topic#retention
  * Add Topic#retention=
  * Add Subscription#topic_retention

### 2.7.1 / 2021-07-08

#### Documentation

* Update AUTHENTICATION.md in handwritten packages

### 2.7.0 / 2021-06-15

#### Features

* Add Publisher Flow Control
  * Add flow_control to async options in Project#create_topic and Project#topic
  * Add FlowControlLimitError

#### Bug Fixes

* Fix Project#schema and #schemas to return full resource
  * Include schema definition in default return values.
  * Fix Schema#definition to return nil instead of empty string when not present.

### 2.6.1 / 2021-04-28

#### Bug Fixes

* Add final flush of pending requests to Subscriber#wait!
  * fix(pubsub): Add final flush of pending requests to Subscriber#wait!

### 2.6.0 / 2021-04-19

#### Features

* Add ordering_key to Topic#publish
  * Add ordering_key to BatchPublisher#publish

#### Documentation

* The immediate: false option is recommended to avoid adverse impacts on the performance of pull operations ([#11153](https://www.github.com/googleapis/google-cloud-ruby/issues/11153))
* Update Subscription#pull docs and samples to recommend immediate: false

### 2.5.0 / 2021-04-01

#### Features

* Add Schema support
  * Add Schema
  * Add Project#create_schema
  * Add Project#schema
  * Add Project#schemas (Schema::List)
  * Add Project#valid_schema?
  * Add schema options to Project#create_topic
  * Add Topic#schema_name
  * Add Topic#message_encoding
  * Add Topic#message_encoding_binary?
  * Add Topic#message_encoding_json?

### 2.4.0 / 2021-03-10

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 2.3.2 / 2021-02-08

#### Bug Fixes

* Fix project option in Project#topic and Project#subscription
  * Ensure that project option is used when skip_lookup is false.
  * Improve documentation of topic_name, subscription_name and snapshot_name.

### 2.3.1 / 2021-01-13

#### Bug Fixes

* Update Subscription#retry_policy=
  * Remove conditional RPC to fetch full resource before update.

### 2.3.0 / 2020-11-18

#### Features

* Add inventory.use_legacy_flow_control to listen options
  * Add inventory.use_legacy_flow_control to Subscription#listen options
  * Add Subscriber#use_legacy_flow_control?

#### Documentation

* Remove EXPERIMENTAL label from RetryPolicy docs

### 2.2.0 / 2020-11-11

#### Features

* Add Subscription#remove_dead_letter_policy

### 2.1.1 / 2020-10-26

#### Documentation

* Update deprecated attribute name limit to max_outstanding_messages

### 2.1.0 / 2020-09-17

#### Features

* quota_project can be set via library configuration ([#7630](https://www.github.com/googleapis/google-cloud-ruby/issues/7630))
* Add push_config (PushConfig) param to Topic#subscribe
  * Make PushConfig constructor public.

#### Documentation

* Update sample code for on_error, at_exit, and concurrency tuning

### 2.0.0 / 2020-08-06

This is a major update that removes the "low-level" client interface code, and
instead adds the new `google-cloud-pubsub-v1` gem as a dependency.
The new dependency is a rewritten low-level client, produced by a next-
generation client code generator, with improved performance and stability.

This change should have no effect on the high-level interface that most users
will use. The one exception is that the (mostly undocumented) `client_config`
argument, for adjusting low-level parameters such as RPC retry settings on
client objects, has been removed. If you need to adjust these parameters, use
the configuration interface in `google-cloud-pubsub-v1`.

Substantial changes have been made in the low-level interfaces, however. If you
are using the low-level classes under the `Google::Cloud::PubSub::V1` module,
please review the docs for the new `google-cloud-pubsub-v1` gem. In
particular:

* Some classes have been renamed, notably the client classes themselves.
* The client constructor takes a configuration block instead of configuration
  keyword arguments.
* All RPC method arguments are now keyword arguments.

### 1.10.0 / 2020-07-23

#### Features

* Add Subscription#detach and #detached?

### 1.9.0 / 2020-07-21

#### Features

* Add support for server-side flow control

### 1.8.0 / 2020-06-29

#### Features

* Add Subscription#filter

### 1.7.1 / 2020-05-28

#### Documentation

* Fix a few broken links

### 1.7.0 / 2020-05-21

#### Features

* Add Retry Policy support
  * Add RetryPolicy
  * Add retry_policy param to Topic#subscribe
  * Add Subscription#retry_policy
  * Add Subscription#retry_policy=
* Set client-scoped UUID in initial StreamingPullRequest#client_id

### 1.6.1 / 2020-05-06

#### Documentation

* Fix example in Emulator documentation
* Remove experimental notice from ReceivedMessage#delivery_attempt
* Wrap example URLs in backticks

### 1.6.0 / 2020-04-06

#### Features

* Add list_topic_snapshots and get_snapshot
  * Add PublisherClient#list_topic_snapshots
  * Add SubscriberClient#get_snapshot

#### Documentation

* Remove a spurious link in the low-level interface documentation.

### 1.5.0 / 2020-03-25

#### Features

* Add max_duration_per_lease_extension to Subscription#listen and Subscriber

### 1.4.0 / 2020-03-11

#### Features

*  Rename Subscriber inventory methods and params
  * Rename Subscriber#inventory_limit to #max_outstanding_messages
  * Rename Subscriber#bytesize to #max_outstanding_bytes
  * Rename Subscriber#extension to #max_total_lease_duration
  * Add deprecated aliases for the original methods
* Support separate project setting for quota/billing

#### Documentation

* Update documentation in the lower-level client

### 1.3.1 / 2020-02-18

#### Bug Fixes

* Move Thread.new to end of AsyncPublisher#initialize

### 1.3.0 / 2020-02-10

#### Features

* Add support for Dead Letter Topics
  * Add `dead_letter_topic` and `dead_letter_max_delivery_attempts` to `Topic#subscribe`
  * Add `Subscription#dead_letter_topic` and `Subscription#dead_letter_topic=`
  * Add `Subscription#dead_letter_max_delivery_attempts` and `Subscription#dead_letter_max_delivery_attempts=`
  * Add `ReceivedMessage#delivery_attempt`

### 1.2.2 / 2020-02-04

#### Performance Improvements

* Add StreamingPullRequest#client_id to the lower-level API

### 1.2.1 / 2020-01-23

#### Documentation

* Update copyright year

### 1.2.0 / 2020-01-09

#### Features

* Add Subscriber inventory settings
  * Add the following settings to Subscriber:
    * Subscriber#inventory_limit
    * Subscriber#inventory_bytesize
    * Subscriber#extension
  * Allow Subscription#listen inventory argument to be a hash.
* Update AsyncPublisher configuration defaults
  * Update AsyncPublisher defaults to the following:
    * max_bytes to 1MB, was 10MB.
    * max_messages to 100, was 1,000.
    * interval to 10 milliseconds, was 250 milliseconds.
    * publish thread count to 2, was 4
    * callback thread count to 4, was 8.

### 1.1.3 / 2019-12-18

#### Bug Fixes

* Fix MonitorMixin usage on Ruby 2.7
  * Ruby 2.7 will error if new_cond is called before super().
  * Make the call to super() be the first call in initialize

### 1.1.2 / 2019-11-19

#### Performance Improvements

* Update network configuration

### 1.1.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

#### Documentation

* Update the list of GCP environments for automatic authentication

### 1.1.0 / 2019-10-23

#### Features

* Add support for Ordering Keys
  * Google Cloud Pub/Sub ordering keys provide the ability to ensure related
    messages are sent to subscribers in the order in which they were published.
    The service guarantees that, for a given ordering key and publisher, messages
    are sent to subscribers in the order in which they were published.
  * Note: At the time of this release, ordering keys are not yet publicly enabled
    and requires special project enablements.
  * Add Google::Cloud::PubSub::Topic#enable_message_ordering! method.
  * Add Google::Cloud::PubSub::Topic#message_ordering? method.
  * Add ordering_key argument to Google::Cloud::PubSub::Topic#publish_async method.
  * Add Google::Cloud::PubSub::Topic#resume_publish method.
  * Add message_ordering argument to Google::Cloud::PubSub::Topic#subscribe method.
  * Add Google::Cloud::PubSub::Subscription#message_ordering? method.
* Update Ruby dependency to minimum of 2.4.

### 1.0.2 / 2019-10-10

#### Bug Fixes

* Fix Subscriber state after releasing messages
  * Correctly reset the Subscriber state when releasing messages
    after the callback either raises an error, or the callback
    fails to call acknowledge or modify_ack_deadline on the
    message. If a Subscriber fills it's inventory, and stops
    pulling additional messages before all the callbacks are
    completed (moves to a paused state) then the Subscriber
    could become stuck in a paused state.
  * A paused Subscriber will now check whether to unpause after
    the callback is completed, instead of when acknowledge or
    modify_ack_deadline is called on the message.

### 1.0.1 / 2019-10-01

#### Bug Fixes

* Fix Subscriber lease issue
  * Fix logic for renewing Subscriber lease for messages.
    * Subscriptions with very low volume would only be renewed once.
    * Now messages will be renewed as many times as it takes until 
* Fix Subscriber lease timing
  * Start the clock for the next lease renewal immediately.
  * This help Subscriptions with a very short deadline not

### 1.0.0 / 2019-09-30

#### Features

* Allow wait to block for specified time
  * Add timeout argument to Subscriber#wait! method.
  * Document timeout argument on AsyncPublisher#wait! method.
* Add stop! convenience method, calling both stop and wait
  * Add Subscriber#stop! method.
  * Add AsyncPublisher#stop! method.

### 0.39.3 / 2019-09-27

#### Bug Fixes

* Fix Subscriber#wait! behavior
  * Fix an issue where the Subscriber#wait! would block
    for only 60 seconds, and not indefinitely.
  * This was introduced in the previous release, 0.39.2.

#### Configuration Changes

* Update Subscriber acknowledge and modify_ack_deadline configuration
  * The acknowledge and modify_ack_deadline RPCs have a lower size
    limit than the other RPCs. Requests larger than 524288 bytes will
    raise invalid argument errors.
* Update low-level client network configuration

### 0.39.2 / 2019-09-17

#### Bug Fixes

* Do not interrupt Subscriber callbacks when stopping
  * Allow in-process callbacks to complete when a Subscriber is stopped.

#### Documentation

* Update Subscriber stop and wait documentation
  * Update Subscriber#stop and Subscriber#wait! method

### 0.39.1 / 2019-09-04

#### Features

* Update Dead Letter Policy
  * Add ReceivedMessage#delivery_attempt
  * Experimental

### 0.39.0 / 2019-08-23

#### Features

* Add Dead Letter Policy to low-level API
  * Add Google::Cloud::PubSub::V1::Subscription#dead_letter_policy
  * Add Google::Cloud::PubSub::V1::DeadLetterPolicy class

#### Documentation

* Update documentation

### 0.38.1 / 2019-08-02

* Add endpoint argument to constructor

### 0.38.0 / 2019-07-31

* Allow persistence_regions to be set
  * Support setting persistence_regions on topic creation
    and topic update.
* Allow Service endpoint to be configured
  * Google::Cloud::PubSub.configure.endpoint
* Fix max threads setting in thread pools
  * Thread pools once again limit the number of threads allocated.
* Reduce thread usage at startup
  * Allocate threads in pool as needed, not all up front
* Update documentation links

### 0.37.1 / 2019-07-09

* Add IAM GetPolicyOptions in the lower-level interface.
* Support overriding service host and port in the low-level interface.
* Fixed race in TimedUnaryBuffer.

### 0.37.0 / 2019-06-17

* Add Topic#persistence_regions
* Subscriber changes
  * Fix potential inventory bug
  * Messages are removed after callback
    * This change prevents the Subscriber inventory from filling up
      when messages are never acked or nacked in the user callback.
      This might happen due to an error in the user callback code.
      Removing a message from the inventory will cause the message to
      be redelivered and reprocessed.
  * Update concurrency implementation
    * Use concurrent-ruby Promises framework.
* Update network configuration
* Enable grpc.service_config_disable_resolution

### 0.36.0 / 2019-05-21

* Add Topic#kms_key
  * Add the Cloud KMS encryption key that will be used to
    protect access to messages published on a topic.
* Updates to the low-level API:
  * Add Topic#kms_key_name (experimental)
  * Snapshots no longer marked beta.
  * Update IAM documentation.

### 0.35.0 / 2019-04-25

* Add Subscription#push_config and Subscription::PushConfig
* Add Subscription#expires_in
* Add Topic#reload!
* Add Subscription#reload!
* Update low-level generated files  
  * Add PushConfig#oidc_token
  * Add ordering_key to PubsubMessage.
  * Add enable_message_ordering to Subscription.
  * Extract gRPC header values from request.
  * Update documentation.

### 0.34.1 / 2019-02-13

* Fix bug (typo) in retrieving default on_error proc.
* Update network configuration.

### 0.34.0 / 2019-02-01

* Switch to use Google::Cloud::PubSub namespace.
* Add PubSub on_error configuration.
* Major updates to Subscriber
  * Add dependency on current-ruby.
  * Updates are now made using unary API calls, not the gRPC stream.
  * Update Subscriber inventory lease mechanics:
    * This change will help avoid race conditions by ensuring that
      inventory lease renewal actions don't override ack/nack/delay
      actions made on a received message via the Subscriber callback.
  * Changes to avoid potential race conditions in updates.
* Add reference?/resource? helper methods:
  * Topic#reference?
  * Topic#resource?
  * Subscription#reference?
  * Subscription#resource?
* Add documentation for methods that will make an API call
  when called on a reference object.
  * Topic#labels
  * Subscription#topic
  * Subscription#deadline
  * Subscription#retain_acked
  * Subscription#retention
  * Subscription#endpoint
  * Subscription#labels
  * Subscription#exists?
  * Subscription#listen (without deadline optional argument)
* Add example code for avoiding API calls to Overview guide.
* Remove the #delay alias for modify_ack_deadline.
  * Users should use the modify_ack_deadline and modify_ack_deadline!
    methods directly instead.
* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.
* Update low level API
  * Add expiration_policy field
  * Numerous updates and fixes to the low-level documentation,
    including fixes for some broken links.i

### 0.33.2 / 2018-10-29

* Rename delay methods to modify_ack_deadline
  * Rename modify_ack_deadling aliases to delay
  * This maintains backwards compatibility

### 0.33.1 / 2018-10-03

* Update connection configuration.
  * Treat Acknowledge as idempotent.

### 0.33.0 / 2018-09-20

* Add support for user labels to Snapshot, Subscription and Topic.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 0.32.2 / 2018-09-12

* Add missing documentation files to package.

### 0.32.1 / 2018-09-10

* Fix issue where client_config was not being used on publisher API calls.
* Update documentation.

### 0.32.0 / 2018-08-14

* Updated Subscriber implementation
  * Revised shutdown mechanics
    * Fixes stop and wait! would hanging indefinitely.
    * Reduce the number of GRPC warnings printed.
  * Added error callbacks to the API
    *  Use error handler to be notified when unhandled errors
       occur on a subscriber's stream thread.
* Documentation updates.

### 0.31.1 / 2018-08-14

* Fix bug in AsyncUnaryPusher,
  * The modify_ack_deadline requests were malformed.

### 0.31.0 / 2018-06-12

* Switch Subscriber to use unary RPC calls for ack/modack.
* Reduce number of String objects that are garbage collected.
* Documentation updates.

### 0.30.2 / 2018-04-02

* Subscriber stability enhancements.
* Subscriber performance enhancements.

### 0.30.1 / 2018-03-08

* Fix Subscriber thread leak.

### 0.30.0 / 2018-02-27

* Support Shared Configuration.
* Fix issue with IAM Policy not refreshing properly.

### 0.29.0 / 2017-12-19

* Update Subscriber's receipt of received messages.
* Refactor Subscriber implementation to fix some threading bugs.
* Update google-gax dependency to 1.0.

### 0.28.1 / 2017-11-21

* Remove warning when connecting to Pub/Sub Emulator.

### 0.28.0 / 2017-11-14

* Add `Google::Cloud::Pubsub::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Update generated low level GAPIC code.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.27.2 / 2017-10-18

* Update documentation

### 0.27.1 / 2017-10-11

* Add keepalive to gRPC connections.
* Update Subscriber Streaming Messages error handling
* Fix link in README

### 0.27.0 / 2017-08-10

This is a major release that offers new functionality. It adds the ability to asynchronously publish batches of messages when a threshold is met (batch message count, total batch size, batch age). It also adds the ability to receive and acknowledge messages via multiple streams.

* Publishing Messages Asynchronously
  * `Topic#publish_async` and `AsyncPublisher` added
  * `AsyncPublisher` can be stopped
  * `PublishResult` object is yielded from `Topic#publish_async`
* Subscriber Streaming Messages
  * `Subscription#listen` changed to return a `Subscriber` object
  * `Subscriber` can open multiple streams to pull messages
  * `Subscriber` must be started to begin streaming messages
  * `Subscriber` can be stopped
  * `Subscriber`'s received messages are leased until acknowledged or rejected
* Other Additions
  * `ReceivedMessage#reject!` method added (aliased as `nack!` and `ignore!`)
  * `Message#published_at` attribute was added
* Removals
  * `Project#publish` method has been removed
  * `Project#subscribe` method has been removed
  * `Project#topic` method argument `autocreate` was removed
  * `Subscription#pull` method argument `autoack` was removed
  * `Subscription#wait_for_messages` method argument `autoack` was removed

### 0.26.0 / 2017-07-11

* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update initialization to raise a better error if project ID is not specified.

### 0.25.0 / 2017-06-01

* Add Snapshot and Subscription#seek.
* Add Subscription#retain_acked and Subscription#retention.
* Update gem spec homepage links.
* Remove memoization of Policy.
* Remove force parameter from Subscription#policy and Topic#policy.
* Remove Policy#deep_dup.
* Configure gRPC max_send_message_length and max_receive_message_length
to accommodate max message size > 4 MB.

### 0.24.0 / 2017-03-31

* Updated documentation
* Updated retry configuration for pull requests
* Automatic retry on `UNAVAILABLE` errors

### 0.23.2 / 2017-03-03

* No public API changes.
* Update GRPC header value sent to the Pub/Sub API.

### 0.23.1 / 2017-03-01

* No public API changes.
* Update GRPC header value sent to the Pub/Sub API.
* Low level API adds new Protobuf types and GAPIC methods.

### 0.23.0 / 2017-02-21

* Add emulator_host parameter
* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.22.0 / 2017-01-26

* Change class names in low-level API (GAPIC)
* Change method parameters in low-level API (GAPIC)
* Add LICENSE to package.

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Pubsub.new
* New constructor argument client_config

### 0.20.1 / 2016-09-02

* Fix an issue with the GRPC client and forked sub-processes

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Pub/Sub service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
