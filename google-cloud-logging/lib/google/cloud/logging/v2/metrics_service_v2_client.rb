# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/logging/v2/logging_metrics.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"

require "google/logging/v2/logging_metrics_pb"
require "google/cloud/logging/credentials"

module Google
  module Cloud
    module Logging
      module V2
        # Service for configuring logs-based metrics.
        #
        # @!attribute [r] metrics_service_v2_stub
        #   @return [Google::Logging::V2::MetricsServiceV2::Stub]
        class MetricsServiceV2Client
          attr_reader :metrics_service_v2_stub

          # The default address of the service.
          SERVICE_ADDRESS = "logging.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_log_metrics" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "metrics")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud-platform.read-only",
            "https://www.googleapis.com/auth/logging.admin",
            "https://www.googleapis.com/auth/logging.read",
            "https://www.googleapis.com/auth/logging.write"
          ].freeze

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          METRIC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/metrics/{metric}"
          )

          private_constant :METRIC_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified metric resource name string.
          # @param project [String]
          # @param metric [String]
          # @return [String]
          def self.metric_path project, metric
            METRIC_PATH_TEMPLATE.render(
              :"project" => project,
              :"metric" => metric
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
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              updater_proc: nil,
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
            require "google/logging/v2/logging_metrics_services_pb"

            if channel || chan_creds || updater_proc
              warn "The `channel`, `chan_creds`, and `updater_proc` parameters will be removed " \
                "on 2017/09/08"
              credentials ||= channel
              credentials ||= chan_creds
              credentials ||= updater_proc
            end
            if service_path != SERVICE_ADDRESS || port != DEFAULT_SERVICE_PORT
              warn "`service_path` and `port` parameters are deprecated and will be removed"
            end

            credentials ||= Google::Cloud::Logging::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Logging::Credentials.new(credentials).updater_proc
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

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.1.0 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "metrics_service_v2_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.logging.v2.MetricsServiceV2",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @metrics_service_v2_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Logging::V2::MetricsServiceV2::Stub.method(:new)
            )

            @list_log_metrics = Google::Gax.create_api_call(
              @metrics_service_v2_stub.method(:list_log_metrics),
              defaults["list_log_metrics"]
            )
            @get_log_metric = Google::Gax.create_api_call(
              @metrics_service_v2_stub.method(:get_log_metric),
              defaults["get_log_metric"]
            )
            @create_log_metric = Google::Gax.create_api_call(
              @metrics_service_v2_stub.method(:create_log_metric),
              defaults["create_log_metric"]
            )
            @update_log_metric = Google::Gax.create_api_call(
              @metrics_service_v2_stub.method(:update_log_metric),
              defaults["update_log_metric"]
            )
            @delete_log_metric = Google::Gax.create_api_call(
              @metrics_service_v2_stub.method(:delete_log_metric),
              defaults["delete_log_metric"]
            )
          end

          # Service calls

          # Lists logs-based metrics.
          #
          # @param parent [String]
          #   Required. The name of the project containing the metrics:
          #
          #       "projects/[PROJECT_ID]"
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Logging::V2::LogMetric>]
          #   An enumerable of Google::Logging::V2::LogMetric instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   metrics_service_v2_client = Google::Cloud::Logging::V2::Metrics.new
          #   formatted_parent = Google::Cloud::Logging::V2::MetricsServiceV2Client.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   metrics_service_v2_client.list_log_metrics(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   metrics_service_v2_client.list_log_metrics(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_log_metrics \
              parent,
              page_size: nil,
              options: nil
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::ListLogMetricsRequest)
            @list_log_metrics.call(req, options)
          end

          # Gets a logs-based metric.
          #
          # @param metric_name [String]
          #   The resource name of the desired metric:
          #
          #       "projects/[PROJECT_ID]/metrics/[METRIC_ID]"
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::LogMetric]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   metrics_service_v2_client = Google::Cloud::Logging::V2::Metrics.new
          #   formatted_metric_name = Google::Cloud::Logging::V2::MetricsServiceV2Client.metric_path("[PROJECT]", "[METRIC]")
          #   response = metrics_service_v2_client.get_log_metric(formatted_metric_name)

          def get_log_metric \
              metric_name,
              options: nil
            req = {
              metric_name: metric_name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::GetLogMetricRequest)
            @get_log_metric.call(req, options)
          end

          # Creates a logs-based metric.
          #
          # @param parent [String]
          #   The resource name of the project in which to create the metric:
          #
          #       "projects/[PROJECT_ID]"
          #
          #   The new metric must be provided in the request.
          # @param metric [Google::Logging::V2::LogMetric | Hash]
          #   The new logs-based metric, which must not have an identifier that
          #   already exists.
          #   A hash of the same form as `Google::Logging::V2::LogMetric`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::LogMetric]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   metrics_service_v2_client = Google::Cloud::Logging::V2::Metrics.new
          #   formatted_parent = Google::Cloud::Logging::V2::MetricsServiceV2Client.project_path("[PROJECT]")
          #   metric = {}
          #   response = metrics_service_v2_client.create_log_metric(formatted_parent, metric)

          def create_log_metric \
              parent,
              metric,
              options: nil
            req = {
              parent: parent,
              metric: metric
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::CreateLogMetricRequest)
            @create_log_metric.call(req, options)
          end

          # Creates or updates a logs-based metric.
          #
          # @param metric_name [String]
          #   The resource name of the metric to update:
          #
          #       "projects/[PROJECT_ID]/metrics/[METRIC_ID]"
          #
          #   The updated metric must be provided in the request and it's
          #   +name+ field must be the same as +[METRIC_ID]+ If the metric
          #   does not exist in +[PROJECT_ID]+, then a new metric is created.
          # @param metric [Google::Logging::V2::LogMetric | Hash]
          #   The updated metric.
          #   A hash of the same form as `Google::Logging::V2::LogMetric`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Logging::V2::LogMetric]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   metrics_service_v2_client = Google::Cloud::Logging::V2::Metrics.new
          #   formatted_metric_name = Google::Cloud::Logging::V2::MetricsServiceV2Client.metric_path("[PROJECT]", "[METRIC]")
          #   metric = {}
          #   response = metrics_service_v2_client.update_log_metric(formatted_metric_name, metric)

          def update_log_metric \
              metric_name,
              metric,
              options: nil
            req = {
              metric_name: metric_name,
              metric: metric
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::UpdateLogMetricRequest)
            @update_log_metric.call(req, options)
          end

          # Deletes a logs-based metric.
          #
          # @param metric_name [String]
          #   The resource name of the metric to delete:
          #
          #       "projects/[PROJECT_ID]/metrics/[METRIC_ID]"
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/logging/v2"
          #
          #   metrics_service_v2_client = Google::Cloud::Logging::V2::Metrics.new
          #   formatted_metric_name = Google::Cloud::Logging::V2::MetricsServiceV2Client.metric_path("[PROJECT]", "[METRIC]")
          #   metrics_service_v2_client.delete_log_metric(formatted_metric_name)

          def delete_log_metric \
              metric_name,
              options: nil
            req = {
              metric_name: metric_name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Logging::V2::DeleteLogMetricRequest)
            @delete_log_metric.call(req, options)
            nil
          end
        end
      end
    end
  end
end
