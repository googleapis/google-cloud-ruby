# Release History

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
