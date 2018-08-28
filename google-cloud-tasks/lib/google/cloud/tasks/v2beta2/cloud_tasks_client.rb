# Copyright 2018 Google LLC
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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/tasks/v2beta2/cloudtasks.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/cloud/tasks/v2beta2/cloudtasks_pb"
require "google/cloud/tasks/v2beta2/credentials"

module Google
  module Cloud
    module Tasks
      module V2beta2
        # Cloud Tasks allows developers to manage the execution of background
        # work in their applications.
        #
        # @!attribute [r] cloud_tasks_stub
        #   @return [Google::Cloud::Tasks::V2beta2::CloudTasks::Stub]
        class CloudTasksClient
          # @private
          attr_reader :cloud_tasks_stub

          # The default address of the service.
          SERVICE_ADDRESS = "cloudtasks.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_queues" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "queues"),
            "list_tasks" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "tasks")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          QUEUE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/queues/{queue}"
          )

          private_constant :QUEUE_PATH_TEMPLATE

          TASK_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/queues/{queue}/tasks/{task}"
          )

          private_constant :TASK_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified location resource name string.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def self.location_path project, location
            LOCATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location
            )
          end

          # Returns a fully-qualified queue resource name string.
          # @param project [String]
          # @param location [String]
          # @param queue [String]
          # @return [String]
          def self.queue_path project, location, queue
            QUEUE_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"queue" => queue
            )
          end

          # Returns a fully-qualified task resource name string.
          # @param project [String]
          # @param location [String]
          # @param queue [String]
          # @param task [String]
          # @return [String]
          def self.task_path project, location, queue, task
            TASK_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"queue" => queue,
              :"task" => task
            )
          end

          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/tasks/v2beta2/cloudtasks_services_pb"

            credentials ||= Google::Cloud::Tasks::V2beta2::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Tasks::V2beta2::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-tasks'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "cloud_tasks_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.tasks.v2beta2.CloudTasks",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @cloud_tasks_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Tasks::V2beta2::CloudTasks::Stub.method(:new)
            )

            @list_queues = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:list_queues),
              defaults["list_queues"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_queue = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:get_queue),
              defaults["get_queue"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_queue = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:create_queue),
              defaults["create_queue"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_queue = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:update_queue),
              defaults["update_queue"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'queue.name' => request.queue.name}
              end
            )
            @delete_queue = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:delete_queue),
              defaults["delete_queue"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @purge_queue = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:purge_queue),
              defaults["purge_queue"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @pause_queue = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:pause_queue),
              defaults["pause_queue"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @resume_queue = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:resume_queue),
              defaults["resume_queue"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_iam_policy = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:get_iam_policy),
              defaults["get_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @set_iam_policy = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:set_iam_policy),
              defaults["set_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @test_iam_permissions = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:test_iam_permissions),
              defaults["test_iam_permissions"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @list_tasks = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:list_tasks),
              defaults["list_tasks"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_task = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:get_task),
              defaults["get_task"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_task = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:create_task),
              defaults["create_task"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_task = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:delete_task),
              defaults["delete_task"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @lease_tasks = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:lease_tasks),
              defaults["lease_tasks"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @acknowledge_task = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:acknowledge_task),
              defaults["acknowledge_task"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @renew_lease = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:renew_lease),
              defaults["renew_lease"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @cancel_lease = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:cancel_lease),
              defaults["cancel_lease"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @run_task = Google::Gax.create_api_call(
              @cloud_tasks_stub.method(:run_task),
              defaults["run_task"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Lists queues.
          #
          # Queues are returned in lexicographical order.
          #
          # @param parent [String]
          #   Required.
          #
          #   The location name.
          #   For example: +projects/PROJECT_ID/locations/LOCATION_ID+
          # @param filter [String]
          #   +filter+ can be used to specify a subset of queues. Any {Google::Cloud::Tasks::V2beta2::Queue Queue}
          #   field can be used as a filter and several operators as supported.
          #   For example: +<=, <, >=, >, !=, =, :+. The filter syntax is the same as
          #   described in
          #   [Stackdriver's Advanced Logs Filters](https://cloud.google.com/logging/docs/view/advanced_filters).
          #
          #   Sample filter "app_engine_http_target: *".
          #
          #   Note that using filters might cause fewer queues than the
          #   requested_page size to be returned.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Tasks::V2beta2::Queue>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Tasks::V2beta2::Queue>]
          #   An enumerable of Google::Cloud::Tasks::V2beta2::Queue instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   cloud_tasks_client.list_queues(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   cloud_tasks_client.list_queues(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_queues \
              parent,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::ListQueuesRequest)
            @list_queues.call(req, options, &block)
          end

          # Gets a queue.
          #
          # @param name [String]
          #   Required.
          #
          #   The resource name of the queue. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID+
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Queue]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Queue]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #   response = cloud_tasks_client.get_queue(formatted_name)

          def get_queue \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::GetQueueRequest)
            @get_queue.call(req, options, &block)
          end

          # Creates a queue.
          #
          # Queues created with this method allow tasks to live for a maximum of 31
          # days. After a task is 31 days old, the task will be deleted regardless of whether
          # it was dispatched or not.
          #
          # WARNING: Using this method may have unintended side effects if you are
          # using an App Engine +queue.yaml+ or +queue.xml+ file to manage your queues.
          # Read
          # [Overview of Queue Management and queue.yaml](https://cloud.google.com/tasks/docs/queue-yaml)
          # before using this method.
          #
          # @param parent [String]
          #   Required.
          #
          #   The location name in which the queue will be created.
          #   For example: +projects/PROJECT_ID/locations/LOCATION_ID+
          #
          #   The list of allowed locations can be obtained by calling Cloud
          #   Tasks' implementation of
          #   {Google::Cloud::Location::Locations::ListLocations ListLocations}.
          # @param queue [Google::Cloud::Tasks::V2beta2::Queue | Hash]
          #   Required.
          #
          #   The queue to create.
          #
          #   {Google::Cloud::Tasks::V2beta2::Queue#name Queue's name} cannot be the same as an existing queue.
          #   A hash of the same form as `Google::Cloud::Tasks::V2beta2::Queue`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Queue]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Queue]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize +queue+:
          #   queue = {}
          #   response = cloud_tasks_client.create_queue(formatted_parent, queue)

          def create_queue \
              parent,
              queue,
              options: nil,
              &block
            req = {
              parent: parent,
              queue: queue
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::CreateQueueRequest)
            @create_queue.call(req, options, &block)
          end

          # Updates a queue.
          #
          # This method creates the queue if it does not exist and updates
          # the queue if it does exist.
          #
          # Queues created with this method allow tasks to live for a maximum of 31
          # days. After a task is 31 days old, the task will be deleted regardless of whether
          # it was dispatched or not.
          #
          # WARNING: Using this method may have unintended side effects if you are
          # using an App Engine +queue.yaml+ or +queue.xml+ file to manage your queues.
          # Read
          # [Overview of Queue Management and queue.yaml](https://cloud.google.com/tasks/docs/queue-yaml)
          # before using this method.
          #
          # @param queue [Google::Cloud::Tasks::V2beta2::Queue | Hash]
          #   Required.
          #
          #   The queue to create or update.
          #
          #   The queue's {Google::Cloud::Tasks::V2beta2::Queue#name name} must be specified.
          #
          #   Output only fields cannot be modified using UpdateQueue.
          #   Any value specified for an output only field will be ignored.
          #   The queue's {Google::Cloud::Tasks::V2beta2::Queue#name name} cannot be changed.
          #   A hash of the same form as `Google::Cloud::Tasks::V2beta2::Queue`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   A mask used to specify which fields of the queue are being updated.
          #
          #   If empty, then all fields will be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Queue]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Queue]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #
          #   # TODO: Initialize +queue+:
          #   queue = {}
          #   response = cloud_tasks_client.update_queue(queue)

          def update_queue \
              queue,
              update_mask: nil,
              options: nil,
              &block
            req = {
              queue: queue,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::UpdateQueueRequest)
            @update_queue.call(req, options, &block)
          end

          # Deletes a queue.
          #
          # This command will delete the queue even if it has tasks in it.
          #
          # Note: If you delete a queue, a queue with the same name can't be created
          # for 7 days.
          #
          # WARNING: Using this method may have unintended side effects if you are
          # using an App Engine +queue.yaml+ or +queue.xml+ file to manage your queues.
          # Read
          # [Overview of Queue Management and queue.yaml](https://cloud.google.com/tasks/docs/queue-yaml)
          # before using this method.
          #
          # @param name [String]
          #   Required.
          #
          #   The queue name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID+
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #   cloud_tasks_client.delete_queue(formatted_name)

          def delete_queue \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::DeleteQueueRequest)
            @delete_queue.call(req, options, &block)
            nil
          end

          # Purges a queue by deleting all of its tasks.
          #
          # All tasks created before this method is called are permanently deleted.
          #
          # Purge operations can take up to one minute to take effect. Tasks
          # might be dispatched before the purge takes effect. A purge is irreversible.
          #
          # @param name [String]
          #   Required.
          #
          #   The queue name. For example:
          #   +projects/PROJECT_ID/location/LOCATION_ID/queues/QUEUE_ID+
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Queue]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Queue]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #   response = cloud_tasks_client.purge_queue(formatted_name)

          def purge_queue \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::PurgeQueueRequest)
            @purge_queue.call(req, options, &block)
          end

          # Pauses the queue.
          #
          # If a queue is paused then the system will stop dispatching tasks
          # until the queue is resumed via
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::ResumeQueue ResumeQueue}. Tasks can still be added
          # when the queue is paused. A queue is paused if its
          # {Google::Cloud::Tasks::V2beta2::Queue#state state} is {Google::Cloud::Tasks::V2beta2::Queue::State::PAUSED PAUSED}.
          #
          # @param name [String]
          #   Required.
          #
          #   The queue name. For example:
          #   +projects/PROJECT_ID/location/LOCATION_ID/queues/QUEUE_ID+
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Queue]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Queue]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #   response = cloud_tasks_client.pause_queue(formatted_name)

          def pause_queue \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::PauseQueueRequest)
            @pause_queue.call(req, options, &block)
          end

          # Resume a queue.
          #
          # This method resumes a queue after it has been
          # {Google::Cloud::Tasks::V2beta2::Queue::State::PAUSED PAUSED} or
          # {Google::Cloud::Tasks::V2beta2::Queue::State::DISABLED DISABLED}. The state of a queue is stored
          # in the queue's {Google::Cloud::Tasks::V2beta2::Queue#state state}; after calling this method it
          # will be set to {Google::Cloud::Tasks::V2beta2::Queue::State::RUNNING RUNNING}.
          #
          # WARNING: Resuming many high-QPS queues at the same time can
          # lead to target overloading. If you are resuming high-QPS
          # queues, follow the 500/50/5 pattern described in
          # [Managing Cloud Tasks Scaling Risks](https://cloud.google.com/tasks/docs/manage-cloud-task-scaling).
          #
          # @param name [String]
          #   Required.
          #
          #   The queue name. For example:
          #   +projects/PROJECT_ID/location/LOCATION_ID/queues/QUEUE_ID+
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Queue]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Queue]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #   response = cloud_tasks_client.resume_queue(formatted_name)

          def resume_queue \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::ResumeQueueRequest)
            @resume_queue.call(req, options, &block)
          end

          # Gets the access control policy for a {Google::Cloud::Tasks::V2beta2::Queue Queue}.
          # Returns an empty policy if the resource exists and does not have a policy
          # set.
          #
          # Authorization requires the following
          # [Google IAM](https://cloud.google.com/iam) permission on the specified
          # resource parent:
          #
          # * +cloudtasks.queues.getIamPolicy+
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/\\{project}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #   response = cloud_tasks_client.get_iam_policy(formatted_resource)

          def get_iam_policy \
              resource,
              options: nil,
              &block
            req = {
              resource: resource
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
            @get_iam_policy.call(req, options, &block)
          end

          # Sets the access control policy for a {Google::Cloud::Tasks::V2beta2::Queue Queue}. Replaces any existing
          # policy.
          #
          # Note: The Cloud Console does not check queue-level IAM permissions yet.
          # Project-level permissions are required to use the Cloud Console.
          #
          # Authorization requires the following
          # [Google IAM](https://cloud.google.com/iam) permission on the specified
          # resource parent:
          #
          # * +cloudtasks.queues.setIamPolicy+
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being specified.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/\\{project}+.
          # @param policy [Google::Iam::V1::Policy | Hash]
          #   REQUIRED: The complete policy to be applied to the +resource+. The size of
          #   the policy is limited to a few 10s of KB. An empty policy is a
          #   valid policy but certain Cloud Platform services (such as Projects)
          #   might reject them.
          #   A hash of the same form as `Google::Iam::V1::Policy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #
          #   # TODO: Initialize +policy+:
          #   policy = {}
          #   response = cloud_tasks_client.set_iam_policy(formatted_resource, policy)

          def set_iam_policy \
              resource,
              policy,
              options: nil,
              &block
            req = {
              resource: resource,
              policy: policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::SetIamPolicyRequest)
            @set_iam_policy.call(req, options, &block)
          end

          # Returns permissions that a caller has on a {Google::Cloud::Tasks::V2beta2::Queue Queue}.
          # If the resource does not exist, this will return an empty set of
          # permissions, not a {Google::Rpc::Code::NOT_FOUND NOT_FOUND} error.
          #
          # Note: This operation is designed to be used for building permission-aware
          # UIs and command-line tools, not for authorization checking. This operation
          # may "fail open" without warning.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy detail is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/\\{project}+.
          # @param permissions [Array<String>]
          #   The set of permissions to check for the +resource+. Permissions with
          #   wildcards (such as '*' or 'storage.*') are not allowed. For more
          #   information see
          #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::TestIamPermissionsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::TestIamPermissionsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_resource = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #
          #   # TODO: Initialize +permissions+:
          #   permissions = []
          #   response = cloud_tasks_client.test_iam_permissions(formatted_resource, permissions)

          def test_iam_permissions \
              resource,
              permissions,
              options: nil,
              &block
            req = {
              resource: resource,
              permissions: permissions
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::TestIamPermissionsRequest)
            @test_iam_permissions.call(req, options, &block)
          end

          # Lists the tasks in a queue.
          #
          # By default, only the {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC} view is retrieved
          # due to performance considerations;
          # {Google::Cloud::Tasks::V2beta2::ListTasksRequest#response_view response_view} controls the
          # subset of information which is returned.
          #
          # The tasks may be returned in any order. The ordering may change at any
          # time.
          #
          # @param parent [String]
          #   Required.
          #
          #   The queue name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID+
          # @param response_view [Google::Cloud::Tasks::V2beta2::Task::View]
          #   The response_view specifies which subset of the {Google::Cloud::Tasks::V2beta2::Task Task} will be
          #   returned.
          #
          #   By default response_view is {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC}; not all
          #   information is retrieved by default because some data, such as
          #   payloads, might be desirable to return only when needed because
          #   of its large size or because of the sensitivity of data that it
          #   contains.
          #
          #   Authorization for {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL} requires
          #   +cloudtasks.tasks.fullView+ [Google IAM](https://cloud.google.com/iam/)
          #   permission on the {Google::Cloud::Tasks::V2beta2::Task Task} resource.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Tasks::V2beta2::Task>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Tasks::V2beta2::Task>]
          #   An enumerable of Google::Cloud::Tasks::V2beta2::Task instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #
          #   # Iterate over all results.
          #   cloud_tasks_client.list_tasks(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   cloud_tasks_client.list_tasks(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_tasks \
              parent,
              response_view: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              response_view: response_view,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::ListTasksRequest)
            @list_tasks.call(req, options, &block)
          end

          # Gets a task.
          #
          # @param name [String]
          #   Required.
          #
          #   The task name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID+
          # @param response_view [Google::Cloud::Tasks::V2beta2::Task::View]
          #   The response_view specifies which subset of the {Google::Cloud::Tasks::V2beta2::Task Task} will be
          #   returned.
          #
          #   By default response_view is {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC}; not all
          #   information is retrieved by default because some data, such as
          #   payloads, might be desirable to return only when needed because
          #   of its large size or because of the sensitivity of data that it
          #   contains.
          #
          #   Authorization for {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL} requires
          #   +cloudtasks.tasks.fullView+ [Google IAM](https://cloud.google.com/iam/)
          #   permission on the {Google::Cloud::Tasks::V2beta2::Task Task} resource.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Task]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Task]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
          #   response = cloud_tasks_client.get_task(formatted_name)

          def get_task \
              name,
              response_view: nil,
              options: nil,
              &block
            req = {
              name: name,
              response_view: response_view
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::GetTaskRequest)
            @get_task.call(req, options, &block)
          end

          # Creates a task and adds it to a queue.
          #
          # Tasks cannot be updated after creation; there is no UpdateTask command.
          #
          # * For {Google::Cloud::Tasks::V2beta2::AppEngineHttpTarget App Engine queues}, the maximum task size is
          #   100KB.
          # * For {Google::Cloud::Tasks::V2beta2::PullTarget pull queues}, the maximum task size is 1MB.
          #
          # @param parent [String]
          #   Required.
          #
          #   The queue name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID+
          #
          #   The queue must already exist.
          # @param task [Google::Cloud::Tasks::V2beta2::Task | Hash]
          #   Required.
          #
          #   The task to add.
          #
          #   Task names have the following format:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID+.
          #   The user can optionally specify a task {Google::Cloud::Tasks::V2beta2::Task#name name}. If a
          #   name is not specified then the system will generate a random
          #   unique task id, which will be set in the task returned in the
          #   {Google::Cloud::Tasks::V2beta2::Task#name response}.
          #
          #   If {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time} is not set or is in the
          #   past then Cloud Tasks will set it to the current time.
          #
          #   Task De-duplication:
          #
          #   Explicitly specifying a task ID enables task de-duplication.  If
          #   a task's ID is identical to that of an existing task or a task
          #   that was deleted or completed recently then the call will fail
          #   with {Google::Rpc::Code::ALREADY_EXISTS ALREADY_EXISTS}.
          #   If the task's queue was created using Cloud Tasks, then another task with
          #   the same name can't be created for ~1hour after the original task was
          #   deleted or completed. If the task's queue was created using queue.yaml or
          #   queue.xml, then another task with the same name can't be created
          #   for ~9days after the original task was deleted or completed.
          #
          #   Because there is an extra lookup cost to identify duplicate task
          #   names, these {Google::Cloud::Tasks::V2beta2::CloudTasks::CreateTask CreateTask} calls have significantly
          #   increased latency. Using hashed strings for the task id or for
          #   the prefix of the task id is recommended. Choosing task ids that
          #   are sequential or have sequential prefixes, for example using a
          #   timestamp, causes an increase in latency and error rates in all
          #   task commands. The infrastructure relies on an approximately
          #   uniform distribution of task ids to store and serve tasks
          #   efficiently.
          #   A hash of the same form as `Google::Cloud::Tasks::V2beta2::Task`
          #   can also be provided.
          # @param response_view [Google::Cloud::Tasks::V2beta2::Task::View]
          #   The response_view specifies which subset of the {Google::Cloud::Tasks::V2beta2::Task Task} will be
          #   returned.
          #
          #   By default response_view is {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC}; not all
          #   information is retrieved by default because some data, such as
          #   payloads, might be desirable to return only when needed because
          #   of its large size or because of the sensitivity of data that it
          #   contains.
          #
          #   Authorization for {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL} requires
          #   +cloudtasks.tasks.fullView+ [Google IAM](https://cloud.google.com/iam/)
          #   permission on the {Google::Cloud::Tasks::V2beta2::Task Task} resource.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Task]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Task]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #
          #   # TODO: Initialize +task+:
          #   task = {}
          #   response = cloud_tasks_client.create_task(formatted_parent, task)

          def create_task \
              parent,
              task,
              response_view: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              task: task,
              response_view: response_view
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::CreateTaskRequest)
            @create_task.call(req, options, &block)
          end

          # Deletes a task.
          #
          # A task can be deleted if it is scheduled or dispatched. A task
          # cannot be deleted if it has completed successfully or permanently
          # failed.
          #
          # @param name [String]
          #   Required.
          #
          #   The task name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID+
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
          #   cloud_tasks_client.delete_task(formatted_name)

          def delete_task \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::DeleteTaskRequest)
            @delete_task.call(req, options, &block)
            nil
          end

          # Leases tasks from a pull queue for
          # {Google::Cloud::Tasks::V2beta2::LeaseTasksRequest#lease_duration lease_duration}.
          #
          # This method is invoked by the worker to obtain a lease. The
          # worker must acknowledge the task via
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::AcknowledgeTask AcknowledgeTask} after they have
          # performed the work associated with the task.
          #
          # The {Google::Cloud::Tasks::V2beta2::PullMessage#payload payload} is intended to store data that
          # the worker needs to perform the work associated with the task. To
          # return the payloads in the {Google::Cloud::Tasks::V2beta2::LeaseTasksResponse response}, set
          # {Google::Cloud::Tasks::V2beta2::LeaseTasksRequest#response_view response_view} to
          # {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL}.
          #
          # A maximum of 10 qps of {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks}
          # requests are allowed per
          # queue. {Google::Rpc::Code::RESOURCE_EXHAUSTED RESOURCE_EXHAUSTED}
          # is returned when this limit is
          # exceeded. {Google::Rpc::Code::RESOURCE_EXHAUSTED RESOURCE_EXHAUSTED}
          # is also returned when
          # {Google::Cloud::Tasks::V2beta2::RateLimits#max_tasks_dispatched_per_second max_tasks_dispatched_per_second}
          # is exceeded.
          #
          # @param parent [String]
          #   Required.
          #
          #   The queue name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID+
          # @param lease_duration [Google::Protobuf::Duration | Hash]
          #   After the worker has successfully finished the work associated
          #   with the task, the worker must call via
          #   {Google::Cloud::Tasks::V2beta2::CloudTasks::AcknowledgeTask AcknowledgeTask} before the
          #   {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time}. Otherwise the task will be
          #   returned to a later {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks} call so
          #   that another worker can retry it.
          #
          #   The maximum lease duration is 1 week.
          #   +lease_duration+ will be truncated to the nearest second.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
          # @param max_tasks [Integer]
          #   The maximum number of tasks to lease.
          #
          #   The system will make a best effort to return as close to as
          #   +max_tasks+ as possible.
          #
          #   The largest that +max_tasks+ can be is 1000.
          # @param response_view [Google::Cloud::Tasks::V2beta2::Task::View]
          #   The response_view specifies which subset of the {Google::Cloud::Tasks::V2beta2::Task Task} will be
          #   returned.
          #
          #   By default response_view is {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC}; not all
          #   information is retrieved by default because some data, such as
          #   payloads, might be desirable to return only when needed because
          #   of its large size or because of the sensitivity of data that it
          #   contains.
          #
          #   Authorization for {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL} requires
          #   +cloudtasks.tasks.fullView+ [Google IAM](https://cloud.google.com/iam/)
          #   permission on the {Google::Cloud::Tasks::V2beta2::Task Task} resource.
          # @param filter [String]
          #   +filter+ can be used to specify a subset of tasks to lease.
          #
          #   When +filter+ is set to +tag=<my-tag>+ then the
          #   {Google::Cloud::Tasks::V2beta2::LeaseTasksResponse response} will contain only tasks whose
          #   {Google::Cloud::Tasks::V2beta2::PullMessage#tag tag} is equal to +<my-tag>+. +<my-tag>+ must be
          #   less than 500 characters.
          #
          #   When +filter+ is set to +tag_function=oldest_tag()+, only tasks which have
          #   the same tag as the task with the oldest
          #   {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time} will be returned.
          #
          #   Grammar Syntax:
          #
          #   * +filter = "tag=" tag | "tag_function=" function+
          #
          #   * +tag = string+
          #
          #   * +function = "oldest_tag()"+
          #
          #   The +oldest_tag()+ function returns tasks which have the same tag as the
          #   oldest task (ordered by schedule time).
          #
          #   SDK compatibility: Although the SDK allows tags to be either
          #   string or
          #   [bytes](https://cloud.google.com/appengine/docs/standard/java/javadoc/com/google/appengine/api/taskqueue/TaskOptions.html#tag-byte:A-),
          #   only UTF-8 encoded tags can be used in Cloud Tasks. Tag which
          #   aren't UTF-8 encoded can't be used in the
          #   {Google::Cloud::Tasks::V2beta2::LeaseTasksRequest#filter filter} and the task's
          #   {Google::Cloud::Tasks::V2beta2::PullMessage#tag tag} will be displayed as empty in Cloud Tasks.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::LeaseTasksResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::LeaseTasksResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.queue_path("[PROJECT]", "[LOCATION]", "[QUEUE]")
          #
          #   # TODO: Initialize +lease_duration+:
          #   lease_duration = {}
          #   response = cloud_tasks_client.lease_tasks(formatted_parent, lease_duration)

          def lease_tasks \
              parent,
              lease_duration,
              max_tasks: nil,
              response_view: nil,
              filter: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              lease_duration: lease_duration,
              max_tasks: max_tasks,
              response_view: response_view,
              filter: filter
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::LeaseTasksRequest)
            @lease_tasks.call(req, options, &block)
          end

          # Acknowledges a pull task.
          #
          # The worker, that is, the entity that
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks leased} this task must call this method
          # to indicate that the work associated with the task has finished.
          #
          # The worker must acknowledge a task within the
          # {Google::Cloud::Tasks::V2beta2::LeaseTasksRequest#lease_duration lease_duration} or the lease
          # will expire and the task will become available to be leased
          # again. After the task is acknowledged, it will not be returned
          # by a later {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks},
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::GetTask GetTask}, or
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::ListTasks ListTasks}.
          #
          # @param name [String]
          #   Required.
          #
          #   The task name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID+
          # @param schedule_time [Google::Protobuf::Timestamp | Hash]
          #   Required.
          #
          #   The task's current schedule time, available in the
          #   {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time} returned by
          #   {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks} response or
          #   {Google::Cloud::Tasks::V2beta2::CloudTasks::RenewLease RenewLease} response. This restriction is
          #   to ensure that your worker currently holds the lease.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
          #
          #   # TODO: Initialize +schedule_time+:
          #   schedule_time = {}
          #   cloud_tasks_client.acknowledge_task(formatted_name, schedule_time)

          def acknowledge_task \
              name,
              schedule_time,
              options: nil,
              &block
            req = {
              name: name,
              schedule_time: schedule_time
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::AcknowledgeTaskRequest)
            @acknowledge_task.call(req, options, &block)
            nil
          end

          # Renew the current lease of a pull task.
          #
          # The worker can use this method to extend the lease by a new
          # duration, starting from now. The new task lease will be
          # returned in the task's {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time}.
          #
          # @param name [String]
          #   Required.
          #
          #   The task name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID+
          # @param schedule_time [Google::Protobuf::Timestamp | Hash]
          #   Required.
          #
          #   The task's current schedule time, available in the
          #   {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time} returned by
          #   {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks} response or
          #   {Google::Cloud::Tasks::V2beta2::CloudTasks::RenewLease RenewLease} response. This restriction is
          #   to ensure that your worker currently holds the lease.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param lease_duration [Google::Protobuf::Duration | Hash]
          #   Required.
          #
          #   The desired new lease duration, starting from now.
          #
          #
          #   The maximum lease duration is 1 week.
          #   +lease_duration+ will be truncated to the nearest second.
          #   A hash of the same form as `Google::Protobuf::Duration`
          #   can also be provided.
          # @param response_view [Google::Cloud::Tasks::V2beta2::Task::View]
          #   The response_view specifies which subset of the {Google::Cloud::Tasks::V2beta2::Task Task} will be
          #   returned.
          #
          #   By default response_view is {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC}; not all
          #   information is retrieved by default because some data, such as
          #   payloads, might be desirable to return only when needed because
          #   of its large size or because of the sensitivity of data that it
          #   contains.
          #
          #   Authorization for {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL} requires
          #   +cloudtasks.tasks.fullView+ [Google IAM](https://cloud.google.com/iam/)
          #   permission on the {Google::Cloud::Tasks::V2beta2::Task Task} resource.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Task]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Task]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
          #
          #   # TODO: Initialize +schedule_time+:
          #   schedule_time = {}
          #
          #   # TODO: Initialize +lease_duration+:
          #   lease_duration = {}
          #   response = cloud_tasks_client.renew_lease(formatted_name, schedule_time, lease_duration)

          def renew_lease \
              name,
              schedule_time,
              lease_duration,
              response_view: nil,
              options: nil,
              &block
            req = {
              name: name,
              schedule_time: schedule_time,
              lease_duration: lease_duration,
              response_view: response_view
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::RenewLeaseRequest)
            @renew_lease.call(req, options, &block)
          end

          # Cancel a pull task's lease.
          #
          # The worker can use this method to cancel a task's lease by
          # setting its {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time} to now. This will
          # make the task available to be leased to the next caller of
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks}.
          #
          # @param name [String]
          #   Required.
          #
          #   The task name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID+
          # @param schedule_time [Google::Protobuf::Timestamp | Hash]
          #   Required.
          #
          #   The task's current schedule time, available in the
          #   {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time} returned by
          #   {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks} response or
          #   {Google::Cloud::Tasks::V2beta2::CloudTasks::RenewLease RenewLease} response. This restriction is
          #   to ensure that your worker currently holds the lease.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param response_view [Google::Cloud::Tasks::V2beta2::Task::View]
          #   The response_view specifies which subset of the {Google::Cloud::Tasks::V2beta2::Task Task} will be
          #   returned.
          #
          #   By default response_view is {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC}; not all
          #   information is retrieved by default because some data, such as
          #   payloads, might be desirable to return only when needed because
          #   of its large size or because of the sensitivity of data that it
          #   contains.
          #
          #   Authorization for {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL} requires
          #   +cloudtasks.tasks.fullView+ [Google IAM](https://cloud.google.com/iam/)
          #   permission on the {Google::Cloud::Tasks::V2beta2::Task Task} resource.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Task]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Task]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
          #
          #   # TODO: Initialize +schedule_time+:
          #   schedule_time = {}
          #   response = cloud_tasks_client.cancel_lease(formatted_name, schedule_time)

          def cancel_lease \
              name,
              schedule_time,
              response_view: nil,
              options: nil,
              &block
            req = {
              name: name,
              schedule_time: schedule_time,
              response_view: response_view
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::CancelLeaseRequest)
            @cancel_lease.call(req, options, &block)
          end

          # Forces a task to run now.
          #
          # When this method is called, Cloud Tasks will dispatch the task, even if
          # the task is already running, the queue has reached its {Google::Cloud::Tasks::V2beta2::RateLimits RateLimits} or
          # is {Google::Cloud::Tasks::V2beta2::Queue::State::PAUSED PAUSED}.
          #
          # This command is meant to be used for manual debugging. For
          # example, {Google::Cloud::Tasks::V2beta2::CloudTasks::RunTask RunTask} can be used to retry a failed
          # task after a fix has been made or to manually force a task to be
          # dispatched now.
          #
          # The dispatched task is returned. That is, the task that is returned
          # contains the {Google::Cloud::Tasks::V2beta2::Task#status status} after the task is dispatched but
          # before the task is received by its target.
          #
          # If Cloud Tasks receives a successful response from the task's
          # target, then the task will be deleted; otherwise the task's
          # {Google::Cloud::Tasks::V2beta2::Task#schedule_time schedule_time} will be reset to the time that
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::RunTask RunTask} was called plus the retry delay specified
          # in the queue's {Google::Cloud::Tasks::V2beta2::RetryConfig RetryConfig}.
          #
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::RunTask RunTask} returns
          # {Google::Rpc::Code::NOT_FOUND NOT_FOUND} when it is called on a
          # task that has already succeeded or permanently failed.
          #
          # {Google::Cloud::Tasks::V2beta2::CloudTasks::RunTask RunTask} cannot be called on a
          # {Google::Cloud::Tasks::V2beta2::PullMessage pull task}.
          #
          # @param name [String]
          #   Required.
          #
          #   The task name. For example:
          #   +projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID+
          # @param response_view [Google::Cloud::Tasks::V2beta2::Task::View]
          #   The response_view specifies which subset of the {Google::Cloud::Tasks::V2beta2::Task Task} will be
          #   returned.
          #
          #   By default response_view is {Google::Cloud::Tasks::V2beta2::Task::View::BASIC BASIC}; not all
          #   information is retrieved by default because some data, such as
          #   payloads, might be desirable to return only when needed because
          #   of its large size or because of the sensitivity of data that it
          #   contains.
          #
          #   Authorization for {Google::Cloud::Tasks::V2beta2::Task::View::FULL FULL} requires
          #   +cloudtasks.tasks.fullView+ [Google IAM](https://cloud.google.com/iam/)
          #   permission on the {Google::Cloud::Tasks::V2beta2::Task Task} resource.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Tasks::V2beta2::Task]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Tasks::V2beta2::Task]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/tasks"
          #
          #   cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta2)
          #   formatted_name = Google::Cloud::Tasks::V2beta2::CloudTasksClient.task_path("[PROJECT]", "[LOCATION]", "[QUEUE]", "[TASK]")
          #   response = cloud_tasks_client.run_task(formatted_name)

          def run_task \
              name,
              response_view: nil,
              options: nil,
              &block
            req = {
              name: name,
              response_view: response_view
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Tasks::V2beta2::RunTaskRequest)
            @run_task.call(req, options, &block)
          end
        end
      end
    end
  end
end
