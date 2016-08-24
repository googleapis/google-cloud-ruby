# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/spanner/admin/instance/v1/spanner_instance_admin.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/spanner/admin/instance/v1/spanner_instance_admin_services_pb"

module Google
  module Cloud
    module Spanner
      module Admin
        module Instance
          module V1
            # Cloud Spanner Instance Admin API
            #
            # The Cloud Spanner Instance Admin API can be used to create, delete,
            # modify and list instances. Instances are dedicated Cloud Spanner serving
            # and storage resources to be used by Cloud Spanner databases.
            #
            # Each instance has a "configuration", which dictates where the
            # serving resources for the Cloud Spanner instance are located (e.g.,
            # US-central, Europe). Configurations are created by Google based on
            # resource availability.
            #
            # Cloud Spanner billing is based on the instances that exist and their
            # sizes. After an instance exists, there are no additional
            # per-database or per-operation charges for use of the instance
            # (though there may be additional network bandwidth charges).
            # Instances offer isolation: problems with databases in one instance
            # will not affect other instances. However, within an instance
            # databases can affect each other. For example, if one database in an
            # instance receives a lot of requests and consumes most of the
            # instance resources, fewer resources are available for other
            # databases in that instance, and their performance may suffer.
            #
            # @!attribute [r] stub
            #   @return [Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub]
            class InstanceAdminApi
              attr_reader :stub

              # The default address of the service.
              SERVICE_ADDRESS = "wrenchworks.googleapis.com".freeze

              # The default port of the service.
              DEFAULT_SERVICE_PORT = 443

              CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

              DEFAULT_TIMEOUT = 30

              PAGE_DESCRIPTORS = {
                "list_instance_configs" => Google::Gax::PageDescriptor.new(
                  "page_token",
                  "next_page_token",
                  "instance_configs"),
                "list_instances" => Google::Gax::PageDescriptor.new(
                  "page_token",
                  "next_page_token",
                  "instances")
              }.freeze

              private_constant :PAGE_DESCRIPTORS

              # The scopes needed to make gRPC calls to all of the methods defined in
              # this service.
              ALL_SCOPES = [
                "https://www.googleapis.com/auth/cloud-platform",
                "https://www.googleapis.com/auth/spanner.admin"
              ].freeze

              PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}"
              )

              private_constant :PROJECT_PATH_TEMPLATE

              INSTANCE_CONFIG_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}/instanceConfigs/{instance_config}"
              )

              private_constant :INSTANCE_CONFIG_PATH_TEMPLATE

              INSTANCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}/instances/{instance}"
              )

              private_constant :INSTANCE_PATH_TEMPLATE

              # Returns a fully-qualified project resource name string.
              # @param project [String]
              # @return [String]
              def self.project_path project
                PROJECT_PATH_TEMPLATE.render(
                  :"project" => project
                )
              end

              # Returns a fully-qualified instance_config resource name string.
              # @param project [String]
              # @param instance_config [String]
              # @return [String]
              def self.instance_config_path project, instance_config
                INSTANCE_CONFIG_PATH_TEMPLATE.render(
                  :"project" => project,
                  :"instance_config" => instance_config
                )
              end

              # Returns a fully-qualified instance resource name string.
              # @param project [String]
              # @param instance [String]
              # @return [String]
              def self.instance_path project, instance
                INSTANCE_PATH_TEMPLATE.render(
                  :"project" => project,
                  :"instance" => instance
                )
              end

              # Parses the project from a project resource.
              # @param project_name [String]
              # @return [String]
              def self.match_project_from_project_name project_name
                PROJECT_PATH_TEMPLATE.match(project_name)["project"]
              end

              # Parses the project from a instance_config resource.
              # @param instance_config_name [String]
              # @return [String]
              def self.match_project_from_instance_config_name instance_config_name
                INSTANCE_CONFIG_PATH_TEMPLATE.match(instance_config_name)["project"]
              end

              # Parses the instance_config from a instance_config resource.
              # @param instance_config_name [String]
              # @return [String]
              def self.match_instance_config_from_instance_config_name instance_config_name
                INSTANCE_CONFIG_PATH_TEMPLATE.match(instance_config_name)["instance_config"]
              end

              # Parses the project from a instance resource.
              # @param instance_name [String]
              # @return [String]
              def self.match_project_from_instance_name instance_name
                INSTANCE_PATH_TEMPLATE.match(instance_name)["project"]
              end

              # Parses the instance from a instance resource.
              # @param instance_name [String]
              # @return [String]
              def self.match_instance_from_instance_name instance_name
                INSTANCE_PATH_TEMPLATE.match(instance_name)["instance"]
              end

              # @param service_path [String]
              #   The domain name of the API remote host.
              # @param port [Integer]
              #   The port on which to connect to the remote host.
              # @param channel [Channel]
              #   A Channel object through which to make calls.
              # @param chan_creds [Grpc::ChannelCredentials]
              #   A ChannelCredentials for the setting up the RPC client.
              # @param client_config[Hash]
              #   A Hash for call options for each method. See
              #   Google::Gax#construct_settings for the structure of
              #   this data. Falls back to the default config if not specified
              #   or the specified config is missing data points.
              # @param timeout [Numeric]
              #   The default timeout, in seconds, for calls made through this client.
              # @param app_name [String]
              #   The codename of the calling service.
              # @param app_version [String]
              #   The version of the calling service.
              def initialize \
                  service_path: SERVICE_ADDRESS,
                  port: DEFAULT_SERVICE_PORT,
                  channel: nil,
                  chan_creds: nil,
                  scopes: ALL_SCOPES,
                  client_config: {},
                  timeout: DEFAULT_TIMEOUT,
                  app_name: "gax",
                  app_version: Google::Gax::VERSION
                google_api_client = "#{app_name}/#{app_version} " \
                  "#{CODE_GEN_NAME_VERSION} ruby/#{RUBY_VERSION}".freeze
                headers = { :"x-goog-api-client" => google_api_client }
                client_config_file = Pathname.new(__dir__).join(
                  "instance_admin_client_config.json"
                )
                defaults = client_config_file.open do |f|
                  Google::Gax.construct_settings(
                    "google.spanner.admin.instance.v1.InstanceAdmin",
                    JSON.parse(f.read),
                    client_config,
                    Google::Gax::Grpc::STATUS_CODE_NAMES,
                    timeout,
                    page_descriptors: PAGE_DESCRIPTORS,
                    errors: Google::Gax::Grpc::API_ERRORS,
                    kwargs: headers
                  )
                end
                @stub = Google::Gax::Grpc.create_stub(
                  service_path,
                  port,
                  chan_creds: chan_creds,
                  channel: channel,
                  scopes: scopes,
                  &Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.method(:new)
                )

                @list_instance_configs = Google::Gax.create_api_call(
                  @stub.method(:list_instance_configs),
                  defaults["list_instance_configs"]
                )
                @get_instance_config = Google::Gax.create_api_call(
                  @stub.method(:get_instance_config),
                  defaults["get_instance_config"]
                )
                @list_instances = Google::Gax.create_api_call(
                  @stub.method(:list_instances),
                  defaults["list_instances"]
                )
                @get_instance = Google::Gax.create_api_call(
                  @stub.method(:get_instance),
                  defaults["get_instance"]
                )
                @create_instance = Google::Gax.create_api_call(
                  @stub.method(:create_instance),
                  defaults["create_instance"]
                )
                @update_instance = Google::Gax.create_api_call(
                  @stub.method(:update_instance),
                  defaults["update_instance"]
                )
                @delete_instance = Google::Gax.create_api_call(
                  @stub.method(:delete_instance),
                  defaults["delete_instance"]
                )
              end

              # Service calls

              # Lists the supported instance configurations for a given project.
              #
              # @param name [String]
              #   The name of the project for which a list of supported instance
              #   configurations is requested. Values are of the form
              #   +projects/<project>+.
              # @param page_size [Integer]
              #   The maximum number of resources contained in the underlying API
              #   response. If page streaming is performed per-resource, this
              #   parameter does not affect the return value. If page streaming is
              #   performed per-page, this determines the maximum number of
              #   resources in a page.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::PagedEnumerable<Google::Spanner::Admin::Instance::V1::InstanceConfig>]
              #   An enumerable of Google::Spanner::Admin::Instance::V1::InstanceConfig instances.
              #   See Google::Gax::PagedEnumerable documentation for other
              #   operations such as per-page iteration or access to the response
              #   object.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def list_instance_configs \
                  name,
                  page_size: nil,
                  options: nil
                req = Google::Spanner::Admin::Instance::V1::ListInstanceConfigsRequest.new(
                  name: name
                )
                req.page_size = page_size unless page_size.nil?
                @list_instance_configs.call(req, options)
              end

              # Gets information about a particular instance configuration.
              #
              # @param name [String]
              #   The name of the requested instance configuration. Values are of the form
              #   +projects/<project>/instanceConfigs/<config>+.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Spanner::Admin::Instance::V1::InstanceConfig]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def get_instance_config \
                  name,
                  options: nil
                req = Google::Spanner::Admin::Instance::V1::GetInstanceConfigRequest.new(
                  name: name
                )
                @get_instance_config.call(req, options)
              end

              # Lists all instances in the given project.
              #
              # @param name [String]
              #   The name of the project for which a list of instances is
              #   requested. Values are of the form +projects/<project>+.
              # @param page_size [Integer]
              #   The maximum number of resources contained in the underlying API
              #   response. If page streaming is performed per-resource, this
              #   parameter does not affect the return value. If page streaming is
              #   performed per-page, this determines the maximum number of
              #   resources in a page.
              # @param filter [String]
              #   An expression for filtering the results of the request. Filter rules are
              #   case insensitive. The fields eligible for filtering are:
              #
              #     * name
              #     * display_name
              #     * labels.key where key is the name of a label
              #
              #   Some examples of using filters are:
              #
              #     * name:* --> The instance has a name.
              #     * name:Howl --> The instance's name is howl.
              #     * name:HOWL --> Equivalent to above.
              #     * NAME:howl --> Equivalent to above.
              #     * labels.env:* --> The instance has the label env.
              #     * labels.env:dev --> The instance's label env has the value dev.
              #     * name:howl labels.env:dev --> The instance's name is howl and it has
              #                                    the label env with value dev.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::PagedEnumerable<Google::Spanner::Admin::Instance::V1::Instance>]
              #   An enumerable of Google::Spanner::Admin::Instance::V1::Instance instances.
              #   See Google::Gax::PagedEnumerable documentation for other
              #   operations such as per-page iteration or access to the response
              #   object.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def list_instances \
                  name,
                  filter,
                  page_size: nil,
                  options: nil
                req = Google::Spanner::Admin::Instance::V1::ListInstancesRequest.new(
                  name: name,
                  filter: filter
                )
                req.page_size = page_size unless page_size.nil?
                @list_instances.call(req, options)
              end

              # Gets information about a particular instance.
              #
              # @param name [String]
              #   The name of the requested instance. Values are of the form
              #   +projects/<project>/instances/<instance>+.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Spanner::Admin::Instance::V1::Instance]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def get_instance \
                  name,
                  options: nil
                req = Google::Spanner::Admin::Instance::V1::GetInstanceRequest.new(
                  name: name
                )
                @get_instance.call(req, options)
              end

              # Creates an instance and begins preparing it to begin serving. The
              # returned Long-running operation
              # can be used to track the progress of preparing the new
              # instance. The instance name is assigned by the caller. If the
              # named instance already exists, +CreateInstance+ returns
              # +ALREADY_EXISTS+.
              #
              # Immediately upon completion of this request:
              #
              #   * The instance is readable via the API, with all requested attributes
              #     but no allocated resources. Its state is +CREATING+.
              #
              # Until completion of the returned operation:
              #
              #   * Cancelling the operation renders the instance immediately unreadable
              #     via the API.
              #   * The instance can be deleted.
              #   * All other attempts to modify the instance are rejected.
              #
              # Upon completion of the returned operation:
              #
              #   * Billing for all successfully-allocated resources begins (some types
              #     may have lower than the requested levels).
              #   * Databases can be created in the instance.
              #   * The instance's allocated resource levels are readable via the API.
              #   * The instance's state becomes +READY+.
              #
              # The returned operation's
              # Metadata field type is
              # CreateInstanceMetadata
              # The returned operation's
              # Response field type is
              # Instance, if
              # successful.
              #
              # @param name [String]
              #   A unique identifier for the instance, which cannot be changed after
              #   the instance is created. Values are of the form
              #   +projects/<project>/instances/A-z*+
              # @param config [String]
              #   The name of the instance's configuration. Values are of the form
              #   +projects/<project>/instanceConfigs/<configuration>+. See
              #   also InstanceConfig and
              #   ListInstanceConfigs.
              # @param display_name [String]
              #   The descriptive name for this instance as it appears in UIs.
              #   Must be unique per project.
              # @param node_count [Integer]
              #   The number of nodes allocated to this instance.
              # @param state [Google::Spanner::Admin::Instance::V1::Instance::State]
              #   The current instance state. For
              #   CreateInstance, the state must be
              #   either omitted or set to +CREATING+. For
              #   UpdateInstance, the state must be
              #   either omitted or set to +READY+.
              # @param labels [Hash{String => String}]
              #   Cloud Labels are a flexible and lightweight mechanism for organizing cloud
              #   resources into groups that reflect a customer?s organizational needs and
              #   deployment strategies. Cloud Labels can be used to filter collections of
              #   resources. They can be used to control how resource metrics are aggregated.
              #   And they can be used as arguments to policy management rules (e.g. route,
              #   firewall, load balancing, etc.).
              #
              #    * Label keys must be between 1 and 63 characters long and must conform to
              #      the following regular expression: {a-z}[https://cloud.google.com[-a-z0-9]*[a-z0-9]]?.
              #    * Label values must be between 0 and 63 characters long and must conform
              #      to the regular expression ({a-z}[https://cloud.google.com[-a-z0-9]*[a-z0-9]]?)?.
              #    * No more than 64 labels can be associated with a given resource.
              #
              #   See https://goo.gl/xmQnxf for more information on and examples of labels.
              #
              #   If you plan to use labels in your own code, please note that additional
              #   characters may be allowed in the future. And so you are advised to use an
              #   internal label representation, such as JSON, which doesn't rely upon
              #   specific characters being disallowed.  For example, representing labels
              #   as the string:  name + ?_? + value  would prove problematic if we were to
              #   allow ?_? in a future release.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Longrunning::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def create_instance \
                  name,
                  config,
                  display_name,
                  node_count,
                  state,
                  labels,
                  options: nil
                req = Google::Spanner::Admin::Instance::V1::Instance.new(
                  name: name,
                  config: config,
                  display_name: display_name,
                  node_count: node_count,
                  state: state,
                  labels: labels
                )
                @create_instance.call(req, options)
              end

              # Updates an instance, and begins allocating or releasing resources
              # as requested. The returned Long-running
              # operation can be used to track the
              # progress of updating the instance. If the named instance does not
              # exist, returns +NOT_FOUND+.
              #
              # Immediately upon completion of this request:
              #
              #   * For resource types for which a decrease in the instance's allocation
              #     has been requested, billing is based on the newly-requested level.
              #
              # Until completion of the returned operation:
              #
              #   * Cancelling the operation sets its metadata's
              #     Cancel_time, and begins
              #     restoring resources to their pre-request values. The operation
              #     is guaranteed to succeed at undoing all resource changes,
              #     after which point it terminates with a +CANCELLED+ status.
              #   * All other attempts to modify the instance are rejected.
              #   * Reading the instance via the API continues to give the pre-request
              #     resource levels.
              #
              # Upon completion of the returned operation:
              #
              #   * Billing begins for all successfully-allocated resources (some types
              #     may have lower than the requested levels).
              #   * All newly-reserved resources are available for serving the instance's
              #     tables.
              #   * The instance's new resource levels are readable via the API.
              #
              # The returned operation's
              # Metadata field type is
              # UpdateInstanceMetadata
              # The returned operation's
              # Response field type is
              # Instance, if
              # successful.
              #
              # @param name [String]
              #   A unique identifier for the instance, which cannot be changed after
              #   the instance is created. Values are of the form
              #   +projects/<project>/instances/A-z*+
              # @param config [String]
              #   The name of the instance's configuration. Values are of the form
              #   +projects/<project>/instanceConfigs/<configuration>+. See
              #   also InstanceConfig and
              #   ListInstanceConfigs.
              # @param display_name [String]
              #   The descriptive name for this instance as it appears in UIs.
              #   Must be unique per project.
              # @param node_count [Integer]
              #   The number of nodes allocated to this instance.
              # @param state [Google::Spanner::Admin::Instance::V1::Instance::State]
              #   The current instance state. For
              #   CreateInstance, the state must be
              #   either omitted or set to +CREATING+. For
              #   UpdateInstance, the state must be
              #   either omitted or set to +READY+.
              # @param labels [Hash{String => String}]
              #   Cloud Labels are a flexible and lightweight mechanism for organizing cloud
              #   resources into groups that reflect a customer?s organizational needs and
              #   deployment strategies. Cloud Labels can be used to filter collections of
              #   resources. They can be used to control how resource metrics are aggregated.
              #   And they can be used as arguments to policy management rules (e.g. route,
              #   firewall, load balancing, etc.).
              #
              #    * Label keys must be between 1 and 63 characters long and must conform to
              #      the following regular expression: {a-z}[https://cloud.google.com[-a-z0-9]*[a-z0-9]]?.
              #    * Label values must be between 0 and 63 characters long and must conform
              #      to the regular expression ({a-z}[https://cloud.google.com[-a-z0-9]*[a-z0-9]]?)?.
              #    * No more than 64 labels can be associated with a given resource.
              #
              #   See https://goo.gl/xmQnxf for more information on and examples of labels.
              #
              #   If you plan to use labels in your own code, please note that additional
              #   characters may be allowed in the future. And so you are advised to use an
              #   internal label representation, such as JSON, which doesn't rely upon
              #   specific characters being disallowed.  For example, representing labels
              #   as the string:  name + ?_? + value  would prove problematic if we were to
              #   allow ?_? in a future release.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Longrunning::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def update_instance \
                  name,
                  config,
                  display_name,
                  node_count,
                  state,
                  labels,
                  options: nil
                req = Google::Spanner::Admin::Instance::V1::Instance.new(
                  name: name,
                  config: config,
                  display_name: display_name,
                  node_count: node_count,
                  state: state,
                  labels: labels
                )
                @update_instance.call(req, options)
              end

              # Deletes an instance.
              #
              # Immediately upon completion of the request:
              #
              #   * Billing ceases for all of the instance's reserved resources.
              #
              # Soon afterward:
              #
              #   * The instance and *all of its databases* immediately and
              #     irrevocably disappear from the API. All data in the databases
              #     is permanently deleted.
              #
              # @param name [String]
              #   The name of the instance to be deleted. Values are of the form
              #   +projects/<project>/instances/<instance>+
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def delete_instance \
                  name,
                  options: nil
                req = Google::Spanner::Admin::Instance::V1::DeleteInstanceRequest.new(
                  name: name
                )
                @delete_instance.call(req, options)
              end
            end
          end
        end
      end
    end
  end
end
