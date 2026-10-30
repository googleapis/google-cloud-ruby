# Copyright 2016 Google LLC
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


require "google/cloud/errors"
require "google/cloud/pubsub/credentials"
require "google/cloud/pubsub/convert"
require "google/cloud/pubsub/version"
require "google/cloud/pubsub/v1"
require "google/cloud/pubsub/admin_clients"
require "google/cloud/pubsub/internal_logger"
require "securerandom"

module Google
  module Cloud
    module PubSub
      ##
      # @private Represents the Pub/Sub service API, including IAM mixins.
      class Service
        attr_accessor :project
        attr_accessor :credentials
        attr_accessor :host
        attr_accessor :timeout
        ###
        # The same client_id is used across all streaming pull connections that are created by this client. This is
        # intentional, as it indicates to the server that any guarantees, such as message ordering, made for a stream
        # that is disconnected will be made for the stream that is created to replace it. The attr_accessor allows the
        # value to be replaced for unit testing.
        attr_accessor :client_id

        attr_reader :universe_domain

        ##
        # @private The InternalLogger object.
        attr_reader :internal_logger

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil, universe_domain: nil, logger: nil
          @project = project
          @credentials = credentials
          @host = host
          @timeout = timeout
          @client_id = SecureRandom.uuid.freeze
          @universe_domain = universe_domain || ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] || "googleapis.com"
          @logger = logger
          @internal_logger = InternalLogger.new logger
        end

        def subscription_admin
          return mocked_subscription_admin if mocked_subscription_admin
          @subscription_admin ||= SubscriptionAdmin::Client.new do |config|
            config.credentials = credentials if credentials
            override_client_config_timeouts config if timeout
            config.endpoint = host if host
            config.universe_domain = universe_domain
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
            config.logger = @logger if @logger
          end
        end
        attr_accessor :mocked_subscription_admin

        def topic_admin
          return mocked_topic_admin if mocked_topic_admin
          @topic_admin ||= TopicAdmin::Client.new do |config|
            config.credentials = credentials if credentials
            override_client_config_timeouts config if timeout
            config.endpoint = host if host
            config.universe_domain = universe_domain
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
            config.logger = @logger if @logger
          end
        end
        attr_accessor :mocked_topic_admin

        def iam
          return mocked_iam if mocked_iam
          @iam ||= begin
            iam = (@topic_admin || @subscription_admin || @schemas || topic_admin).iam_policy_client
            iam.configure do |config|
              override_client_config_timeouts config if timeout
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::PubSub::VERSION
              config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
              config.logger = @logger if @logger
            end
            iam
          end
        end
        attr_accessor :mocked_iam

        def schemas
          return mocked_schemas if mocked_schemas
          @schemas ||= V1::SchemaService::Client.new do |config|
            config.credentials = credentials if credentials
            override_client_config_timeouts config if timeout
            config.endpoint = host if host
            config.universe_domain = universe_domain
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::PubSub::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
            config.logger = @logger if @logger
          end
        end
        attr_accessor :mocked_schemas

        ##
        # Adds one or more messages to the topic.
        # Raises GRPC status code 5 if the topic does not exist.
        # The messages parameter is an array of arrays.
        # The first element is the data, second is attributes hash.
        def publish topic, messages, compress: false, call_options: nil, attempt_handle: nil
          request = { topic: topic_path(topic), messages: messages }
          options = build_publish_call_options compress: compress,
                                               call_options: call_options,
                                               attempt_handle: attempt_handle
          prev_handle = Thread.current[TopicAdmin::Client::THREAD_ATTEMPT_HANDLE_KEY]
          Thread.current[TopicAdmin::Client::THREAD_ATTEMPT_HANDLE_KEY] = attempt_handle
          begin
            if options
              topic_admin.publish_internal request, options
            else
              topic_admin.publish_internal request
            end
          ensure
            attempt_handle&.clear_operation
            Thread.current[TopicAdmin::Client::THREAD_ATTEMPT_HANDLE_KEY] = prev_handle
          end
        end

        ##
        # @private Returns the effective publish RPC timeout in seconds.
        def publish_timeout
          return @timeout if @timeout
          if @topic_admin.respond_to? :configure
            cfg = @topic_admin.configure
            if cfg.respond_to?(:rpcs) && cfg.rpcs.respond_to?(:publish) && cfg.rpcs.publish.timeout
              return cfg.rpcs.publish.timeout
            end
            return cfg.timeout if cfg.respond_to?(:timeout) && cfg.timeout
          end
          V1::TopicAdmin::Client.configure.rpcs.publish.timeout ||
            V1::TopicAdmin::Client.configure.timeout ||
            60.0
        end

        ##
        # Pulls a single message from the server.
        def pull subscription, options = {}
          max_messages = options.fetch(:max, 100).to_i
          return_immediately = !(!options.fetch(:immediate, true))

          subscription_admin.pull_internal subscription: subscription_path(subscription, options),
                                           max_messages: max_messages,
                                           return_immediately: return_immediately
        end

        def streaming_pull request_enum, options = {}
          subscription_admin.streaming_pull_internal request_enum, options
        end

        ##
        # Acknowledges receipt of a message.
        def acknowledge subscription, *ack_ids
          internal_logger.log_ack_nack ack_ids, "ack"
          subscription_admin.acknowledge_internal subscription: subscription_path(subscription),
                                                  ack_ids: ack_ids
        end

        ##
        # Modifies the ack deadline for a specific message.
        def modify_ack_deadline subscription, ids, deadline
          if deadline.zero?
            internal_logger.log_ack_nack Array(ids), "nack"
          end
          subscription_admin.modify_ack_deadline_internal subscription: subscription_path(subscription),
                                                          ack_ids: Array(ids),
                                                          ack_deadline_seconds: deadline
        end

        # Helper methods

        def project_path options = {}
          project_name = options[:project] || project
          "projects/#{project_name}"
        end

        def topic_path topic_name, options = {}
          return topic_name if topic_name.to_s.include? "/"
          "#{project_path options}/topics/#{topic_name}"
        end

        def subscription_path subscription_name, options = {}
          return subscription_name if subscription_name.to_s.include? "/"
          "#{project_path options}/subscriptions/#{subscription_name}"
        end

        def snapshot_path snapshot_name, options = {}
          return snapshot_name if snapshot_name.nil? || snapshot_name.to_s.include?("/")
          "#{project_path options}/snapshots/#{snapshot_name}"
        end

        def schema_path schema_name, options = {}
          return schema_name if schema_name.nil? || schema_name.to_s.include?("/")
          "#{project_path options}/schemas/#{schema_name}"
        end

        protected

        # Set the timeout in the client config.
        # Override the default timeout in each individual RPC config as well, since when they are non-nil, these
        # defaults have precedence over the top-level config.timeout. See Gapic::CallOptions#apply_defaults.
        def override_client_config_timeouts config
          config.timeout = timeout
          rpc_names = config.rpcs.methods - Object.methods
          rpc_names.each do |rpc_name|
            rpc = config.rpcs.send rpc_name
            rpc.timeout = timeout if rpc.respond_to? :timeout=
          end
        end

        def build_publish_call_options compress: false, call_options: nil, attempt_handle: nil
          return nil if !compress && call_options.nil? && attempt_handle.nil?

          opts_hash = call_options.respond_to?(:to_h) ? call_options.to_h : {}
          metadata = (opts_hash[:metadata] || {}).dup
          metadata[:"grpc-internal-encoding-request"] = "gzip" if compress

          retry_policy = resolve_retry_policy opts_hash[:retry_policy], attempt_handle

          ::Gapic::CallOptions.new(
            timeout: opts_hash[:timeout],
            metadata: metadata.empty? ? nil : metadata,
            retry_policy: retry_policy
          )
        end

        def resolve_retry_policy raw_retry_policy, attempt_handle
          return raw_retry_policy if attempt_handle.nil?
          return raw_retry_policy if raw_retry_policy.is_a? TopicAdmin::CancellableRetryPolicy

          if raw_retry_policy.is_a? Hash
            TopicAdmin::CancellableRetryPolicy.new attempt_handle: attempt_handle, **raw_retry_policy
          elsif raw_retry_policy.nil?
            TopicAdmin::CancellableRetryPolicy.new attempt_handle: attempt_handle
          else
            raw_retry_policy
          end
        end
      end
    end
    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
