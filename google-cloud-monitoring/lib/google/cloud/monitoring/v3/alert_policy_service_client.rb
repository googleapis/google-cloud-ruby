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
# https://github.com/googleapis/googleapis/blob/master/google/monitoring/v3/alert_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/monitoring/v3/alert_service_pb"
require "google/cloud/monitoring/credentials"

module Google
  module Cloud
    module Monitoring
      module V3
        # The AlertPolicyService API is used to manage (list, create, delete,
        # edit) alert policies in Stackdriver Monitoring. An alerting policy is
        # a description of the conditions under which some aspect of your
        # system is considered to be "unhealthy" and the ways to notify
        # people or services about this state. In addition to using this API, alert
        # policies can also be managed through
        # [Stackdriver Monitoring](https://cloud.google.com/monitoring/docs/),
        # which can be reached by clicking the "Monitoring" tab in
        # [Cloud Console](https://console.cloud.google.com/).
        #
        # @!attribute [r] alert_policy_service_stub
        #   @return [Google::Monitoring::V3::AlertPolicyService::Stub]
        class AlertPolicyServiceClient
          attr_reader :alert_policy_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "monitoring.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_alert_policies" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "alert_policies")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/monitoring.read",
            "https://www.googleapis.com/auth/monitoring.write"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          ALERT_POLICY_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/alertPolicies/{alert_policy}"
          )

          private_constant :ALERT_POLICY_PATH_TEMPLATE

          ALERT_POLICY_CONDITION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/alertPolicies/{alert_policy}/conditions/{condition}"
          )

          private_constant :ALERT_POLICY_CONDITION_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified alert_policy resource name string.
          # @param project [String]
          # @param alert_policy [String]
          # @return [String]
          def self.alert_policy_path project, alert_policy
            ALERT_POLICY_PATH_TEMPLATE.render(
              :"project" => project,
              :"alert_policy" => alert_policy
            )
          end

          # Returns a fully-qualified alert_policy_condition resource name string.
          # @param project [String]
          # @param alert_policy [String]
          # @param condition [String]
          # @return [String]
          def self.alert_policy_condition_path project, alert_policy, condition
            ALERT_POLICY_CONDITION_PATH_TEMPLATE.render(
              :"project" => project,
              :"alert_policy" => alert_policy,
              :"condition" => condition
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
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/monitoring/v3/alert_service_services_pb"

            credentials ||= Google::Cloud::Monitoring::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Monitoring::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-monitoring'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "alert_policy_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.monitoring.v3.AlertPolicyService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            @alert_policy_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Monitoring::V3::AlertPolicyService::Stub.method(:new)
            )

            @list_alert_policies = Google::Gax.create_api_call(
              @alert_policy_service_stub.method(:list_alert_policies),
              defaults["list_alert_policies"]
            )
            @get_alert_policy = Google::Gax.create_api_call(
              @alert_policy_service_stub.method(:get_alert_policy),
              defaults["get_alert_policy"]
            )
            @create_alert_policy = Google::Gax.create_api_call(
              @alert_policy_service_stub.method(:create_alert_policy),
              defaults["create_alert_policy"]
            )
            @delete_alert_policy = Google::Gax.create_api_call(
              @alert_policy_service_stub.method(:delete_alert_policy),
              defaults["delete_alert_policy"]
            )
            @update_alert_policy = Google::Gax.create_api_call(
              @alert_policy_service_stub.method(:update_alert_policy),
              defaults["update_alert_policy"]
            )
          end

          # Service calls

          # Lists the existing alerting policies for the project.
          #
          # @param name [String]
          #   The project whose alert policies are to be listed. The format is
          #
          #       projects/[PROJECT_ID]
          #
          #   Note that this field names the parent container in which the alerting
          #   policies to be listed are stored. To retrieve a single alerting policy
          #   by name, use the
          #   {Google::Monitoring::V3::AlertPolicyService::GetAlertPolicy GetAlertPolicy}
          #   operation, instead.
          # @param filter [String]
          #   If provided, this field specifies the criteria that must be met by
          #   alert policies to be included in the response.
          #
          #   For more details, see [sorting and
          #   filtering](/monitoring/api/v3/sorting-and-filtering).
          # @param order_by [String]
          #   A comma-separated list of fields by which to sort the result. Supports
          #   the same set of field references as the +filter+ field. Entries can be
          #   prefixed with a minus sign to sort by the field in descending order.
          #
          #   For more details, see [sorting and
          #   filtering](/monitoring/api/v3/sorting-and-filtering).
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Monitoring::V3::AlertPolicy>]
          #   An enumerable of Google::Monitoring::V3::AlertPolicy instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring/v3"
          #
          #   alert_policy_service_client = Google::Cloud::Monitoring::V3::AlertPolicy.new
          #   formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   alert_policy_service_client.list_alert_policies(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   alert_policy_service_client.list_alert_policies(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_alert_policies \
              name,
              filter: nil,
              order_by: nil,
              page_size: nil,
              options: nil
            req = {
              name: name,
              filter: filter,
              order_by: order_by,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListAlertPoliciesRequest)
            @list_alert_policies.call(req, options)
          end

          # Gets a single alerting policy.
          #
          # @param name [String]
          #   The alerting policy to retrieve. The format is
          #
          #       projects/[PROJECT_ID]/alertPolicies/[ALERT_POLICY_ID]
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Monitoring::V3::AlertPolicy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring/v3"
          #
          #   alert_policy_service_client = Google::Cloud::Monitoring::V3::AlertPolicy.new
          #   formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.alert_policy_path("[PROJECT]", "[ALERT_POLICY]")
          #   response = alert_policy_service_client.get_alert_policy(formatted_name)

          def get_alert_policy \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetAlertPolicyRequest)
            @get_alert_policy.call(req, options)
          end

          # Creates a new alerting policy.
          #
          # @param name [String]
          #   The project in which to create the alerting policy. The format is
          #   +projects/[PROJECT_ID]+.
          #
          #   Note that this field names the parent container in which the alerting
          #   policy will be written, not the name of the created policy. The alerting
          #   policy that is returned will have a name that contains a normalized
          #   representation of this name as a prefix but adds a suffix of the form
          #   +/alertPolicies/[POLICY_ID]+, identifying the policy in the container.
          # @param alert_policy [Google::Monitoring::V3::AlertPolicy | Hash]
          #   The requested alerting policy. You should omit the +name+ field in this
          #   policy. The name will be returned in the new policy, including
          #   a new [ALERT_POLICY_ID] value.
          #   A hash of the same form as `Google::Monitoring::V3::AlertPolicy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Monitoring::V3::AlertPolicy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring/v3"
          #
          #   alert_policy_service_client = Google::Cloud::Monitoring::V3::AlertPolicy.new
          #   formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize +alert_policy+:
          #   alert_policy = {}
          #   response = alert_policy_service_client.create_alert_policy(formatted_name, alert_policy)

          def create_alert_policy \
              name,
              alert_policy,
              options: nil
            req = {
              name: name,
              alert_policy: alert_policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::CreateAlertPolicyRequest)
            @create_alert_policy.call(req, options)
          end

          # Deletes an alerting policy.
          #
          # @param name [String]
          #   The alerting policy to delete. The format is:
          #
          #       projects/[PROJECT_ID]/alertPolicies/[ALERT_POLICY_ID]
          #
          #   For more information, see {Google::Monitoring::V3::AlertPolicy AlertPolicy}.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring/v3"
          #
          #   alert_policy_service_client = Google::Cloud::Monitoring::V3::AlertPolicy.new
          #   formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.alert_policy_path("[PROJECT]", "[ALERT_POLICY]")
          #   alert_policy_service_client.delete_alert_policy(formatted_name)

          def delete_alert_policy \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::DeleteAlertPolicyRequest)
            @delete_alert_policy.call(req, options)
            nil
          end

          # Updates an alerting policy. You can either replace the entire policy with
          # a new one or replace only certain fields in the current alerting policy by
          # specifying the fields to be updated via +updateMask+. Returns the
          # updated alerting policy.
          #
          # @param alert_policy [Google::Monitoring::V3::AlertPolicy | Hash]
          #   Required. The updated alerting policy or the updated values for the
          #   fields listed in +update_mask+.
          #   If +update_mask+ is not empty, any fields in this policy that are
          #   not in +update_mask+ are ignored.
          #   A hash of the same form as `Google::Monitoring::V3::AlertPolicy`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Optional. A list of alerting policy field names. If this field is not
          #   empty, each listed field in the existing alerting policy is set to the
          #   value of the corresponding field in the supplied policy (+alert_policy+),
          #   or to the field's default value if the field is not in the supplied
          #   alerting policy.  Fields not listed retain their previous value.
          #
          #   Examples of valid field masks include +display_name+, +documentation+,
          #   +documentation.content+, +documentation.mime_type+, +user_labels+,
          #   +user_label.nameofkey+, +enabled+, +conditions+, +combiner+, etc.
          #
          #   If this field is empty, then the supplied alerting policy replaces the
          #   existing policy. It is the same as deleting the existing policy and
          #   adding the supplied policy, except for the following:
          #
          #   * The new policy will have the same +[ALERT_POLICY_ID]+ as the former
          #     policy. This gives you continuity with the former policy in your
          #     notifications and incidents.
          #   * Conditions in the new policy will keep their former +[CONDITION_ID]+ if
          #     the supplied condition includes the +name+ field with that
          #     +[CONDITION_ID]+. If the supplied condition omits the +name+ field,
          #     then a new +[CONDITION_ID]+ is created.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Monitoring::V3::AlertPolicy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring/v3"
          #
          #   alert_policy_service_client = Google::Cloud::Monitoring::V3::AlertPolicy.new
          #
          #   # TODO: Initialize +alert_policy+:
          #   alert_policy = {}
          #   response = alert_policy_service_client.update_alert_policy(alert_policy)

          def update_alert_policy \
              alert_policy,
              update_mask: nil,
              options: nil
            req = {
              alert_policy: alert_policy,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::UpdateAlertPolicyRequest)
            @update_alert_policy.call(req, options)
          end
        end
      end
    end
  end
end
