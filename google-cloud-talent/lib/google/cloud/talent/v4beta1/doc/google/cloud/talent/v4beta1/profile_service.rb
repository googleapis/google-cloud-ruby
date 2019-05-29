# Copyright 2019 Google LLC
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


module Google
  module Cloud
    module Talent
      module V4beta1
        # List profiles request.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required.
        #
        #     The resource name of the tenant under which the job is created.
        #
        #     The format is "projects/{project_id}/tenants/{tenant_id}", for example,
        #     "projects/api-test-project/tenants/foo".
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional.
        #
        #     The token that specifies the current offset (that is, starting result).
        #
        #     Please set the value to
        #     {Google::Cloud::Talent::V4beta1::ListProfilesResponse#next_page_token ListProfilesResponse#next_page_token}
        #     to continue the list.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional.
        #
        #     The maximum number of profiles to be returned, at most 100.
        #
        #     Default is 100 unless a positive number smaller than 100 is specified.
        # @!attribute [rw] read_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional.
        #
        #     A field mask to specify the profile fields to be listed in response.
        #     All fields are listed if it is unset.
        #
        #     Valid values are:
        #
        #     * name
        class ListProfilesRequest; end

        # The List profiles response object.
        # @!attribute [rw] profiles
        #   @return [Array<Google::Cloud::Talent::V4beta1::Profile>]
        #     Profiles for the specific tenant.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A token to retrieve the next page of results. This is empty if there are no
        #     more results.
        class ListProfilesResponse; end

        # Create profile request.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required.
        #
        #     The name of the tenant this profile belongs to.
        #
        #     The format is "projects/{project_id}/tenants/{tenant_id}", for example,
        #     "projects/api-test-project/tenants/foo".
        # @!attribute [rw] profile
        #   @return [Google::Cloud::Talent::V4beta1::Profile]
        #     Required.
        #
        #     The profile to be created.
        class CreateProfileRequest; end

        # Get profile request.
        # @!attribute [rw] name
        #   @return [String]
        #     Required.
        #
        #     Resource name of the profile to get.
        #
        #     The format is
        #     "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}",
        #     for example, "projects/api-test-project/tenants/foo/profiles/bar".
        class GetProfileRequest; end

        # Update profile request
        # @!attribute [rw] profile
        #   @return [Google::Cloud::Talent::V4beta1::Profile]
        #     Required.
        #
        #     Profile to be updated.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional.
        #
        #     A field mask to specify the profile fields to update.
        #
        #     A full update is performed if it is unset.
        #
        #     Valid values are:
        #
        #     * externalId
        #     * source
        #     * uri
        #     * isHirable
        #     * createTime
        #     * updateTime
        #     * resumeHrxml
        #     * personNames
        #     * addresses
        #     * emailAddresses
        #     * phoneNumbers
        #     * personalUris
        #     * additionalContactInfo
        #     * employmentRecords
        #     * educationRecords
        #     * skills
        #     * projects
        #     * publications
        #     * patents
        #     * certifications
        #     * recruitingNotes
        #     * customAttributes
        #     * groupId
        class UpdateProfileRequest; end

        # Delete profile request.
        # @!attribute [rw] name
        #   @return [String]
        #     Required.
        #
        #     Resource name of the profile to be deleted.
        #
        #     The format is
        #     "projects/{project_id}/tenants/{tenant_id}/profiles/{profile_id}",
        #     for example, "projects/api-test-project/tenants/foo/profiles/bar".
        class DeleteProfileRequest; end

        # The request body of the `SearchProfiles` call.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required.
        #
        #     The resource name of the tenant to search within.
        #
        #     The format is "projects/{project_id}/tenants/{tenant_id}", for example,
        #     "projects/api-test-project/tenants/foo".
        # @!attribute [rw] request_metadata
        #   @return [Google::Cloud::Talent::V4beta1::RequestMetadata]
        #     Required.
        #
        #     The meta information collected about the profile search user. This is used
        #     to improve the search quality of the service. These values are provided by
        #     users, and must be precise and consistent.
        # @!attribute [rw] profile_query
        #   @return [Google::Cloud::Talent::V4beta1::ProfileQuery]
        #     Optional.
        #
        #     Search query to execute. See
        #     {Google::Cloud::Talent::V4beta1::ProfileQuery ProfileQuery} for more details.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional.
        #
        #     A limit on the number of profiles returned in the search results.
        #     A value above the default value 10 can increase search response time.
        #
        #     The maximum value allowed is 100. Otherwise an error is thrown.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional.
        #
        #     The pageToken, similar to offset enables users of the API to paginate
        #     through the search results. To retrieve the first page of results, set the
        #     pageToken to empty. The search response includes a
        #     {Google::Cloud::Talent::V4beta1::SearchProfilesResponse#next_page_token nextPageToken}
        #     field that can be used to populate the pageToken field for the next page of
        #     results. Using pageToken instead of offset increases the performance of the
        #     API, especially compared to larger offset values.
        # @!attribute [rw] offset
        #   @return [Integer]
        #     Optional.
        #
        #     An integer that specifies the current offset (that is, starting result) in
        #     search results. This field is only considered if
        #     {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#page_token page_token}
        #     is unset.
        #
        #     The maximum allowed value is 5000. Otherwise an error is thrown.
        #
        #     For example, 0 means to search from the first profile, and 10 means to
        #     search from the 11th profile. This can be used for pagination, for example
        #     pageSize = 10 and offset = 10 means to search from the second page.
        # @!attribute [rw] disable_spell_check
        #   @return [true, false]
        #     Optional.
        #
        #     This flag controls the spell-check feature. If `false`, the
        #     service attempts to correct a misspelled query.
        #
        #     For example, "enginee" is corrected to "engineer".
        # @!attribute [rw] order_by
        #   @return [String]
        #     Optional.
        #
        #     The criteria that determines how search results are sorted.
        #     Defaults is "relevance desc" if no value is specified.
        #
        #     Supported options are:
        #
        #     * "relevance desc": By descending relevance, as determined by the API
        #       algorithms.
        #     * "update_time desc": Sort by
        #       {Google::Cloud::Talent::V4beta1::Profile#update_time Profile#update_time} in
        #       descending order
        #       (recently updated profiles first).
        #     * "create_time desc": Sort by
        #       {Google::Cloud::Talent::V4beta1::Profile#create_time Profile#create_time} in
        #       descending order
        #       (recently created profiles first).
        #     * "first_name": Sort by
        #       {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#given_name PersonName::PersonStructuredName#given_name}
        #       in
        #       ascending order.
        #     * "first_name desc": Sort by
        #       {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#given_name PersonName::PersonStructuredName#given_name}
        #       in descending order.
        #     * "last_name": Sort by
        #       {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#family_name PersonName::PersonStructuredName#family_name}
        #       in
        #       ascending order.
        #     * "last_name desc": Sort by
        #       {Google::Cloud::Talent::V4beta1::PersonName::PersonStructuredName#family_name PersonName::PersonStructuredName#family_name}
        #       in ascending order.
        # @!attribute [rw] case_sensitive_sort
        #   @return [true, false]
        #     Optional.
        #
        #     When sort by field is based on alphabetical order, sort values case
        #     sensitively (based on ASCII) when the value is set to true. Default value
        #     is case in-sensitive sort (false).
        # @!attribute [rw] histogram_queries
        #   @return [Array<Google::Cloud::Talent::V4beta1::HistogramQuery>]
        #     Optional.
        #
        #     A list of expressions specifies histogram requests against matching
        #     profiles for
        #     {Google::Cloud::Talent::V4beta1::SearchProfilesRequest SearchProfilesRequest}.
        #
        #     The expression syntax looks like a function definition with optional
        #     parameters.
        #
        #     Function syntax: function_name(histogram_facet[, list of buckets])
        #
        #     Data types:
        #
        #     * Histogram facet: facet names with format [a-zA-Z][a-zA-Z0-9_]+.
        #     * String: string like "any string with backslash escape for quote(\")."
        #     * Number: whole number and floating point number like 10, -1 and -0.01.
        #     * List: list of elements with comma(,) separator surrounded by square
        #       brackets. For example, [1, 2, 3] and ["one", "two", "three"].
        #
        #     Built-in constants:
        #
        #     * MIN (minimum number similar to java Double.MIN_VALUE)
        #     * MAX (maximum number similar to java Double.MAX_VALUE)
        #
        #     Built-in functions:
        #
        #     * bucket(start, end[, label])
        #       Bucket build-in function creates a bucket with range of [start, end). Note
        #       that the end is exclusive.
        #       For example, bucket(1, MAX, "positive number") or bucket(1, 10).
        #
        #     Histogram Facets:
        #
        #     * admin1: Admin1 is a global placeholder for referring to state, province,
        #       or the particular term a country uses to define the geographic structure
        #       below the country level. Examples include states codes such as "CA", "IL",
        #       "NY", and provinces, such as "BC".
        #     * locality: Locality is a global placeholder for referring to city, town,
        #       or the particular term a country uses to define the geographic structure
        #       below the admin1 level. Examples include city names such as
        #       "Mountain View" and "New York".
        #     * extended_locality: Extended locality is concatenated version of admin1
        #       and locality with comma separator. For example, "Mountain View, CA" and
        #       "New York, NY".
        #     * postal_code: Postal code of profile which follows locale code.
        #     * country: Country code (ISO-3166-1 alpha-2 code) of profile, such as US,
        #       JP, GB.
        #     * job_title: Normalized job titles specified in EmploymentHistory.
        #     * company_name: Normalized company name of profiles to match on.
        #     * institution: The school name. For example, "MIT",
        #       "University of California, Berkeley"
        #     * degree: Highest education degree in ISCED code. Each value in degree
        #       covers a specific level of education, without any expansion to upper nor
        #       lower levels of education degree.
        #     * experience_in_months: experience in months. 0 means 0 month to 1 month
        #       (exclusive).
        #     * application_date: The application date specifies application start dates.
        #       See
        #       {Google::Cloud::Talent::V4beta1::ApplicationDateFilter ApplicationDateFilter}
        #       for more details.
        #     * application_outcome_notes: The application outcome reason specifies the
        #       reasons behind the outcome of the job application.
        #       See
        #       {Google::Cloud::Talent::V4beta1::ApplicationOutcomeNotesFilter ApplicationOutcomeNotesFilter}
        #       for more details.
        #     * application_job_title: The application job title specifies the job
        #       applied for in the application.
        #       See
        #       {Google::Cloud::Talent::V4beta1::ApplicationJobFilter ApplicationJobFilter}
        #       for more details.
        #     * hirable_status: Hirable status specifies the profile's hirable status.
        #     * string_custom_attribute: String custom attributes. Values can be accessed
        #       via square bracket notation like string_custom_attribute["key1"].
        #     * numeric_custom_attribute: Numeric custom attributes. Values can be
        #       accessed via square bracket notation like numeric_custom_attribute["key1"].
        #
        #     Example expressions:
        #
        #     * count(admin1)
        #     * count(experience_in_months, [bucket(0, 12, "1 year"),
        #       bucket(12, 36, "1-3 years"), bucket(36, MAX, "3+ years")])
        #     * count(string_custom_attribute["assigned_recruiter"])
        #     * count(numeric_custom_attribute["favorite_number"],
        #       [bucket(MIN, 0, "negative"), bucket(0, MAX, "non-negative")])
        class SearchProfilesRequest; end

        # Response of SearchProfiles method.
        # @!attribute [rw] estimated_total_size
        #   @return [Integer]
        #     An estimation of the number of profiles that match the specified query.
        #
        #     This number isn't guaranteed to be accurate.
        # @!attribute [rw] spell_correction
        #   @return [Google::Cloud::Talent::V4beta1::SpellingCorrection]
        #     The spell checking result, and correction.
        # @!attribute [rw] metadata
        #   @return [Google::Cloud::Talent::V4beta1::ResponseMetadata]
        #     Additional information for the API invocation, such as the request
        #     tracking id.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A token to retrieve the next page of results. This is empty if there are no
        #     more results.
        # @!attribute [rw] histogram_query_results
        #   @return [Array<Google::Cloud::Talent::V4beta1::HistogramQueryResult>]
        #     The histogram results that match with specified
        #     {Google::Cloud::Talent::V4beta1::SearchProfilesRequest#histogram_queries SearchProfilesRequest#histogram_queries}.
        # @!attribute [rw] summarized_profiles
        #   @return [Array<Google::Cloud::Talent::V4beta1::SummarizedProfile>]
        #     The profile entities that match the specified
        #     {Google::Cloud::Talent::V4beta1::SearchProfilesRequest SearchProfilesRequest}.
        class SearchProfilesResponse; end

        # Output only.
        #
        # Profile entry with metadata inside
        # {Google::Cloud::Talent::V4beta1::SearchProfilesResponse SearchProfilesResponse}.
        # @!attribute [rw] profiles
        #   @return [Array<Google::Cloud::Talent::V4beta1::Profile>]
        #     A list of profiles that are linked by
        #     {Google::Cloud::Talent::V4beta1::Profile#group_id Profile#group_id}.
        # @!attribute [rw] summary
        #   @return [Google::Cloud::Talent::V4beta1::Profile]
        #     A profile summary shows the profile summary and how the profile matches the
        #     search query.
        #
        #     In profile summary, the profiles with the same
        #     {Google::Cloud::Talent::V4beta1::Profile#group_id Profile#group_id} are merged
        #     together. Among profiles, same education/employment records may be slightly
        #     different but they are merged into one with best efforts.
        #
        #     For example, in one profile the school name is "UC Berkeley" and the field
        #     study is "Computer Science" and in another one the school name is
        #     "University of California at Berkeley" and the field study is "CS". The API
        #     merges these two inputs into one and selects one value for each field. For
        #     example, the school name in summary is set to "University of California at
        #     Berkeley" and the field of study is set to "Computer Science".
        class SummarizedProfile; end
      end
    end
  end
end