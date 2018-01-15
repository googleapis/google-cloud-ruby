# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google-cloud-pubsub"
require "google/cloud/pubsub/project"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud Pub/Sub
    #
    # Google Cloud Pub/Sub is designed to provide reliable, many-to-many,
    # asynchronous messaging between applications. Publisher applications can
    # send messages to a "topic" and other applications can subscribe to that
    # topic to receive the messages. By decoupling senders and receivers, Google
    # Cloud Pub/Sub allows developers to communicate between independently
    # written applications.
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Your authentication credentials are detected automatically in
    # Google Cloud Platform environments such as Google Compute Engine, Google
    # App Engine and Google Kubernetes Engine. In other environments you can
    # configure authentication easily, either directly in your code or via
    # environment variables. Read more about the options for connecting in the
    # [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # topic.publish "task completed"
    # ```
    #
    # To learn more about Pub/Sub, read the [Google Cloud Pub/Sub Overview
    # ](https://cloud.google.com/pubsub/overview).
    #
    # ## Retrieving Topics
    #
    # A Topic is a named resource to which messages are sent by publishers.
    # A Topic is found by its name. (See {Google::Cloud::Pubsub::Project#topic})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    # topic = pubsub.topic "my-topic"
    # ```
    #
    # ## Creating a Topic
    #
    # A Topic is created from a Project. (See
    # {Google::Cloud::Pubsub::Project#create_topic})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    # topic = pubsub.create_topic "my-topic"
    # ```
    #
    # ## Retrieving Subscriptions
    #
    # A Subscription is a named resource representing the stream of messages
    # from a single, specific Topic, to be delivered to the subscribing
    # application. A Subscription is found by its name. (See
    # {Google::Cloud::Pubsub::Topic#subscription})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # subscription = topic.subscription "my-topic-subscription"
    # puts subscription.name
    # ```
    #
    # ## Creating a Subscription
    #
    # A Subscription is created from a Topic. (See
    # {Google::Cloud::Pubsub::Topic#subscribe} and
    # {Google::Cloud::Pubsub::Project#subscribe})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # sub = topic.subscribe "my-topic-sub"
    # puts sub.name # => "my-topic-sub"
    # ```
    #
    # The subscription can be created that specifies the number of seconds to
    # wait to be acknowledged as well as an endpoint URL to push the messages
    # to:
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # sub = topic.subscribe "my-topic-sub",
    #                       deadline: 120,
    #                       endpoint: "https://example.com/push"
    # ```
    #
    # ## Publishing Messages
    #
    # Messages are published to a topic. Any message published to a topic
    # without a subscription will be lost. Ensure the topic has a subscription
    # before publishing. (See {Google::Cloud::Pubsub::Topic#publish} and
    # {Google::Cloud::Pubsub::Project#publish})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # msg = topic.publish "task completed"
    # ```
    #
    # Messages can also be published with attributes:
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # msg = topic.publish "task completed",
    #                     foo: :bar,
    #                     this: :that
    # ```
    #
    # Messages can also be published in batches asynchronously using
    # `publish_async`. (See {Google::Cloud::Pubsub::Topic#publish_async} and
    # {Google::Cloud::Pubsub::AsyncPublisher})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # topic.publish_async "task completed" do |result|
    #   if result.succeeded?
    #     log_publish_success result.data
    #   else
    #     log_publish_failure result.data, result.error
    #   end
    # end
    #
    # topic.async_publisher.stop.wait!
    # ```
    #
    # Or multiple messages can be published in batches at the same time by
    # passing a block to `publish`. (See
    # {Google::Cloud::Pubsub::BatchPublisher})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # topic = pubsub.topic "my-topic"
    # msgs = topic.publish do |batch|
    #   batch.publish "task 1 completed", foo: :bar
    #   batch.publish "task 2 completed", foo: :baz
    #   batch.publish "task 3 completed", foo: :bif
    # end
    # ```
    #
    # ## Receiving messages
    #
    # Messages can be streamed from a subscription with a subscriber object
    # that is created using `listen`. (See
    # {Google::Cloud::Pubsub::Subscription#listen} and
    # {Google::Cloud::Pubsub::Subscriber})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    #
    # subscriber = sub.listen do |received_message|
    #   # process message
    #   received_message.acknowledge!
    # end
    #
    # # Start background threads that will call the block passed to listen.
    # subscriber.start
    #
    # # Shut down the subscriber when ready to stop receiving messages.
    # subscriber.stop.wait!
    # ```
    #
    # Messages also can be pulled directly in a one-time operation. (See
    # {Google::Cloud::Pubsub::Subscription#pull})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    # received_messages = sub.pull
    # ```
    #
    # A maximum number of messages to pull can be specified:
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    # received_messages = sub.pull max: 10
    # ```
    #
    # ## Acknowledging a Message
    #
    # Messages that are received can be acknowledged in Pub/Sub, marking the
    # message to be removed so it cannot be pulled again.
    #
    # A Message that can be acknowledged is called a ReceivedMessage.
    # ReceivedMessages can be acknowledged one at a time:
    # (See {Google::Cloud::Pubsub::ReceivedMessage#acknowledge!})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    #
    # subscriber = sub.listen do |received_message|
    #   # process message
    #   received_message.acknowledge!
    # end
    #
    # # Start background threads that will call the block passed to listen.
    # subscriber.start
    #
    # # Shut down the subscriber when ready to stop receiving messages.
    # subscriber.stop.wait!
    # ```
    #
    # Or, multiple messages can be acknowledged in a single API call:
    # (See {Google::Cloud::Pubsub::Subscription#acknowledge})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    # received_messages = sub.pull
    # sub.acknowledge received_messages
    # ```
    #
    # ## Modifying a Deadline
    #
    # A message must be acknowledged after it is pulled, or Pub/Sub will mark
    # the message for redelivery. The message acknowledgement deadline can
    # delayed if more time is needed. This will allow more time to process the
    # message before the message is marked for redelivery. (See
    # {Google::Cloud::Pubsub::ReceivedMessage#delay!})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    # subscriber = sub.listen do |received_message|
    #   puts received_message.message.data
    #
    #   # Delay for 2 minutes
    #   received_message.delay! 120
    # end
    #
    # # Start background threads that will call the block passed to listen.
    # subscriber.start
    #
    # # Shut down the subscriber when ready to stop receiving messages.
    # subscriber.stop.wait!
    # ```
    #
    # The message can also be made available for immediate redelivery:
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    # subscriber = sub.listen do |received_message|
    #   puts received_message.message.data
    #
    #   # Mark for redelivery
    #   received_message.reject!
    # end
    #
    # # Start background threads that will call the block passed to listen.
    # subscriber.start
    #
    # # Shut down the subscriber when ready to stop receiving messages.
    # subscriber.stop.wait!
    # ```
    #
    # Multiple messages can be delayed or made available for immediate
    # redelivery: (See {Google::Cloud::Pubsub::Subscription#delay})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    # received_messages = sub.pull
    # sub.delay 120, received_messages
    # ```
    #
    # ## Creating a snapshot and using seek
    #
    # You can create a snapshot to retain the existing backlog on a
    # subscription. The snapshot will hold the messages in the subscription's
    # backlog that are unacknowledged upon the successful completion of the
    # `create_snapshot` operation.
    #
    # Later, you can use `seek` to reset the subscription's backlog to the
    # snapshot.
    #
    # (See {Google::Cloud::Pubsub::Subscription#create_snapshot} and
    # {Google::Cloud::Pubsub::Subscription#seek})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    #
    # snapshot = sub.create_snapshot
    #
    # received_messages = sub.pull
    # sub.acknowledge received_messages
    #
    # sub.seek snapshot
    # ```
    #
    # ## Listening for Messages
    #
    # A subscriber object can be created using `listen`, which streams messages
    # from the backend and processes them as they are received. (See
    # {Google::Cloud::Pubsub::Subscription#listen} and
    # {Google::Cloud::Pubsub::Subscriber})
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    #
    # subscriber = sub.listen do |received_message|
    #   # process message
    #   received_message.acknowledge!
    # end
    #
    # # Start background threads that will call the block passed to listen.
    # subscriber.start
    #
    # # Shut down the subscriber when ready to stop receiving messages.
    # subscriber.stop.wait!
    # ```
    #
    # The subscriber object can be configured to control the number of
    # concurrent streams to open, the number of received messages to be
    # collected, and the number of threads each stream opens for concurrent
    # calls made to handle the received messages.
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new
    #
    # sub = pubsub.subscription "my-topic-sub"
    #
    # subscriber = sub.listen threads: { callback: 16 } do |received_message|
    #   # store the message somewhere before acknowledging
    #   store_in_backend received_message.data # takes a few seconds
    #   received_message.acknowledge!
    # end
    #
    # # Start background threads that will call the block passed to listen.
    # subscriber.start
    # ```
    #
    # ## Working Across Projects
    #
    # All calls to the Pub/Sub service use the same project and credentials
    # provided to the {Google::Cloud#pubsub} method. However, it is common to
    # reference topics or subscriptions in other projects, which can be achieved
    # by using the `project` option. The main credentials must have permissions
    # to the topics and subscriptions in other projects.
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new # my-project
    #
    # # Get a topic in the current project
    # my_topic = pubsub.topic "my-topic"
    # my_topic.name #=> "projects/my-project/topics/my-topic"
    # # Get a topic in another project
    # other_topic = pubsub.topic "other-topic", project: "other-project-id"
    # other_topic.name #=> "projects/other-project-id/topics/other-topic"
    # ```
    #
    # It is possible to create a subscription in the current project that pulls
    # from a topic in another project:
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # pubsub = Google::Cloud::Pubsub.new # my-project
    #
    # # Get a topic in another project
    # topic = pubsub.topic "other-topic", project: "other-project-id"
    # # Create a subscription in the current project that pulls from
    # # the topic in another project
    # sub = topic.subscribe "my-sub"
    # sub.name #=> "projects/my-project/subscriptions/my-sub"
    # sub.topic.name #=> "projects/other-project-id/topics/other-topic"
    # ```
    #
    # ## Using the Google Cloud Pub/Sub Emulator
    #
    # To develop and test your application locally, you can use the [Google
    # Cloud Pub/Sub Emulator](https://cloud.google.com/pubsub/emulator), which
    # provides [local
    # emulation](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/)
    # of the production Google Cloud Pub/Sub environment. You can start the
    # Google Cloud Pub/Sub emulator using the `gcloud` command-line tool.
    #
    # To configure your ruby code to use the emulator, set the
    # `PUBSUB_EMULATOR_HOST` environment variable to the host and port where the
    # emulator is running. The value can be set as an environment variable in
    # the shell running the ruby code, or can be set directly in the ruby code
    # as shown below.
    #
    # ```ruby
    # require "google/cloud/pubsub"
    #
    # # Make Pub/Sub use the emulator
    # ENV["PUBSUB_EMULATOR_HOST"] = "localhost:8918"
    #
    # pubsub = Google::Cloud::Pubsub.new "emulator-project-id"
    #
    # # Get a topic in the current project
    # my_topic = pubsub.new_topic "my-topic"
    # my_topic.name #=> "projects/emulator-project-id/topics/my-topic"
    # ```
    #
    module Pubsub
      ##
      # Creates a new object for connecting to the Pub/Sub service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project_id Project identifier for the Pub/Sub service
      #   you are connecting to. If not present, the default project for the
      #   credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Pubsub::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/pubsub`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      # @param [String] emulator_host Pub/Sub emulator host. Optional.
      #   If the param is nil, uses the value of the `emulator_host` config.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Pubsub::Project]
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud.pubsub
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, emulator_host: nil, project: nil,
                   keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config
        emulator_host ||= configure.emulator_host
        if emulator_host
          return Pubsub::Project.new(
            Pubsub::Service.new(
              project_id, :this_channel_is_insecure,
              host: emulator_host
            )
          )
        end

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Pubsub::Credentials.new credentials, scope: scope
        end

        Pubsub::Project.new(
          Pubsub::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config
          )
        )
      end

      ##
      # Reload pubsub configuration from defaults. For testing.
      # @private
      #
      def self.reload_configuration!
        default_creds = Google::Cloud.credentials_from_env(
          "PUBSUB_CREDENTIALS", "PUBSUB_CREDENTIALS_JSON",
          "PUBSUB_KEYFILE", "PUBSUB_KEYFILE_JSON"
        )

        Google::Cloud.configure.delete! :pubsub
        Google::Cloud.configure.add_config! :pubsub do |config|
          config.add_field! :project_id, ENV["PUBSUB_PROJECT"], match: String
          config.add_alias! :project, :project_id
          config.add_field! :credentials, default_creds,
                            match: [String, Hash, Google::Auth::Credentials]
          config.add_alias! :keyfile, :credentials
          config.add_field! :scope, nil, match: [String, Array]
          config.add_field! :timeout, nil, match: Integer
          config.add_field! :client_config, nil, match: Hash
          config.add_field! :emulator_host, ENV["PUBSUB_EMULATOR_HOST"],
                            match: String
        end
      end

      reload_configuration! unless Google::Cloud.configure.subconfig? :pubsub

      ##
      # Configure the Google Cloud Pubsub library.
      #
      # The following Pubsub configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Pubsub project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Pubsub::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `retries` - (Integer) Number of times to retry requests on server
      #   error.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      # * `emulator_host` - (String) Host name of the emulator. Defaults to
      #   `ENV["PUBSUB_EMULATOR_HOST"]`
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Pubsub library uses.
      #
      def self.configure
        yield Google::Cloud.configure.pubsub if block_given?

        Google::Cloud.configure.pubsub
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.pubsub.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.pubsub.credentials ||
          Google::Cloud.configure.credentials ||
          Pubsub::Credentials.default(scope: scope)
      end
    end
  end
end
