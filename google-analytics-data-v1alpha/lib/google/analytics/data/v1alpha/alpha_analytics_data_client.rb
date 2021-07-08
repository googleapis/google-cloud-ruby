# Copyright 2020 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/analytics/data/v1alpha/analytics_data_api.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/analytics/data/v1alpha/analytics_data_api_pb"
require "google/analytics/data/v1alpha/credentials"

module Google
  module Analytics
    module Data
      module V1alpha
        # Google Analytics reporting data service.
        #
        # @!attribute [r] alpha_analytics_data_stub
        #   @return [Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub]
        class AlphaAnalyticsDataClient
          attr_reader :alpha_analytics_data_stub

          # The default address of the service.
          SERVICE_ADDRESS = "analyticsdata.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/analytics",
            "https://www.googleapis.com/auth/analytics.readonly"
          ].freeze


          METADATA_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "properties/{property}/metadata"
          )

          private_constant :METADATA_PATH_TEMPLATE

          # Returns a fully-qualified metadata resource name string.
          # @param property [String]
          # @return [String]
          def self.metadata_path property
            METADATA_PATH_TEMPLATE.render(
              :"property" => property
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
            require "google/analytics/data/v1alpha/analytics_data_api_services_pb"

            credentials ||= Google::Analytics::Data::V1alpha::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Analytics::Data::V1alpha::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-analytics-data'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            if credentials.respond_to?(:quota_project_id) && credentials.quota_project_id
              headers[:"x-goog-user-project"] = credentials.quota_project_id
            end
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "alpha_analytics_data_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.analytics.data.v1alpha.AlphaAnalyticsData",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @alpha_analytics_data_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.method(:new)
            )

            @run_report = Google::Gax.create_api_call(
              @alpha_analytics_data_stub.method(:run_report),
              defaults["run_report"],
              exception_transformer: exception_transformer
            )
            @run_pivot_report = Google::Gax.create_api_call(
              @alpha_analytics_data_stub.method(:run_pivot_report),
              defaults["run_pivot_report"],
              exception_transformer: exception_transformer
            )
            @batch_run_reports = Google::Gax.create_api_call(
              @alpha_analytics_data_stub.method(:batch_run_reports),
              defaults["batch_run_reports"],
              exception_transformer: exception_transformer
            )
            @batch_run_pivot_reports = Google::Gax.create_api_call(
              @alpha_analytics_data_stub.method(:batch_run_pivot_reports),
              defaults["batch_run_pivot_reports"],
              exception_transformer: exception_transformer
            )
            @get_metadata = Google::Gax.create_api_call(
              @alpha_analytics_data_stub.method(:get_metadata),
              defaults["get_metadata"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @run_realtime_report = Google::Gax.create_api_call(
              @alpha_analytics_data_stub.method(:run_realtime_report),
              defaults["run_realtime_report"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'property' => request.property}
              end
            )
          end

          # Service calls

          # Returns a customized report of your Google Analytics event data. Reports
          # contain statistics derived from data collected by the Google Analytics
          # tracking code. The data returned from the API is as a table with columns
          # for the requested dimensions and metrics. Metrics are individual
          # measurements of user activity on your property, such as active users or
          # event count. Dimensions break down metrics across some common criteria,
          # such as country or event name.
          #
          # @param entity [Google::Analytics::Data::V1alpha::Entity | Hash]
          #   A property whose events are tracked. Within a batch request, this entity
          #   should either be unspecified or consistent with the batch-level entity.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Entity`
          #   can also be provided.
          # @param dimensions [Array<Google::Analytics::Data::V1alpha::Dimension | Hash>]
          #   The dimensions requested and displayed.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Dimension`
          #   can also be provided.
          # @param metrics [Array<Google::Analytics::Data::V1alpha::Metric | Hash>]
          #   The metrics requested and displayed.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Metric`
          #   can also be provided.
          # @param date_ranges [Array<Google::Analytics::Data::V1alpha::DateRange | Hash>]
          #   Date ranges of data to read. If multiple date ranges are requested, each
          #   response row will contain a zero based date range index. If two date
          #   ranges overlap, the event data for the overlapping days is included in the
          #   response rows for both date ranges. In a cohort request, this `dateRanges`
          #   must be unspecified.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::DateRange`
          #   can also be provided.
          # @param offset [Integer]
          #   The row count of the start row. The first row is counted as row 0.
          #
          #   To learn more about this pagination parameter, see
          #   [Pagination](https://developers.google.com/analytics/devguides/reporting/data/v1/basics#pagination).
          # @param limit [Integer]
          #   The number of rows to return. If unspecified, 10 rows are returned. If
          #   -1, all rows are returned.
          #
          #   To learn more about this pagination parameter, see
          #   [Pagination](https://developers.google.com/analytics/devguides/reporting/data/v1/basics#pagination).
          # @param metric_aggregations [Array<Google::Analytics::Data::V1alpha::MetricAggregation>]
          #   Aggregation of metrics. Aggregated metric values will be shown in rows
          #   where the dimension_values are set to "RESERVED_(MetricAggregation)".
          # @param dimension_filter [Google::Analytics::Data::V1alpha::FilterExpression | Hash]
          #   The filter clause of dimensions. Dimensions must be requested to be used in
          #   this filter. Metrics cannot be used in this filter.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::FilterExpression`
          #   can also be provided.
          # @param metric_filter [Google::Analytics::Data::V1alpha::FilterExpression | Hash]
          #   The filter clause of metrics. Applied at post aggregation phase, similar to
          #   SQL having-clause. Metrics must be requested to be used in this filter.
          #   Dimensions cannot be used in this filter.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::FilterExpression`
          #   can also be provided.
          # @param order_bys [Array<Google::Analytics::Data::V1alpha::OrderBy | Hash>]
          #   Specifies how rows are ordered in the response.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::OrderBy`
          #   can also be provided.
          # @param currency_code [String]
          #   A currency code in ISO4217 format, such as "AED", "USD", "JPY".
          #   If the field is empty, the report uses the entity's default currency.
          # @param cohort_spec [Google::Analytics::Data::V1alpha::CohortSpec | Hash]
          #   Cohort group associated with this request. If there is a cohort group
          #   in the request the 'cohort' dimension must be present.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::CohortSpec`
          #   can also be provided.
          # @param keep_empty_rows [true, false]
          #   If false or unspecified, each row with all metrics equal to 0 will not be
          #   returned. If true, these rows will be returned if they are not separately
          #   removed by a filter.
          # @param return_property_quota [true, false]
          #   Toggles whether to return the current state of this Analytics Property's
          #   quota. Quota is returned in [PropertyQuota](https://cloud.google.com#PropertyQuota).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Analytics::Data::V1alpha::RunReportResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Analytics::Data::V1alpha::RunReportResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/analytics/data"
          #
          #   alpha_analytics_data_client = Google::Analytics::Data::V1alpha.new(version: :v1alpha)
          #   response = alpha_analytics_data_client.run_report

          def run_report \
              entity: nil,
              dimensions: nil,
              metrics: nil,
              date_ranges: nil,
              offset: nil,
              limit: nil,
              metric_aggregations: nil,
              dimension_filter: nil,
              metric_filter: nil,
              order_bys: nil,
              currency_code: nil,
              cohort_spec: nil,
              keep_empty_rows: nil,
              return_property_quota: nil,
              options: nil,
              &block
            req = {
              entity: entity,
              dimensions: dimensions,
              metrics: metrics,
              date_ranges: date_ranges,
              offset: offset,
              limit: limit,
              metric_aggregations: metric_aggregations,
              dimension_filter: dimension_filter,
              metric_filter: metric_filter,
              order_bys: order_bys,
              currency_code: currency_code,
              cohort_spec: cohort_spec,
              keep_empty_rows: keep_empty_rows,
              return_property_quota: return_property_quota
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Analytics::Data::V1alpha::RunReportRequest)
            @run_report.call(req, options, &block)
          end

          # Returns a customized pivot report of your Google Analytics event data.
          # Pivot reports are more advanced and expressive formats than regular
          # reports. In a pivot report, dimensions are only visible if they are
          # included in a pivot. Multiple pivots can be specified to further dissect
          # your data.
          #
          # @param entity [Google::Analytics::Data::V1alpha::Entity | Hash]
          #   A property whose events are tracked. Within a batch request, this entity
          #   should either be unspecified or consistent with the batch-level entity.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Entity`
          #   can also be provided.
          # @param dimensions [Array<Google::Analytics::Data::V1alpha::Dimension | Hash>]
          #   The dimensions requested. All defined dimensions must be used by one of the
          #   following: dimension_expression, dimension_filter, pivots, order_bys.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Dimension`
          #   can also be provided.
          # @param metrics [Array<Google::Analytics::Data::V1alpha::Metric | Hash>]
          #   The metrics requested, at least one metric needs to be specified. All
          #   defined metrics must be used by one of the following: metric_expression,
          #   metric_filter, order_bys.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Metric`
          #   can also be provided.
          # @param dimension_filter [Google::Analytics::Data::V1alpha::FilterExpression | Hash]
          #   The filter clause of dimensions. Dimensions must be requested to be used in
          #   this filter. Metrics cannot be used in this filter.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::FilterExpression`
          #   can also be provided.
          # @param metric_filter [Google::Analytics::Data::V1alpha::FilterExpression | Hash]
          #   The filter clause of metrics. Applied at post aggregation phase, similar to
          #   SQL having-clause. Metrics must be requested to be used in this filter.
          #   Dimensions cannot be used in this filter.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::FilterExpression`
          #   can also be provided.
          # @param pivots [Array<Google::Analytics::Data::V1alpha::Pivot | Hash>]
          #   Describes the visual format of the report's dimensions in columns or rows.
          #   The union of the fieldNames (dimension names) in all pivots must be a
          #   subset of dimension names defined in Dimensions. No two pivots can share a
          #   dimension. A dimension is only visible if it appears in a pivot.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Pivot`
          #   can also be provided.
          # @param date_ranges [Array<Google::Analytics::Data::V1alpha::DateRange | Hash>]
          #   The date range to retrieve event data for the report. If multiple date
          #   ranges are specified, event data from each date range is used in the
          #   report. A special dimension with field name "dateRange" can be included in
          #   a Pivot's field names; if included, the report compares between date
          #   ranges. In a cohort request, this `dateRanges` must be unspecified.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::DateRange`
          #   can also be provided.
          # @param currency_code [String]
          #   A currency code in ISO4217 format, such as "AED", "USD", "JPY".
          #   If the field is empty, the report uses the entity's default currency.
          # @param cohort_spec [Google::Analytics::Data::V1alpha::CohortSpec | Hash]
          #   Cohort group associated with this request. If there is a cohort group
          #   in the request the 'cohort' dimension must be present.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::CohortSpec`
          #   can also be provided.
          # @param keep_empty_rows [true, false]
          #   If false or unspecified, each row with all metrics equal to 0 will not be
          #   returned. If true, these rows will be returned if they are not separately
          #   removed by a filter.
          # @param return_property_quota [true, false]
          #   Toggles whether to return the current state of this Analytics Property's
          #   quota. Quota is returned in [PropertyQuota](https://cloud.google.com#PropertyQuota).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Analytics::Data::V1alpha::RunPivotReportResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Analytics::Data::V1alpha::RunPivotReportResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/analytics/data"
          #
          #   alpha_analytics_data_client = Google::Analytics::Data::V1alpha.new(version: :v1alpha)
          #   response = alpha_analytics_data_client.run_pivot_report

          def run_pivot_report \
              entity: nil,
              dimensions: nil,
              metrics: nil,
              dimension_filter: nil,
              metric_filter: nil,
              pivots: nil,
              date_ranges: nil,
              currency_code: nil,
              cohort_spec: nil,
              keep_empty_rows: nil,
              return_property_quota: nil,
              options: nil,
              &block
            req = {
              entity: entity,
              dimensions: dimensions,
              metrics: metrics,
              dimension_filter: dimension_filter,
              metric_filter: metric_filter,
              pivots: pivots,
              date_ranges: date_ranges,
              currency_code: currency_code,
              cohort_spec: cohort_spec,
              keep_empty_rows: keep_empty_rows,
              return_property_quota: return_property_quota
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Analytics::Data::V1alpha::RunPivotReportRequest)
            @run_pivot_report.call(req, options, &block)
          end

          # Returns multiple reports in a batch. All reports must be for the same
          # Entity.
          #
          # @param entity [Google::Analytics::Data::V1alpha::Entity | Hash]
          #   A property whose events are tracked. This entity must be specified for the
          #   batch. The entity within RunReportRequest may either be unspecified or
          #   consistent with this entity.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Entity`
          #   can also be provided.
          # @param requests [Array<Google::Analytics::Data::V1alpha::RunReportRequest | Hash>]
          #   Individual requests. Each request has a separate report response. Each
          #   batch request is allowed up to 5 requests.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::RunReportRequest`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Analytics::Data::V1alpha::BatchRunReportsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Analytics::Data::V1alpha::BatchRunReportsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/analytics/data"
          #
          #   alpha_analytics_data_client = Google::Analytics::Data::V1alpha.new(version: :v1alpha)
          #   response = alpha_analytics_data_client.batch_run_reports

          def batch_run_reports \
              entity: nil,
              requests: nil,
              options: nil,
              &block
            req = {
              entity: entity,
              requests: requests
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Analytics::Data::V1alpha::BatchRunReportsRequest)
            @batch_run_reports.call(req, options, &block)
          end

          # Returns multiple pivot reports in a batch. All reports must be for the same
          # Entity.
          #
          # @param entity [Google::Analytics::Data::V1alpha::Entity | Hash]
          #   A property whose events are tracked. This entity must be specified for the
          #   batch. The entity within RunPivotReportRequest may either be unspecified or
          #   consistent with this entity.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Entity`
          #   can also be provided.
          # @param requests [Array<Google::Analytics::Data::V1alpha::RunPivotReportRequest | Hash>]
          #   Individual requests. Each request has a separate pivot report response.
          #   Each batch request is allowed up to 5 requests.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::RunPivotReportRequest`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Analytics::Data::V1alpha::BatchRunPivotReportsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Analytics::Data::V1alpha::BatchRunPivotReportsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/analytics/data"
          #
          #   alpha_analytics_data_client = Google::Analytics::Data::V1alpha.new(version: :v1alpha)
          #   response = alpha_analytics_data_client.batch_run_pivot_reports

          def batch_run_pivot_reports \
              entity: nil,
              requests: nil,
              options: nil,
              &block
            req = {
              entity: entity,
              requests: requests
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Analytics::Data::V1alpha::BatchRunPivotReportsRequest)
            @batch_run_pivot_reports.call(req, options, &block)
          end

          # Returns metadata for dimensions and metrics available in reporting methods.
          # Used to explore the dimensions and metrics. In this method, a Google
          # Analytics GA4 Property Identifier is specified in the request, and
          # the metadata response includes Custom dimensions and metrics as well as
          # Universal metadata.
          #
          # For example if a custom metric with parameter name `levels_unlocked` is
          # registered to a property, the Metadata response will contain
          # `customEvent:levels_unlocked`. Universal metadata are dimensions and
          # metrics applicable to any property such as `country` and `totalUsers`.
          #
          # @param name [String]
          #   Required. The resource name of the metadata to retrieve. This name field is
          #   specified in the URL path and not URL parameters. Property is a numeric
          #   Google Analytics GA4 Property identifier. To learn more, see [where to find
          #   your Property
          #   ID](https://developers.google.com/analytics/devguides/reporting/data/v1/property-id).
          #
          #   Example: properties/1234/metadata
          #
          #   Set the Property ID to 0 for dimensions and metrics common to all
          #   properties. In this special mode, this method will not return custom
          #   dimensions and metrics.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Analytics::Data::V1alpha::Metadata]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Analytics::Data::V1alpha::Metadata]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/analytics/data"
          #
          #   alpha_analytics_data_client = Google::Analytics::Data::V1alpha.new(version: :v1alpha)
          #   formatted_name = Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient.metadata_path("[PROPERTY]")
          #   response = alpha_analytics_data_client.get_metadata(formatted_name)

          def get_metadata \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Analytics::Data::V1alpha::GetMetadataRequest)
            @get_metadata.call(req, options, &block)
          end

          # The Google Analytics Realtime API returns a customized report of realtime
          # event data for your property. These reports show events and usage from the
          # last 30 minutes.
          #
          # @param property [String]
          #   A Google Analytics GA4 property identifier whose events are tracked.
          #   Specified in the URL path and not the body. To learn more, see [where to
          #   find your Property
          #   ID](https://developers.google.com/analytics/devguides/reporting/data/v1/property-id).
          #
          #   Example: properties/1234
          # @param dimensions [Array<Google::Analytics::Data::V1alpha::Dimension | Hash>]
          #   The dimensions requested and displayed.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Dimension`
          #   can also be provided.
          # @param metrics [Array<Google::Analytics::Data::V1alpha::Metric | Hash>]
          #   The metrics requested and displayed.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::Metric`
          #   can also be provided.
          # @param limit [Integer]
          #   The number of rows to return. If unspecified, 10 rows are returned. If
          #   -1, all rows are returned.
          # @param dimension_filter [Google::Analytics::Data::V1alpha::FilterExpression | Hash]
          #   The filter clause of dimensions. Dimensions must be requested to be used in
          #   this filter. Metrics cannot be used in this filter.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::FilterExpression`
          #   can also be provided.
          # @param metric_filter [Google::Analytics::Data::V1alpha::FilterExpression | Hash]
          #   The filter clause of metrics. Applied at post aggregation phase, similar to
          #   SQL having-clause. Metrics must be requested to be used in this filter.
          #   Dimensions cannot be used in this filter.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::FilterExpression`
          #   can also be provided.
          # @param metric_aggregations [Array<Google::Analytics::Data::V1alpha::MetricAggregation>]
          #   Aggregation of metrics. Aggregated metric values will be shown in rows
          #   where the dimension_values are set to "RESERVED_(MetricAggregation)".
          # @param order_bys [Array<Google::Analytics::Data::V1alpha::OrderBy | Hash>]
          #   Specifies how rows are ordered in the response.
          #   A hash of the same form as `Google::Analytics::Data::V1alpha::OrderBy`
          #   can also be provided.
          # @param return_property_quota [true, false]
          #   Toggles whether to return the current state of this Analytics Property's
          #   Realtime quota. Quota is returned in [PropertyQuota](https://cloud.google.com#PropertyQuota).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Analytics::Data::V1alpha::RunRealtimeReportResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Analytics::Data::V1alpha::RunRealtimeReportResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/analytics/data"
          #
          #   alpha_analytics_data_client = Google::Analytics::Data::V1alpha.new(version: :v1alpha)
          #   response = alpha_analytics_data_client.run_realtime_report

          def run_realtime_report \
              property: nil,
              dimensions: nil,
              metrics: nil,
              limit: nil,
              dimension_filter: nil,
              metric_filter: nil,
              metric_aggregations: nil,
              order_bys: nil,
              return_property_quota: nil,
              options: nil,
              &block
            req = {
              property: property,
              dimensions: dimensions,
              metrics: metrics,
              limit: limit,
              dimension_filter: dimension_filter,
              metric_filter: metric_filter,
              metric_aggregations: metric_aggregations,
              order_bys: order_bys,
              return_property_quota: return_property_quota
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Analytics::Data::V1alpha::RunRealtimeReportRequest)
            @run_realtime_report.call(req, options, &block)
          end
        end
      end
    end
  end
end
