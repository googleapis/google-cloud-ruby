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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/talent/v4beta1/profile_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/talent/v4beta1/profile_service_pb"
require "google/cloud/talent/v4beta1/credentials"
require "google/cloud/talent/version"

module Google
  module Cloud
    module Talent
      module V4beta1
        # A service that handles profile management, including profile CRUD,
        # enumeration and search.
        #
        # @!attribute [r] profile_service_stub
        #   @return [Google::Cloud::Talent::V4beta1::ProfileService::Stub]
        class ProfileServiceClient
          # @private
          attr_reader :profile_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "jobs.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "search_profiles" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "summarized_profiles"),
            "list_profiles" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "profiles")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/jobs"
          ].freeze


          PROFILE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/tenants/{tenant}/profiles/{profile}"
          )

          private_constant :PROFILE_PATH_TEMPLATE

          TENANT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/tenants/{tenant}"
          )

          private_constant :TENANT_PATH_TEMPLATE

          # Returns a fully-qualified profile resource name string.
          # @param project [String]
          # @param tenant [String]
          # @param profile [String]
          # @return [String]
          def self.profile_path project, tenant, profile
            PROFILE_PATH_TEMPLATE.render(
              :"project" => project,
              :"tenant" => tenant,
              :"profile" => profile
            )
          end

          # Returns a fully-qualified tenant resource name string.
          # @param project [String]
          # @param tenant [String]
          # @return [String]
          def self.tenant_path project, tenant
            TENANT_PATH_TEMPLATE.render(
              :"project" => project,
              :"tenant" => tenant
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
            require "google/cloud/talent/v4beta1/profile_service_services_pb"

            credentials ||= Google::Cloud::Talent::V4beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Talent::V4beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Talent::VERSION

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
              "profile_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.talent.v4beta1.ProfileService",
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
            @profile_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Talent::V4beta1::ProfileService::Stub.method(:new)
            )

            @delete_profile = Google::Gax.create_api_call(
              @profile_service_stub.method(:delete_profile),
              defaults["delete_profile"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @search_profiles = Google::Gax.create_api_call(
              @profile_service_stub.method(:search_profiles),
              defaults["search_profiles"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_profiles = Google::Gax.create_api_call(
              @profile_service_stub.method(:list_profiles),
              defaults["list_profiles"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_profile = Google::Gax.create_api_call(
              @profile_service_stub.method(:create_profile),
              defaults["create_profile"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_profile = Google::Gax.create_api_call(
              @profile_service_stub.method(:get_profile),
              defaults["get_profile"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @update_profile = Google::Gax.create_api_call(
              @profile_service_stub.method(:update_profile),
              defaults["update_profile"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'profile.name' => request.profile.name}
              end
            )
          end

          # Service calls

          # Deletes the specified profile.
          # Prerequisite: The profile has no associated applications or assignments
          # associated.
          #
          # @param name [String]
          #   Required. Resource name of the profile to be deleted.
          #
          #   The format is
          #   "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}". For
          #   example, "projects/foo/tenants/bar/profiles/baz".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   profile_client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)
          #   formatted_name = Google::Cloud::Talent::V4beta1::ProfileServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")
          #   profile_client.delete_profile(formatted_name)

          def delete_profile \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::DeleteProfileRequest)
            @delete_profile.call(req, options, &block)
            nil
          end

          # Searches for profiles within a tenant.
          #
          # For example, search by raw queries "software engineer in Mountain View" or
          # search by structured filters (location filter, education filter, etc.).
          #
          # See {Google::Cloud::Talent::V4beta1::SearchProfilesRequest SearchProfilesRequest} for more information.
          #
          # @param parent [String]
          #   Required. The resource name of the tenant to search within.
          #
          #   The format is "projects/{project_id}/tenants/{tenant_id}". For example,
          #   "projects/foo/tenants/bar".
          # @param request_metadata [Google::Cloud::Talent::V4beta1::RequestMetadata | Hash]
          #   Required. The meta information collected about the profile search user. This is used
          #   to improve the search quality of the service. These values are provided by
          #   users, and must be precise and consistent.
          #   A hash of the same form as `Google::Cloud::Talent::V4beta1::RequestMetadata`
          #   can also be provided.
          # @param profile_query [Google::Cloud::Talent::V4beta1::ProfileQuery | Hash]
          #   Search query to execute. See {Google::Cloud::Talent::V4beta1::ProfileQuery ProfileQuery} for more details.
          #   A hash of the same form as `Google::Cloud::Talent::V4beta1::ProfileQuery`
          #   can also be provided.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param offset [Integer]
          #   An integer that specifies the current offset (that is, starting result) in
          #   search results. This field is only considered if {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#page_token page_token} is unset.
          #
          #   The maximum allowed value is 5000. Otherwise an error is thrown.
          #
          #   For example, 0 means to search from the first profile, and 10 means to
          #   search from the 11th profile. This can be used for pagination, for example
          #   pageSize = 10 and offset = 10 means to search from the second page.
          # @param disable_spell_check [true, false]
          #   This flag controls the spell-check feature. If `false`, the
          #   service attempts to correct a misspelled query.
          #
          #   For example, "enginee" is corrected to "engineer".
          # @param order_by [String]
          #   The criteria that determines how search results are sorted.
          #   Defaults is "relevance desc" if no value is specified.
          #
          #   Supported options are:
          #
          #   * "relevance desc": By descending relevance, as determined by the API
          #     algorithms.
          #   * "update_date desc": Sort by {Google::Cloud::Talent::V4beta1::Profile#update_time Profile#update_time} in descending order
          #     (recently updated profiles first).
          #   * "create_date desc": Sort by {Google::Cloud::Talent::V4beta1::Profile#create_time Profile#create_time} in descending order
          #     (recently created profiles first).
          #   * "first_name": Sort by {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#given_name PersonName::PersonStructuredName#given_name} in
          #     ascending order.
          #   * "first_name desc": Sort by {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#given_name PersonName::PersonStructuredName#given_name}
          #     in descending order.
          #   * "last_name": Sort by {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#family_name PersonName::PersonStructuredName#family_name} in
          #     ascending order.
          #   * "last_name desc": Sort by {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#family_name PersonName::PersonStructuredName#family_name}
          #     in ascending order.
          # @param case_sensitive_sort [true, false]
          #   When sort by field is based on alphabetical order, sort values case
          #   sensitively (based on ASCII) when the value is set to true. Default value
          #   is case in-sensitive sort (false).
          # @param histogram_queries [Array<Google::Cloud::Talent::V4beta1::HistogramQuery | Hash>]
          #   A list of expressions specifies histogram requests against matching
          #   profiles for {Google::Cloud::Talent::V4beta1::SearchProfilesRequest SearchProfilesRequest}.
          #
          #   The expression syntax looks like a function definition with parameters.
          #
          #   Function syntax: function_name(histogram_facet[, list of buckets])
          #
          #   Data types:
          #
          #   * Histogram facet: facet names with format [a-zA-Z][a-zA-Z0-9_]+.
          #   * String: string like "any string with backslash escape for quote(\")."
          #   * Number: whole number and floating point number like 10, -1 and -0.01.
          #   * List: list of elements with comma(,) separator surrounded by square
          #     brackets. For example, [1, 2, 3] and ["one", "two", "three"].
          #
          #   Built-in constants:
          #
          #   * MIN (minimum number similar to java Double.MIN_VALUE)
          #   * MAX (maximum number similar to java Double.MAX_VALUE)
          #
          #   Built-in functions:
          #
          #   * bucket(start, end[, label])
          #     Bucket build-in function creates a bucket with range of [start, end). Note
          #     that the end is exclusive.
          #     For example, bucket(1, MAX, "positive number") or bucket(1, 10).
          #
          #   Histogram Facets:
          #
          #   * admin1: Admin1 is a global placeholder for referring to state, province,
          #     or the particular term a country uses to define the geographic structure
          #     below the country level. Examples include states codes such as "CA", "IL",
          #     "NY", and provinces, such as "BC".
          #   * locality: Locality is a global placeholder for referring to city, town,
          #     or the particular term a country uses to define the geographic structure
          #     below the admin1 level. Examples include city names such as
          #     "Mountain View" and "New York".
          #   * extended_locality: Extended locality is concatenated version of admin1
          #     and locality with comma separator. For example, "Mountain View, CA" and
          #     "New York, NY".
          #   * postal_code: Postal code of profile which follows locale code.
          #   * country: Country code (ISO-3166-1 alpha-2 code) of profile, such as US,
          #     JP, GB.
          #   * job_title: Normalized job titles specified in EmploymentHistory.
          #   * company_name: Normalized company name of profiles to match on.
          #   * institution: The school name. For example, "MIT",
          #     "University of California, Berkeley"
          #   * degree: Highest education degree in ISCED code. Each value in degree
          #     covers a specific level of education, without any expansion to upper nor
          #     lower levels of education degree.
          #   * experience_in_months: experience in months. 0 means 0 month to 1 month
          #     (exclusive).
          #   * application_date: The application date specifies application start dates.
          #     See {Google::Cloud::Talent::V4beta1::ApplicationDateFilter ApplicationDateFilter} for more details.
          #   * application_outcome_notes: The application outcome reason specifies the
          #     reasons behind the outcome of the job application.
          #     See {Google::Cloud::Talent::V4beta1::ApplicationOutcomeNotesFilter ApplicationOutcomeNotesFilter} for more details.
          #   * application_job_title: The application job title specifies the job
          #     applied for in the application.
          #     See {Google::Cloud::Talent::V4beta1::ApplicationJobFilter ApplicationJobFilter} for more details.
          #   * hirable_status: Hirable status specifies the profile's hirable status.
          #   * string_custom_attribute: String custom attributes. Values can be accessed
          #     via square bracket notation like string_custom_attribute["key1"].
          #   * numeric_custom_attribute: Numeric custom attributes. Values can be
          #     accessed via square bracket notation like numeric_custom_attribute["key1"].
          #
          #   Example expressions:
          #
          #   * count(admin1)
          #   * count(experience_in_months, [bucket(0, 12, "1 year"),
          #     bucket(12, 36, "1-3 years"), bucket(36, MAX, "3+ years")])
          #   * count(string_custom_attribute["assigned_recruiter"])
          #   * count(numeric_custom_attribute["favorite_number"],
          #     [bucket(MIN, 0, "negative"), bucket(0, MAX, "non-negative")])
          #   A hash of the same form as `Google::Cloud::Talent::V4beta1::HistogramQuery`
          #   can also be provided.
          # @param result_set_id [String]
          #   An id that uniquely identifies the result set of a
          #   {Google::Cloud::Talent::V4beta1::ProfileService::SearchProfiles SearchProfiles} call. The id should be
          #   retrieved from the
          #   {Google::Cloud::Talent::V4beta1::SearchProfilesResponse SearchProfilesResponse} message returned from a previous
          #   invocation of {Google::Cloud::Talent::V4beta1::ProfileService::SearchProfiles SearchProfiles}.
          #
          #   A result set is an ordered list of search results.
          #
          #   If this field is not set, a new result set is computed based on the
          #   {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#profile_query profile_query}.  A new {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#result_set_id result_set_id} is returned as a handle to
          #   access this result set.
          #
          #   If this field is set, the service will ignore the resource and
          #   {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#profile_query profile_query} values, and simply retrieve a page of results from the
          #   corresponding result set.  In this case, one and only one of {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#page_token page_token}
          #   or {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#offset offset} must be set.
          #
          #   A typical use case is to invoke {Google::Cloud::Talent::V4beta1::SearchProfilesRequest SearchProfilesRequest} without this
          #   field, then use the resulting {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#result_set_id result_set_id} in
          #   {Google::Cloud::Talent::V4beta1::SearchProfilesResponse SearchProfilesResponse} to page through the results.
          # @param strict_keywords_search [true, false]
          #   This flag is used to indicate whether the service will attempt to
          #   understand synonyms and terms related to the search query or treat the
          #   query "as is" when it generates a set of results. By default this flag is
          #   set to false, thus allowing expanded results to also be returned. For
          #   example a search for "software engineer" might also return candidates who
          #   have experience in jobs similar to software engineer positions. By setting
          #   this flag to true, the service will only attempt to deliver candidates has
          #   software engineer in his/her global fields by treating "software engineer"
          #   as a keyword.
          #
          #   It is recommended to provide a feature in the UI (such as a checkbox) to
          #   allow recruiters to set this flag to true if they intend to search for
          #   longer boolean strings.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Talent::V4beta1::SummarizedProfile>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Talent::V4beta1::SummarizedProfile>]
          #   An enumerable of Google::Cloud::Talent::V4beta1::SummarizedProfile instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   profile_client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)
          #   formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")
          #
          #   # TODO: Initialize `request_metadata`:
          #   request_metadata = {}
          #
          #   # Iterate over all results.
          #   profile_client.search_profiles(formatted_parent, request_metadata).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   profile_client.search_profiles(formatted_parent, request_metadata).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def search_profiles \
              parent,
              request_metadata,
              profile_query: nil,
              page_size: nil,
              offset: nil,
              disable_spell_check: nil,
              order_by: nil,
              case_sensitive_sort: nil,
              histogram_queries: nil,
              result_set_id: nil,
              strict_keywords_search: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              request_metadata: request_metadata,
              profile_query: profile_query,
              page_size: page_size,
              offset: offset,
              disable_spell_check: disable_spell_check,
              order_by: order_by,
              case_sensitive_sort: case_sensitive_sort,
              histogram_queries: histogram_queries,
              result_set_id: result_set_id,
              strict_keywords_search: strict_keywords_search
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::SearchProfilesRequest)
            @search_profiles.call(req, options, &block)
          end

          # Lists profiles by filter. The order is unspecified.
          #
          # @param parent [String]
          #   Required. The resource name of the tenant under which the profile is created.
          #
          #   The format is "projects/{project_id}/tenants/{tenant_id}". For example,
          #   "projects/foo/tenants/bar".
          # @param filter [String]
          #   The filter string specifies the profiles to be enumerated.
          #
          #   Supported operator: =, AND
          #
          #   The field(s) eligible for filtering are:
          #
          #   * `externalId`
          #   * `groupId`
          #
          #   externalId and groupId cannot be specified at the same time. If both
          #   externalId and groupId are provided, the API will return a bad request
          #   error.
          #
          #   Sample Query:
          #
          #   * externalId = "externalId-1"
          #   * groupId = "groupId-1"
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param read_mask [Google::Protobuf::FieldMask | Hash]
          #   A field mask to specify the profile fields to be listed in response.
          #   All fields are listed if it is unset.
          #
          #   Valid values are:
          #
          #   * name
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Talent::V4beta1::Profile>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Talent::V4beta1::Profile>]
          #   An enumerable of Google::Cloud::Talent::V4beta1::Profile instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   profile_client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)
          #   formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")
          #
          #   # Iterate over all results.
          #   profile_client.list_profiles(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   profile_client.list_profiles(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_profiles \
              parent,
              filter: nil,
              page_size: nil,
              read_mask: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size,
              read_mask: read_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::ListProfilesRequest)
            @list_profiles.call(req, options, &block)
          end

          # Creates and returns a new profile.
          #
          # @param parent [String]
          #   Required. The name of the tenant this profile belongs to.
          #
          #   The format is "projects/{project_id}/tenants/{tenant_id}". For example,
          #   "projects/foo/tenants/bar".
          # @param profile [Google::Cloud::Talent::V4beta1::Profile | Hash]
          #   Required. The profile to be created.
          #   A hash of the same form as `Google::Cloud::Talent::V4beta1::Profile`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Talent::V4beta1::Profile]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Talent::V4beta1::Profile]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   profile_client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)
          #   formatted_parent = Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path("[PROJECT]", "[TENANT]")
          #
          #   # TODO: Initialize `profile`:
          #   profile = {}
          #   response = profile_client.create_profile(formatted_parent, profile)

          def create_profile \
              parent,
              profile,
              options: nil,
              &block
            req = {
              parent: parent,
              profile: profile
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::CreateProfileRequest)
            @create_profile.call(req, options, &block)
          end

          # Gets the specified profile.
          #
          # @param name [String]
          #   Required. Resource name of the profile to get.
          #
          #   The format is
          #   "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}". For
          #   example, "projects/foo/tenants/bar/profiles/baz".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Talent::V4beta1::Profile]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Talent::V4beta1::Profile]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   profile_client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)
          #   formatted_name = Google::Cloud::Talent::V4beta1::ProfileServiceClient.profile_path("[PROJECT]", "[TENANT]", "[PROFILE]")
          #   response = profile_client.get_profile(formatted_name)

          def get_profile \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::GetProfileRequest)
            @get_profile.call(req, options, &block)
          end

          # Updates the specified profile and returns the updated result.
          #
          # @param profile [Google::Cloud::Talent::V4beta1::Profile | Hash]
          #   Required. Profile to be updated.
          #   A hash of the same form as `Google::Cloud::Talent::V4beta1::Profile`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   A field mask to specify the profile fields to update.
          #
          #   A full update is performed if it is unset.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Talent::V4beta1::Profile]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Talent::V4beta1::Profile]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   profile_client = Google::Cloud::Talent::ProfileService.new(version: :v4beta1)
          #
          #   # TODO: Initialize `profile`:
          #   profile = {}
          #   response = profile_client.update_profile(profile)

          def update_profile \
              profile,
              update_mask: nil,
              options: nil,
              &block
            req = {
              profile: profile,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::UpdateProfileRequest)
            @update_profile.call(req, options, &block)
          end
        end
      end
    end
  end
end
