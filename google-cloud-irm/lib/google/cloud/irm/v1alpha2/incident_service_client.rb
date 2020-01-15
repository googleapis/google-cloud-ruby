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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/irm/v1alpha2/incidents_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/irm/v1alpha2/incidents_service_pb"
require "google/cloud/irm/v1alpha2/credentials"
require "google/cloud/irm/version"

module Google
  module Cloud
    module Irm
      module V1alpha2
        # The Incident API for Incident Response & Management.
        #
        # @!attribute [r] incident_service_stub
        #   @return [Google::Cloud::Irm::V1alpha2::IncidentService::Stub]
        class IncidentServiceClient
          # @private
          attr_reader :incident_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "irm.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "search_incidents" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "incidents"),
            "search_similar_incidents" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "results"),
            "list_annotations" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "annotations"),
            "list_tags" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "tags"),
            "search_signals" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "signals"),
            "list_artifacts" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "artifacts"),
            "list_subscriptions" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "subscriptions"),
            "list_incident_role_assignments" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "incident_role_assignments")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          ANNOTATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/incidents/{incident}/annotations/{annotation}"
          )

          private_constant :ANNOTATION_PATH_TEMPLATE

          ARTIFACT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/incidents/{incident}/artifacts/{artifact}"
          )

          private_constant :ARTIFACT_PATH_TEMPLATE

          INCIDENT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/incidents/{incident}"
          )

          private_constant :INCIDENT_PATH_TEMPLATE

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          ROLE_ASSIGNMENT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/incidents/{incident}/roleAssignments/{role_assignment}"
          )

          private_constant :ROLE_ASSIGNMENT_PATH_TEMPLATE

          SIGNAL_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/signals/{signal}"
          )

          private_constant :SIGNAL_PATH_TEMPLATE

          SUBSCRIPTION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/incidents/{incident}/subscriptions/{subscription}"
          )

          private_constant :SUBSCRIPTION_PATH_TEMPLATE

          TAG_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/incidents/{incident}/tags/{tag}"
          )

          private_constant :TAG_PATH_TEMPLATE

          # Returns a fully-qualified annotation resource name string.
          # @param project [String]
          # @param incident [String]
          # @param annotation [String]
          # @return [String]
          def self.annotation_path project, incident, annotation
            ANNOTATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"incident" => incident,
              :"annotation" => annotation
            )
          end

          # Returns a fully-qualified artifact resource name string.
          # @param project [String]
          # @param incident [String]
          # @param artifact [String]
          # @return [String]
          def self.artifact_path project, incident, artifact
            ARTIFACT_PATH_TEMPLATE.render(
              :"project" => project,
              :"incident" => incident,
              :"artifact" => artifact
            )
          end

          # Returns a fully-qualified incident resource name string.
          # @param project [String]
          # @param incident [String]
          # @return [String]
          def self.incident_path project, incident
            INCIDENT_PATH_TEMPLATE.render(
              :"project" => project,
              :"incident" => incident
            )
          end

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified role_assignment resource name string.
          # @param project [String]
          # @param incident [String]
          # @param role_assignment [String]
          # @return [String]
          def self.role_assignment_path project, incident, role_assignment
            ROLE_ASSIGNMENT_PATH_TEMPLATE.render(
              :"project" => project,
              :"incident" => incident,
              :"role_assignment" => role_assignment
            )
          end

          # Returns a fully-qualified signal resource name string.
          # @param project [String]
          # @param signal [String]
          # @return [String]
          def self.signal_path project, signal
            SIGNAL_PATH_TEMPLATE.render(
              :"project" => project,
              :"signal" => signal
            )
          end

          # Returns a fully-qualified subscription resource name string.
          # @param project [String]
          # @param incident [String]
          # @param subscription [String]
          # @return [String]
          def self.subscription_path project, incident, subscription
            SUBSCRIPTION_PATH_TEMPLATE.render(
              :"project" => project,
              :"incident" => incident,
              :"subscription" => subscription
            )
          end

          # Returns a fully-qualified tag resource name string.
          # @param project [String]
          # @param incident [String]
          # @param tag [String]
          # @return [String]
          def self.tag_path project, incident, tag
            TAG_PATH_TEMPLATE.render(
              :"project" => project,
              :"incident" => incident,
              :"tag" => tag
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
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              service_address: nil,
              service_port: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/irm/v1alpha2/incidents_service_services_pb"

            credentials ||= Google::Cloud::Irm::V1alpha2::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Irm::V1alpha2::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Irm::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "incident_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.irm.v1alpha2.IncidentService",
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
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @incident_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Irm::V1alpha2::IncidentService::Stub.method(:new)
            )

            @create_incident = Google::Gax.create_api_call(
              @incident_service_stub.method(:create_incident),
              defaults["create_incident"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_incident = Google::Gax.create_api_call(
              @incident_service_stub.method(:get_incident),
              defaults["get_incident"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @search_incidents = Google::Gax.create_api_call(
              @incident_service_stub.method(:search_incidents),
              defaults["search_incidents"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_incident = Google::Gax.create_api_call(
              @incident_service_stub.method(:update_incident),
              defaults["update_incident"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'incident.name' => request.incident.name}
              end
            )
            @search_similar_incidents = Google::Gax.create_api_call(
              @incident_service_stub.method(:search_similar_incidents),
              defaults["search_similar_incidents"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_annotation = Google::Gax.create_api_call(
              @incident_service_stub.method(:create_annotation),
              defaults["create_annotation"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_annotations = Google::Gax.create_api_call(
              @incident_service_stub.method(:list_annotations),
              defaults["list_annotations"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_tag = Google::Gax.create_api_call(
              @incident_service_stub.method(:create_tag),
              defaults["create_tag"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_tag = Google::Gax.create_api_call(
              @incident_service_stub.method(:delete_tag),
              defaults["delete_tag"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_tags = Google::Gax.create_api_call(
              @incident_service_stub.method(:list_tags),
              defaults["list_tags"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_signal = Google::Gax.create_api_call(
              @incident_service_stub.method(:create_signal),
              defaults["create_signal"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @search_signals = Google::Gax.create_api_call(
              @incident_service_stub.method(:search_signals),
              defaults["search_signals"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_signal = Google::Gax.create_api_call(
              @incident_service_stub.method(:get_signal),
              defaults["get_signal"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @lookup_signal = Google::Gax.create_api_call(
              @incident_service_stub.method(:lookup_signal),
              defaults["lookup_signal"],
              exception_transformer: exception_transformer
            )
            @update_signal = Google::Gax.create_api_call(
              @incident_service_stub.method(:update_signal),
              defaults["update_signal"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'signal.name' => request.signal.name}
              end
            )
            @escalate_incident = Google::Gax.create_api_call(
              @incident_service_stub.method(:escalate_incident),
              defaults["escalate_incident"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'incident.name' => request.incident.name}
              end
            )
            @create_artifact = Google::Gax.create_api_call(
              @incident_service_stub.method(:create_artifact),
              defaults["create_artifact"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_artifacts = Google::Gax.create_api_call(
              @incident_service_stub.method(:list_artifacts),
              defaults["list_artifacts"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_artifact = Google::Gax.create_api_call(
              @incident_service_stub.method(:update_artifact),
              defaults["update_artifact"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'artifact.name' => request.artifact.name}
              end
            )
            @delete_artifact = Google::Gax.create_api_call(
              @incident_service_stub.method(:delete_artifact),
              defaults["delete_artifact"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @send_shift_handoff = Google::Gax.create_api_call(
              @incident_service_stub.method(:send_shift_handoff),
              defaults["send_shift_handoff"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_subscription = Google::Gax.create_api_call(
              @incident_service_stub.method(:create_subscription),
              defaults["create_subscription"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_subscription = Google::Gax.create_api_call(
              @incident_service_stub.method(:update_subscription),
              defaults["update_subscription"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'subscription.name' => request.subscription.name}
              end
            )
            @list_subscriptions = Google::Gax.create_api_call(
              @incident_service_stub.method(:list_subscriptions),
              defaults["list_subscriptions"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_subscription = Google::Gax.create_api_call(
              @incident_service_stub.method(:delete_subscription),
              defaults["delete_subscription"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_incident_role_assignment = Google::Gax.create_api_call(
              @incident_service_stub.method(:create_incident_role_assignment),
              defaults["create_incident_role_assignment"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_incident_role_assignment = Google::Gax.create_api_call(
              @incident_service_stub.method(:delete_incident_role_assignment),
              defaults["delete_incident_role_assignment"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_incident_role_assignments = Google::Gax.create_api_call(
              @incident_service_stub.method(:list_incident_role_assignments),
              defaults["list_incident_role_assignments"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @request_incident_role_handover = Google::Gax.create_api_call(
              @incident_service_stub.method(:request_incident_role_handover),
              defaults["request_incident_role_handover"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @confirm_incident_role_handover = Google::Gax.create_api_call(
              @incident_service_stub.method(:confirm_incident_role_handover),
              defaults["confirm_incident_role_handover"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @force_incident_role_handover = Google::Gax.create_api_call(
              @incident_service_stub.method(:force_incident_role_handover),
              defaults["force_incident_role_handover"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @cancel_incident_role_handover = Google::Gax.create_api_call(
              @incident_service_stub.method(:cancel_incident_role_handover),
              defaults["cancel_incident_role_handover"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Creates a new incident.
          #
          # @param incident [Google::Cloud::Irm::V1alpha2::Incident | Hash]
          #   The incident to create.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Incident`
          #   can also be provided.
          # @param parent [String]
          #   The resource name of the hosting Stackdriver project which the incident
          #   belongs to.
          #   The name is of the form `projects/{project_id_or_number}`
          #   .
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Incident]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Incident]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #
          #   # TODO: Initialize `incident`:
          #   incident = {}
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
          #   response = incident_client.create_incident(incident, formatted_parent)

          def create_incident \
              incident,
              parent,
              options: nil,
              &block
            req = {
              incident: incident,
              parent: parent
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CreateIncidentRequest)
            @create_incident.call(req, options, &block)
          end

          # Returns an incident by name.
          #
          # @param name [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Incident]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Incident]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #   response = incident_client.get_incident(formatted_name)

          def get_incident \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::GetIncidentRequest)
            @get_incident.call(req, options, &block)
          end

          # Returns a list of incidents.
          # Incidents are ordered by start time, with the most recent incidents first.
          #
          # @param parent [String]
          #   The resource name of the hosting Stackdriver project which requested
          #   incidents belong to.
          # @param query [String]
          #   An expression that defines which incidents to return.
          #
          #   Search atoms can be used to match certain specific fields.  Otherwise,
          #   plain text will match text fields in the incident.
          #
          #   Search atoms:
          #   * `start` - (timestamp) The time the incident started.
          #   * `stage` - The stage of the incident, one of detected, triaged, mitigated,
          #     resolved, documented, or duplicate (which correspond to values in the
          #     Incident.Stage enum). These are ordered, so `stage<resolved` is
          #     equivalent to `stage:detected OR stage:triaged OR stage:mitigated`.
          #   * `severity` - (Incident.Severity) The severity of the incident.
          #     * Supports matching on a specific severity (for example,
          #       `severity:major`) or on a range (for example, `severity>medium`,
          #       `severity<=minor`, etc.).
          #
          #     Timestamp formats:
          #   * yyyy-MM-dd - an absolute date, treated as a calendar-day-wide window.
          #     In other words, the "<" operator will match dates before that date, the
          #     ">" operator will match dates after that date, and the ":" or "="
          #     operators will match the entire day.
          #   * Nd (for example, 7d) - a relative number of days ago, treated as a moment
          #     in time (as opposed to a day-wide span). A multiple of 24 hours ago (as
          #     opposed to calendar days).  In the case of daylight savings time, it will
          #     apply the current timezone to both ends of the range.  Note that exact
          #     matching (for example, `start:7d`) is unlikely to be useful because that
          #     would only match incidents created precisely at a particular instant in
          #     time.
          #
          #   Examples:
          #
          #   * `foo` - matches incidents containing the word "foo"
          #   * `"foo bar"` - matches incidents containing the phrase "foo bar"
          #   * `foo bar` or `foo AND bar` - matches incidents containing the words "foo"
          #     and "bar"
          #   * `foo -bar` or `foo AND NOT bar` - matches incidents containing the word
          #     "foo" but not the word "bar"
          #   * `foo OR bar` - matches incidents containing the word "foo" or the word
          #     "bar"
          #   * `start>2018-11-28` - matches incidents which started after November 11,
          #     2018.
          #   * `start<=2018-11-28` - matches incidents which started on or before
          #     November 11, 2018.
          #   * `start:2018-11-28` - matches incidents which started on November 11,
          #     2018.
          #   * `start>7d` - matches incidents which started after the point in time 7*24
          #     hours ago
          #   * `start>180d` - similar to 7d, but likely to cross the daylight savings
          #     time boundary, so the end time will be 1 hour different from "now."
          #   * `foo AND start>90d AND stage<resolved` - unresolved incidents from the
          #     past 90 days containing the word "foo"
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param time_zone [String]
          #   The time zone name. It should be an IANA TZ name, such as
          #   "America/Los_Angeles". For more information,
          #   see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones.
          #   If no time zone is specified, the default is UTC.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Incident>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Incident>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::Incident instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   incident_client.search_incidents(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.search_incidents(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def search_incidents \
              parent,
              query: nil,
              page_size: nil,
              time_zone: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              query: query,
              page_size: page_size,
              time_zone: time_zone
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::SearchIncidentsRequest)
            @search_incidents.call(req, options, &block)
          end

          # Updates an existing incident.
          #
          # @param incident [Google::Cloud::Irm::V1alpha2::Incident | Hash]
          #   The incident to update with the new values.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Incident`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   List of fields that should be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Incident]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Incident]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #
          #   # TODO: Initialize `incident`:
          #   incident = {}
          #   response = incident_client.update_incident(incident)

          def update_incident \
              incident,
              update_mask: nil,
              options: nil,
              &block
            req = {
              incident: incident,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::UpdateIncidentRequest)
            @update_incident.call(req, options, &block)
          end

          # Returns a list of incidents that are "similar" to the specified incident
          # or signal. This functionality is provided on a best-effort basis and the
          # definition of "similar" is subject to change.
          #
          # @param name [String]
          #   Resource name of the incident or signal, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsResponse::Result>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsResponse::Result>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsResponse::Result instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # Iterate over all results.
          #   incident_client.search_similar_incidents(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.search_similar_incidents(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def search_similar_incidents \
              name,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsRequest)
            @search_similar_incidents.call(req, options, &block)
          end

          # Creates an annotation on an existing incident. Only 'text/plain' and
          # 'text/markdown' annotations can be created via this method.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
          # @param annotation [Google::Cloud::Irm::V1alpha2::Annotation | Hash]
          #   Only annotation.content is an input argument.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Annotation`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Annotation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Annotation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # TODO: Initialize `annotation`:
          #   annotation = {}
          #   response = incident_client.create_annotation(formatted_parent, annotation)

          def create_annotation \
              parent,
              annotation,
              options: nil,
              &block
            req = {
              parent: parent,
              annotation: annotation
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CreateAnnotationRequest)
            @create_annotation.call(req, options, &block)
          end

          # Lists annotations that are part of an incident. No assumptions should be
          # made on the content-type of the annotation returned.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Annotation>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Annotation>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::Annotation instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # Iterate over all results.
          #   incident_client.list_annotations(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.list_annotations(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_annotations \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::ListAnnotationsRequest)
            @list_annotations.call(req, options, &block)
          end

          # Creates a tag on an existing incident.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
          # @param tag [Google::Cloud::Irm::V1alpha2::Tag | Hash]
          #   Tag to create. Only tag.display_name is an input argument.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Tag`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Tag]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Tag]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # TODO: Initialize `tag`:
          #   tag = {}
          #   response = incident_client.create_tag(formatted_parent, tag)

          def create_tag \
              parent,
              tag,
              options: nil,
              &block
            req = {
              parent: parent,
              tag: tag
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CreateTagRequest)
            @create_tag.call(req, options, &block)
          end

          # Deletes an existing tag.
          #
          # @param name [String]
          #   Resource name of the tag.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.tag_path("[PROJECT]", "[INCIDENT]", "[TAG]")
          #   incident_client.delete_tag(formatted_name)

          def delete_tag \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::DeleteTagRequest)
            @delete_tag.call(req, options, &block)
            nil
          end

          # Lists tags that are part of an incident.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Tag>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Tag>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::Tag instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # Iterate over all results.
          #   incident_client.list_tags(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.list_tags(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_tags \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::ListTagsRequest)
            @list_tags.call(req, options, &block)
          end

          # Creates a new signal.
          #
          # @param parent [String]
          #   The resource name of the hosting Stackdriver project which requested
          #   signal belongs to.
          # @param signal [Google::Cloud::Irm::V1alpha2::Signal | Hash]
          #   The signal to create.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Signal`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Signal]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Signal]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `signal`:
          #   signal = {}
          #   response = incident_client.create_signal(formatted_parent, signal)

          def create_signal \
              parent,
              signal,
              options: nil,
              &block
            req = {
              parent: parent,
              signal: signal
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CreateSignalRequest)
            @create_signal.call(req, options, &block)
          end

          # Lists signals that are part of an incident.
          # Signals are returned in reverse chronological order.
          #
          # @param parent [String]
          #   The resource name of the hosting Stackdriver project which requested
          #   incidents belong to.
          # @param query [String]
          #   An expression that defines which signals to return.
          #
          #   Search atoms can be used to match certain specific fields.  Otherwise,
          #   plain text will match text fields in the signal.
          #
          #   Search atoms:
          #
          #   * `start` - (timestamp) The time the signal was created.
          #   * `title` - The title of the signal.
          #   * `signal_state` - `open` or `closed`. State of the signal.
          #     (e.g., `signal_state:open`)
          #
          #   Timestamp formats:
          #
          #   * yyyy-MM-dd - an absolute date, treated as a calendar-day-wide window.
          #     In other words, the "<" operator will match dates before that date, the
          #     ">" operator will match dates after that date, and the ":" operator will
          #     match the entire day.
          #   * yyyy-MM-ddTHH:mm - Same as above, but with minute resolution.
          #   * yyyy-MM-ddTHH:mm:ss - Same as above, but with second resolution.
          #   * Nd (e.g. 7d) - a relative number of days ago, treated as a moment in time
          #     (as opposed to a day-wide span) a multiple of 24 hours ago (as opposed to
          #     calendar days).  In the case of daylight savings time, it will apply the
          #     current timezone to both ends of the range.  Note that exact matching
          #     (e.g. `start:7d`) is unlikely to be useful because that would only match
          #     signals created precisely at a particular instant in time.
          #
          #   The absolute timestamp formats (everything starting with a year) can
          #   optionally be followed with a UTC offset in +/-hh:mm format.  Also, the 'T'
          #   separating dates and times can optionally be replaced with a space. Note
          #   that any timestamp containing a space or colon will need to be quoted.
          #
          #   Examples:
          #
          #   * `foo` - matches signals containing the word "foo"
          #   * `"foo bar"` - matches signals containing the phrase "foo bar"
          #   * `foo bar` or `foo AND bar` - matches signals containing the words
          #     "foo" and "bar"
          #   * `foo -bar` or `foo AND NOT bar` - matches signals containing the
          #     word
          #     "foo" but not the word "bar"
          #   * `foo OR bar` - matches signals containing the word "foo" or the
          #     word "bar"
          #   * `start>2018-11-28` - matches signals which started after November
          #     11, 2018.
          #   * `start<=2018-11-28` - matches signals which started on or before
          #     November 11, 2018.
          #   * `start:2018-11-28` - matches signals which started on November 11,
          #     2018.
          #   * `start>"2018-11-28 01:02:03+04:00"` - matches signals which started
          #     after November 11, 2018 at 1:02:03 AM according to the UTC+04 time
          #     zone.
          #   * `start>7d` - matches signals which started after the point in time
          #     7*24 hours ago
          #   * `start>180d` - similar to 7d, but likely to cross the daylight savings
          #     time boundary, so the end time will be 1 hour different from "now."
          #   * `foo AND start>90d AND stage<resolved` - unresolved signals from
          #     the past 90 days containing the word "foo"
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Signal>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Signal>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::Signal instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   incident_client.search_signals(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.search_signals(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def search_signals \
              parent,
              query: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              query: query,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::SearchSignalsRequest)
            @search_signals.call(req, options, &block)
          end

          # Returns a signal by name.
          #
          # @param name [String]
          #   Resource name of the Signal resource, for example,
          #   "projects/{project_id}/signals/{signal_id}".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Signal]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Signal]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.signal_path("[PROJECT]", "[SIGNAL]")
          #   response = incident_client.get_signal(formatted_name)

          def get_signal \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::GetSignalRequest)
            @get_signal.call(req, options, &block)
          end

          # Finds a signal by other unique IDs.
          #
          # @param cscc_finding [String]
          #   Full resource name of the CSCC finding id this signal refers to (e.g.
          #   "organizations/abc/sources/123/findings/xyz")
          # @param stackdriver_notification_id [String]
          #   The ID from the Stackdriver Alerting notification.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Signal]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Signal]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   response = incident_client.lookup_signal

          def lookup_signal \
              cscc_finding: nil,
              stackdriver_notification_id: nil,
              options: nil,
              &block
            req = {
              cscc_finding: cscc_finding,
              stackdriver_notification_id: stackdriver_notification_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::LookupSignalRequest)
            @lookup_signal.call(req, options, &block)
          end

          # Updates an existing signal (for example, to assign/unassign it to an
          # incident).
          #
          # @param signal [Google::Cloud::Irm::V1alpha2::Signal | Hash]
          #   The signal to update with the new values.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Signal`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   List of fields that should be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Signal]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Signal]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #
          #   # TODO: Initialize `signal`:
          #   signal = {}
          #   response = incident_client.update_signal(signal)

          def update_signal \
              signal,
              update_mask: nil,
              options: nil,
              &block
            req = {
              signal: signal,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::UpdateSignalRequest)
            @update_signal.call(req, options, &block)
          end

          # Escalates an incident.
          #
          # @param incident [Google::Cloud::Irm::V1alpha2::Incident | Hash]
          #   The incident to escalate with the new values.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Incident`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   List of fields that should be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param subscriptions [Array<Google::Cloud::Irm::V1alpha2::Subscription | Hash>]
          #   Subscriptions to add or update. Existing subscriptions with the same
          #   channel and address as a subscription in the list will be updated.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Subscription`
          #   can also be provided.
          # @param tags [Array<Google::Cloud::Irm::V1alpha2::Tag | Hash>]
          #   Tags to add. Tags identical to existing tags will be ignored.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Tag`
          #   can also be provided.
          # @param roles [Array<Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment | Hash>]
          #   Roles to add or update. Existing roles with the same type (and title, for
          #   TYPE_OTHER roles) will be updated.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment`
          #   can also be provided.
          # @param artifacts [Array<Google::Cloud::Irm::V1alpha2::Artifact | Hash>]
          #   Artifacts to add. All artifacts are added without checking for duplicates.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Artifact`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::EscalateIncidentResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::EscalateIncidentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #
          #   # TODO: Initialize `incident`:
          #   incident = {}
          #   response = incident_client.escalate_incident(incident)

          def escalate_incident \
              incident,
              update_mask: nil,
              subscriptions: nil,
              tags: nil,
              roles: nil,
              artifacts: nil,
              options: nil,
              &block
            req = {
              incident: incident,
              update_mask: update_mask,
              subscriptions: subscriptions,
              tags: tags,
              roles: roles,
              artifacts: artifacts
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::EscalateIncidentRequest)
            @escalate_incident.call(req, options, &block)
          end

          # Creates a new artifact.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
          # @param artifact [Google::Cloud::Irm::V1alpha2::Artifact | Hash]
          #   The artifact to create.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Artifact`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Artifact]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Artifact]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # TODO: Initialize `artifact`:
          #   artifact = {}
          #   response = incident_client.create_artifact(formatted_parent, artifact)

          def create_artifact \
              parent,
              artifact,
              options: nil,
              &block
            req = {
              parent: parent,
              artifact: artifact
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CreateArtifactRequest)
            @create_artifact.call(req, options, &block)
          end

          # Returns a list of artifacts for an incident.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Artifact>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Artifact>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::Artifact instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # Iterate over all results.
          #   incident_client.list_artifacts(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.list_artifacts(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_artifacts \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::ListArtifactsRequest)
            @list_artifacts.call(req, options, &block)
          end

          # Updates an existing artifact.
          #
          # @param artifact [Google::Cloud::Irm::V1alpha2::Artifact | Hash]
          #   The artifact to update with the new values.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Artifact`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   List of fields that should be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Artifact]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Artifact]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #
          #   # TODO: Initialize `artifact`:
          #   artifact = {}
          #   response = incident_client.update_artifact(artifact)

          def update_artifact \
              artifact,
              update_mask: nil,
              options: nil,
              &block
            req = {
              artifact: artifact,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::UpdateArtifactRequest)
            @update_artifact.call(req, options, &block)
          end

          # Deletes an existing artifact.
          #
          # @param name [String]
          #   Resource name of the artifact.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.artifact_path("[PROJECT]", "[INCIDENT]", "[ARTIFACT]")
          #   incident_client.delete_artifact(formatted_name)

          def delete_artifact \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::DeleteArtifactRequest)
            @delete_artifact.call(req, options, &block)
            nil
          end

          # Sends a summary of the shift for oncall handoff.
          #
          # @param parent [String]
          #   The resource name of the Stackdriver project that the handoff is being sent
          #   from. for example, `projects/{project_id}`
          # @param recipients [Array<String>]
          #   Email addresses of the recipients of the handoff, for example,
          #   "user@example.com". Must contain at least one entry.
          # @param subject [String]
          #   The subject of the email. Required.
          # @param cc [Array<String>]
          #   Email addresses that should be CC'd on the handoff. Optional.
          # @param notes_content_type [String]
          #   Content type string, for example, 'text/plain' or 'text/html'.
          # @param notes_content [String]
          #   Additional notes to be included in the handoff. Optional.
          # @param incidents [Array<Google::Cloud::Irm::V1alpha2::SendShiftHandoffRequest::Incident | Hash>]
          #   The set of incidents that should be included in the handoff. Optional.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::SendShiftHandoffRequest::Incident`
          #   can also be provided.
          # @param preview_only [true, false]
          #   If set to true a ShiftHandoffResponse will be returned but the handoff
          #   will not actually be sent.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::SendShiftHandoffResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::SendShiftHandoffResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `recipients`:
          #   recipients = []
          #
          #   # TODO: Initialize `subject`:
          #   subject = ''
          #   response = incident_client.send_shift_handoff(formatted_parent, recipients, subject)

          def send_shift_handoff \
              parent,
              recipients,
              subject,
              cc: nil,
              notes_content_type: nil,
              notes_content: nil,
              incidents: nil,
              preview_only: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              recipients: recipients,
              subject: subject,
              cc: cc,
              notes_content_type: notes_content_type,
              notes_content: notes_content,
              incidents: incidents,
              preview_only: preview_only
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::SendShiftHandoffRequest)
            @send_shift_handoff.call(req, options, &block)
          end

          # Creates a new subscription.
          # This will fail if:
          #    a. there are too many (50) subscriptions in the incident already
          #    b. a subscription using the given channel already exists
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
          # @param subscription [Google::Cloud::Irm::V1alpha2::Subscription | Hash]
          #   The subscription to create.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Subscription`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Subscription]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Subscription]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # TODO: Initialize `subscription`:
          #   subscription = {}
          #   response = incident_client.create_subscription(formatted_parent, subscription)

          def create_subscription \
              parent,
              subscription,
              options: nil,
              &block
            req = {
              parent: parent,
              subscription: subscription
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CreateSubscriptionRequest)
            @create_subscription.call(req, options, &block)
          end

          # Updates a subscription.
          #
          # @param subscription [Google::Cloud::Irm::V1alpha2::Subscription | Hash]
          #   The subscription to update, with new values.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::Subscription`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   List of fields that should be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::Subscription]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::Subscription]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #
          #   # TODO: Initialize `subscription`:
          #   subscription = {}
          #   response = incident_client.update_subscription(subscription)

          def update_subscription \
              subscription,
              update_mask: nil,
              options: nil,
              &block
            req = {
              subscription: subscription,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::UpdateSubscriptionRequest)
            @update_subscription.call(req, options, &block)
          end

          # Returns a list of subscriptions for an incident.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Subscription>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::Subscription>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::Subscription instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # Iterate over all results.
          #   incident_client.list_subscriptions(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.list_subscriptions(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_subscriptions \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::ListSubscriptionsRequest)
            @list_subscriptions.call(req, options, &block)
          end

          # Deletes an existing subscription.
          #
          # @param name [String]
          #   Resource name of the subscription.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.subscription_path("[PROJECT]", "[INCIDENT]", "[SUBSCRIPTION]")
          #   incident_client.delete_subscription(formatted_name)

          def delete_subscription \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::DeleteSubscriptionRequest)
            @delete_subscription.call(req, options, &block)
            nil
          end

          # Creates a role assignment on an existing incident. Normally, the user field
          # will be set when assigning a role to oneself, and the next field will be
          # set when proposing another user as the assignee. Setting the next field
          # directly to a user other than oneself is equivalent to proposing and
          # force-assigning the role to the user.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
          # @param incident_role_assignment [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment | Hash]
          #   Role assignment to create.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # TODO: Initialize `incident_role_assignment`:
          #   incident_role_assignment = {}
          #   response = incident_client.create_incident_role_assignment(formatted_parent, incident_role_assignment)

          def create_incident_role_assignment \
              parent,
              incident_role_assignment,
              options: nil,
              &block
            req = {
              parent: parent,
              incident_role_assignment: incident_role_assignment
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CreateIncidentRoleAssignmentRequest)
            @create_incident_role_assignment.call(req, options, &block)
          end

          # Deletes an existing role assignment.
          #
          # @param name [String]
          #   Resource name of the role assignment.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
          #   incident_client.delete_incident_role_assignment(formatted_name)

          def delete_incident_role_assignment \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::DeleteIncidentRoleAssignmentRequest)
            @delete_incident_role_assignment.call(req, options, &block)
            nil
          end

          # Lists role assignments that are part of an incident.
          #
          # @param parent [String]
          #   Resource name of the incident, for example,
          #   "projects/{project_id}/incidents/{incident_id}".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment>]
          #   An enumerable of Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
          #
          #   # Iterate over all results.
          #   incident_client.list_incident_role_assignments(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   incident_client.list_incident_role_assignments(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_incident_role_assignments \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::ListIncidentRoleAssignmentsRequest)
            @list_incident_role_assignments.call(req, options, &block)
          end

          # Starts a role handover. The proposed assignee will receive an email
          # notifying them of the assignment. This will fail if a role handover is
          # already pending.
          #
          # @param name [String]
          #   Resource name of the role assignment.
          # @param new_assignee [Google::Cloud::Irm::V1alpha2::User | Hash]
          #   The proposed assignee.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::User`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
          #
          #   # TODO: Initialize `new_assignee`:
          #   new_assignee = {}
          #   response = incident_client.request_incident_role_handover(formatted_name, new_assignee)

          def request_incident_role_handover \
              name,
              new_assignee,
              options: nil,
              &block
            req = {
              name: name,
              new_assignee: new_assignee
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::RequestIncidentRoleHandoverRequest)
            @request_incident_role_handover.call(req, options, &block)
          end

          # Confirms a role handover. This will fail if the 'proposed_assignee' field
          # of the IncidentRoleAssignment is not equal to the 'new_assignee' field of
          # the request. If the caller is not the new_assignee,
          # ForceIncidentRoleHandover should be used instead.
          #
          # @param name [String]
          #   Resource name of the role assignment.
          # @param new_assignee [Google::Cloud::Irm::V1alpha2::User | Hash]
          #   The proposed assignee, who will now be the assignee. This should be the
          #   current user; otherwise ForceRoleHandover should be called.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::User`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
          #
          #   # TODO: Initialize `new_assignee`:
          #   new_assignee = {}
          #   response = incident_client.confirm_incident_role_handover(formatted_name, new_assignee)

          def confirm_incident_role_handover \
              name,
              new_assignee,
              options: nil,
              &block
            req = {
              name: name,
              new_assignee: new_assignee
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::ConfirmIncidentRoleHandoverRequest)
            @confirm_incident_role_handover.call(req, options, &block)
          end

          # Forces a role handover. This will fail if the 'proposed_assignee' field of
          # the IncidentRoleAssignment is not equal to the 'new_assignee' field of the
          # request. If the caller is the new_assignee, ConfirmIncidentRoleHandover
          # should be used instead.
          #
          # @param name [String]
          #   Resource name of the role assignment.
          # @param new_assignee [Google::Cloud::Irm::V1alpha2::User | Hash]
          #   The proposed assignee, who will now be the assignee. This should not be
          #   the current user; otherwise ConfirmRoleHandover should be called.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::User`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
          #
          #   # TODO: Initialize `new_assignee`:
          #   new_assignee = {}
          #   response = incident_client.force_incident_role_handover(formatted_name, new_assignee)

          def force_incident_role_handover \
              name,
              new_assignee,
              options: nil,
              &block
            req = {
              name: name,
              new_assignee: new_assignee
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::ForceIncidentRoleHandoverRequest)
            @force_incident_role_handover.call(req, options, &block)
          end

          # Cancels a role handover. This will fail if the 'proposed_assignee' field of
          # the IncidentRoleAssignment is not equal to the 'new_assignee' field of the
          # request.
          #
          # @param name [String]
          #   Resource name of the role assignment.
          # @param new_assignee [Google::Cloud::Irm::V1alpha2::User | Hash]
          #   Person who was proposed as the next assignee (i.e.
          #   IncidentRoleAssignment.proposed_assignee) and whose proposal is being
          #   cancelled.
          #   A hash of the same form as `Google::Cloud::Irm::V1alpha2::User`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/irm"
          #
          #   incident_client = Google::Cloud::Irm.new(version: :v1alpha2)
          #   formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
          #
          #   # TODO: Initialize `new_assignee`:
          #   new_assignee = {}
          #   response = incident_client.cancel_incident_role_handover(formatted_name, new_assignee)

          def cancel_incident_role_handover \
              name,
              new_assignee,
              options: nil,
              &block
            req = {
              name: name,
              new_assignee: new_assignee
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Irm::V1alpha2::CancelIncidentRoleHandoverRequest)
            @cancel_incident_role_handover.call(req, options, &block)
          end
        end
      end
    end
  end
end
