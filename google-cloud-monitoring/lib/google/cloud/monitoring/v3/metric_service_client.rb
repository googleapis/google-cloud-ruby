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
# https://github.com/googleapis/googleapis/blob/master/google/monitoring/v3/metric_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/monitoring/v3/metric_service_pb"
require "google/cloud/monitoring/v3/credentials"

module Google
  module Cloud
    module Monitoring
      module V3
        # Manages metric descriptors, monitored resource descriptors, and
        # time series data.
        #
        # @!attribute [r] metric_service_stub
        #   @return [Google::Monitoring::V3::MetricService::Stub]
        class MetricServiceClient
          # @private
          attr_reader :metric_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "monitoring.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_monitored_resource_descriptors" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "resource_descriptors"),
            "list_metric_descriptors" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "metric_descriptors"),
            "list_time_series" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "time_series")
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

          METRIC_DESCRIPTOR_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/metricDescriptors/{metric_descriptor=**}"
          )

          private_constant :METRIC_DESCRIPTOR_PATH_TEMPLATE

          MONITORED_RESOURCE_DESCRIPTOR_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/monitoredResourceDescriptors/{monitored_resource_descriptor}"
          )

          private_constant :MONITORED_RESOURCE_DESCRIPTOR_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified metric_descriptor resource name string.
          # @param project [String]
          # @param metric_descriptor [String]
          # @return [String]
          def self.metric_descriptor_path project, metric_descriptor
            METRIC_DESCRIPTOR_PATH_TEMPLATE.render(
              :"project" => project,
              :"metric_descriptor" => metric_descriptor
            )
          end

          # Returns a fully-qualified monitored_resource_descriptor resource name string.
          # @param project [String]
          # @param monitored_resource_descriptor [String]
          # @return [String]
          def self.monitored_resource_descriptor_path project, monitored_resource_descriptor
            MONITORED_RESOURCE_DESCRIPTOR_PATH_TEMPLATE.render(
              :"project" => project,
              :"monitored_resource_descriptor" => monitored_resource_descriptor
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
            require "google/monitoring/v3/metric_service_services_pb"

            credentials ||= Google::Cloud::Monitoring::V3::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Monitoring::V3::Credentials.new(credentials).updater_proc
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
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "metric_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.monitoring.v3.MetricService",
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
            @metric_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Monitoring::V3::MetricService::Stub.method(:new)
            )

            @list_monitored_resource_descriptors = Google::Gax.create_api_call(
              @metric_service_stub.method(:list_monitored_resource_descriptors),
              defaults["list_monitored_resource_descriptors"],
              exception_transformer: exception_transformer
            )
            @get_monitored_resource_descriptor = Google::Gax.create_api_call(
              @metric_service_stub.method(:get_monitored_resource_descriptor),
              defaults["get_monitored_resource_descriptor"],
              exception_transformer: exception_transformer
            )
            @list_metric_descriptors = Google::Gax.create_api_call(
              @metric_service_stub.method(:list_metric_descriptors),
              defaults["list_metric_descriptors"],
              exception_transformer: exception_transformer
            )
            @get_metric_descriptor = Google::Gax.create_api_call(
              @metric_service_stub.method(:get_metric_descriptor),
              defaults["get_metric_descriptor"],
              exception_transformer: exception_transformer
            )
            @create_metric_descriptor = Google::Gax.create_api_call(
              @metric_service_stub.method(:create_metric_descriptor),
              defaults["create_metric_descriptor"],
              exception_transformer: exception_transformer
            )
            @delete_metric_descriptor = Google::Gax.create_api_call(
              @metric_service_stub.method(:delete_metric_descriptor),
              defaults["delete_metric_descriptor"],
              exception_transformer: exception_transformer
            )
            @list_time_series = Google::Gax.create_api_call(
              @metric_service_stub.method(:list_time_series),
              defaults["list_time_series"],
              exception_transformer: exception_transformer
            )
            @create_time_series = Google::Gax.create_api_call(
              @metric_service_stub.method(:create_time_series),
              defaults["create_time_series"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Lists monitored resource descriptors that match a filter. This method does not require a Stackdriver account.
          #
          # @param name [String]
          #   The project on which to execute the request. The format is
          #   `"projects/{project_id_or_number}"`.
          # @param filter [String]
          #   An optional [filter](https://cloud.google.com/monitoring/api/v3/filters) describing
          #   the descriptors to be returned.  The filter can reference
          #   the descriptor's type and labels. For example, the
          #   following filter returns only Google Compute Engine descriptors
          #   that have an `id` label:
          #
          #       resource.type = starts_with("gce_") AND resource.label:id
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Api::MonitoredResourceDescriptor>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Api::MonitoredResourceDescriptor>]
          #   An enumerable of Google::Api::MonitoredResourceDescriptor instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   metric_service_client.list_monitored_resource_descriptors(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   metric_service_client.list_monitored_resource_descriptors(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_monitored_resource_descriptors \
              name,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListMonitoredResourceDescriptorsRequest)
            @list_monitored_resource_descriptors.call(req, options, &block)
          end

          # Gets a single monitored resource descriptor. This method does not require a Stackdriver account.
          #
          # @param name [String]
          #   The monitored resource descriptor to get.  The format is
          #   `"projects/{project_id_or_number}/monitoredResourceDescriptors/{resource_type}"`.
          #   The `{resource_type}` is a predefined type, such as
          #   `cloudsql_database`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Api::MonitoredResourceDescriptor]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Api::MonitoredResourceDescriptor]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.monitored_resource_descriptor_path("[PROJECT]", "[MONITORED_RESOURCE_DESCRIPTOR]")
          #   response = metric_service_client.get_monitored_resource_descriptor(formatted_name)

          def get_monitored_resource_descriptor \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetMonitoredResourceDescriptorRequest)
            @get_monitored_resource_descriptor.call(req, options, &block)
          end

          # Lists metric descriptors that match a filter. This method does not require a Stackdriver account.
          #
          # @param name [String]
          #   The project on which to execute the request. The format is
          #   `"projects/{project_id_or_number}"`.
          # @param filter [String]
          #   If this field is empty, all custom and
          #   system-defined metric descriptors are returned.
          #   Otherwise, the [filter](https://cloud.google.com/monitoring/api/v3/filters)
          #   specifies which metric descriptors are to be
          #   returned. For example, the following filter matches all
          #   [custom metrics](https://cloud.google.com/monitoring/custom-metrics):
          #
          #       metric.type = starts_with("custom.googleapis.com/")
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Api::MetricDescriptor>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Api::MetricDescriptor>]
          #   An enumerable of Google::Api::MetricDescriptor instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   metric_service_client.list_metric_descriptors(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   metric_service_client.list_metric_descriptors(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_metric_descriptors \
              name,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListMetricDescriptorsRequest)
            @list_metric_descriptors.call(req, options, &block)
          end

          # Gets a single metric descriptor. This method does not require a Stackdriver account.
          #
          # @param name [String]
          #   The metric descriptor on which to execute the request. The format is
          #   `"projects/{project_id_or_number}/metricDescriptors/{metric_id}"`.
          #   An example value of `{metric_id}` is
          #   `"compute.googleapis.com/instance/disk/read_bytes_count"`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Api::MetricDescriptor]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Api::MetricDescriptor]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.metric_descriptor_path("[PROJECT]", "[METRIC_DESCRIPTOR]")
          #   response = metric_service_client.get_metric_descriptor(formatted_name)

          def get_metric_descriptor \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::GetMetricDescriptorRequest)
            @get_metric_descriptor.call(req, options, &block)
          end

          # Creates a new metric descriptor.
          # User-created metric descriptors define
          # [custom metrics](https://cloud.google.com/monitoring/custom-metrics).
          #
          # @param name [String]
          #   The project on which to execute the request. The format is
          #   `"projects/{project_id_or_number}"`.
          # @param metric_descriptor [Google::Api::MetricDescriptor | Hash]
          #   The new [custom metric](https://cloud.google.com/monitoring/custom-metrics)
          #   descriptor.
          #   A hash of the same form as `Google::Api::MetricDescriptor`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Api::MetricDescriptor]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Api::MetricDescriptor]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `metric_descriptor`:
          #   metric_descriptor = {}
          #   response = metric_service_client.create_metric_descriptor(formatted_name, metric_descriptor)

          def create_metric_descriptor \
              name,
              metric_descriptor,
              options: nil,
              &block
            req = {
              name: name,
              metric_descriptor: metric_descriptor
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::CreateMetricDescriptorRequest)
            @create_metric_descriptor.call(req, options, &block)
          end

          # Deletes a metric descriptor. Only user-created
          # [custom metrics](https://cloud.google.com/monitoring/custom-metrics) can be deleted.
          #
          # @param name [String]
          #   The metric descriptor on which to execute the request. The format is
          #   `"projects/{project_id_or_number}/metricDescriptors/{metric_id}"`.
          #   An example of `{metric_id}` is:
          #   `"custom.googleapis.com/my_test_metric"`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.metric_descriptor_path("[PROJECT]", "[METRIC_DESCRIPTOR]")
          #   metric_service_client.delete_metric_descriptor(formatted_name)

          def delete_metric_descriptor \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::DeleteMetricDescriptorRequest)
            @delete_metric_descriptor.call(req, options, &block)
            nil
          end

          # Lists time series that match a filter. This method does not require a Stackdriver account.
          #
          # @param name [String]
          #   The project on which to execute the request. The format is
          #   "projects/\\{project_id_or_number}".
          # @param filter [String]
          #   A [monitoring filter](https://cloud.google.com/monitoring/api/v3/filters) that specifies which time
          #   series should be returned.  The filter must specify a single metric type,
          #   and can additionally specify metric labels and other information. For
          #   example:
          #
          #       metric.type = "compute.googleapis.com/instance/cpu/usage_time" AND
          #           metric.label.instance_name = "my-instance-name"
          # @param interval [Google::Monitoring::V3::TimeInterval | Hash]
          #   The time interval for which results should be returned. Only time series
          #   that contain data points in the specified interval are included
          #   in the response.
          #   A hash of the same form as `Google::Monitoring::V3::TimeInterval`
          #   can also be provided.
          # @param view [Google::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView]
          #   Specifies which information is returned about the time series.
          # @param aggregation [Google::Monitoring::V3::Aggregation | Hash]
          #   By default, the raw time series data is returned.
          #   Use this field to combine multiple time series for different
          #   views of the data.
          #   A hash of the same form as `Google::Monitoring::V3::Aggregation`
          #   can also be provided.
          # @param order_by [String]
          #   Unsupported: must be left blank. The points in each time series are
          #   returned in reverse time order.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Monitoring::V3::TimeSeries>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Monitoring::V3::TimeSeries>]
          #   An enumerable of Google::Monitoring::V3::TimeSeries instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `filter`:
          #   filter = ''
          #
          #   # TODO: Initialize `interval`:
          #   interval = {}
          #
          #   # TODO: Initialize `view`:
          #   view = :FULL
          #
          #   # Iterate over all results.
          #   metric_service_client.list_time_series(formatted_name, filter, interval, view).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   metric_service_client.list_time_series(formatted_name, filter, interval, view).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_time_series \
              name,
              filter,
              interval,
              view,
              aggregation: nil,
              order_by: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              filter: filter,
              interval: interval,
              view: view,
              aggregation: aggregation,
              order_by: order_by,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::ListTimeSeriesRequest)
            @list_time_series.call(req, options, &block)
          end

          # Creates or adds data to one or more time series.
          # The response is empty if all time series in the request were written.
          # If any time series could not be written, a corresponding failure message is
          # included in the error response.
          #
          # @param name [String]
          #   The project on which to execute the request. The format is
          #   `"projects/{project_id_or_number}"`.
          # @param time_series [Array<Google::Monitoring::V3::TimeSeries | Hash>]
          #   The new data to be added to a list of time series.
          #   Adds at most one data point to each of several time series.  The new data
          #   point must be more recent than any other point in its time series.  Each
          #   `TimeSeries` value must fully specify a unique time series by supplying
          #   all label values for the metric and the monitored resource.
          #   A hash of the same form as `Google::Monitoring::V3::TimeSeries`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/monitoring"
          #
          #   metric_service_client = Google::Cloud::Monitoring::Metric.new(version: :v3)
          #   formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `time_series`:
          #   time_series = []
          #   metric_service_client.create_time_series(formatted_name, time_series)

          def create_time_series \
              name,
              time_series,
              options: nil,
              &block
            req = {
              name: name,
              time_series: time_series
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Monitoring::V3::CreateTimeSeriesRequest)
            @create_time_series.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
