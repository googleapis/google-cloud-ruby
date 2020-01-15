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


module Google
  module Cloud
    module Irm
      module V1alpha2
        # Request for the CreateIncident method.
        # @!attribute [rw] incident
        #   @return [Google::Cloud::Irm::V1alpha2::Incident]
        #     The incident to create.
        # @!attribute [rw] parent
        #   @return [String]
        #     The resource name of the hosting Stackdriver project which the incident
        #     belongs to.
        #     The name is of the form `projects/{project_id_or_number}`
        #     .
        class CreateIncidentRequest; end

        # Request for the GetIncident method.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        class GetIncidentRequest; end

        # Request for the UpdateIncident method.
        # @!attribute [rw] incident
        #   @return [Google::Cloud::Irm::V1alpha2::Incident]
        #     The incident to update with the new values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     List of fields that should be updated.
        class UpdateIncidentRequest; end

        # Request for the SearchSimilarIncidents method.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the incident or signal, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Number of similar incidents to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in 'next_page_token'.
        class SearchSimilarIncidentsRequest; end

        # Response for the SearchSimilarIncidents method.
        # @!attribute [rw] results
        #   @return [Array<Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsResponse::Result>]
        #     The search results, ordered by descending relevance.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of similar incidents.
        class SearchSimilarIncidentsResponse
          # A single search result, i.e. an incident with (potentially) additional
          # information.
          # @!attribute [rw] incident
          #   @return [Google::Cloud::Irm::V1alpha2::Incident]
          #     An incident that is "similar" to the incident or signal specified in the
          #     request.
          class Result; end
        end

        # Request for the CreateAnnotation method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] annotation
        #   @return [Google::Cloud::Irm::V1alpha2::Annotation]
        #     Only annotation.content is an input argument.
        class CreateAnnotationRequest; end

        # Request for the ListAnnotations method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Number of annotations to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in `next_page_token`.
        class ListAnnotationsRequest; end

        # Response for the ListAnnotations method.
        # @!attribute [rw] annotations
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Annotation>]
        #     List of annotations.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of annotations.
        class ListAnnotationsResponse; end

        # Request for the CreateTag method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] tag
        #   @return [Google::Cloud::Irm::V1alpha2::Tag]
        #     Tag to create. Only tag.display_name is an input argument.
        class CreateTagRequest; end

        # Request for the DeleteTag method.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the tag.
        class DeleteTagRequest; end

        # Request for the ListTagsForIncident method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Number of tags to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in `next_page_token`.
        class ListTagsRequest; end

        # Response for the ListTagsForIncident method.
        # @!attribute [rw] tags
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Tag>]
        #     Tags.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of tags.
        class ListTagsResponse; end

        # Request for the CreateSignal method.
        # @!attribute [rw] parent
        #   @return [String]
        #     The resource name of the hosting Stackdriver project which requested
        #     signal belongs to.
        # @!attribute [rw] signal
        #   @return [Google::Cloud::Irm::V1alpha2::Signal]
        #     The signal to create.
        class CreateSignalRequest; end

        # Request for the SearchSignals method.
        # @!attribute [rw] parent
        #   @return [String]
        #     The resource name of the hosting Stackdriver project which requested
        #     incidents belong to.
        # @!attribute [rw] query
        #   @return [String]
        #     An expression that defines which signals to return.
        #
        #     Search atoms can be used to match certain specific fields.  Otherwise,
        #     plain text will match text fields in the signal.
        #
        #     Search atoms:
        #
        #     * `start` - (timestamp) The time the signal was created.
        #     * `title` - The title of the signal.
        #     * `signal_state` - `open` or `closed`. State of the signal.
        #       (e.g., `signal_state:open`)
        #
        #     Timestamp formats:
        #
        #     * yyyy-MM-dd - an absolute date, treated as a calendar-day-wide window.
        #       In other words, the "<" operator will match dates before that date, the
        #       ">" operator will match dates after that date, and the ":" operator will
        #       match the entire day.
        #     * yyyy-MM-ddTHH:mm - Same as above, but with minute resolution.
        #     * yyyy-MM-ddTHH:mm:ss - Same as above, but with second resolution.
        #     * Nd (e.g. 7d) - a relative number of days ago, treated as a moment in time
        #       (as opposed to a day-wide span) a multiple of 24 hours ago (as opposed to
        #       calendar days).  In the case of daylight savings time, it will apply the
        #       current timezone to both ends of the range.  Note that exact matching
        #       (e.g. `start:7d`) is unlikely to be useful because that would only match
        #       signals created precisely at a particular instant in time.
        #
        #     The absolute timestamp formats (everything starting with a year) can
        #     optionally be followed with a UTC offset in +/-hh:mm format.  Also, the 'T'
        #     separating dates and times can optionally be replaced with a space. Note
        #     that any timestamp containing a space or colon will need to be quoted.
        #
        #     Examples:
        #
        #     * `foo` - matches signals containing the word "foo"
        #     * `"foo bar"` - matches signals containing the phrase "foo bar"
        #     * `foo bar` or `foo AND bar` - matches signals containing the words
        #       "foo" and "bar"
        #     * `foo -bar` or `foo AND NOT bar` - matches signals containing the
        #       word
        #       "foo" but not the word "bar"
        #     * `foo OR bar` - matches signals containing the word "foo" or the
        #       word "bar"
        #     * `start>2018-11-28` - matches signals which started after November
        #       11, 2018.
        #     * `start<=2018-11-28` - matches signals which started on or before
        #       November 11, 2018.
        #     * `start:2018-11-28` - matches signals which started on November 11,
        #       2018.
        #     * `start>"2018-11-28 01:02:03+04:00"` - matches signals which started
        #       after November 11, 2018 at 1:02:03 AM according to the UTC+04 time
        #       zone.
        #     * `start>7d` - matches signals which started after the point in time
        #       7*24 hours ago
        #     * `start>180d` - similar to 7d, but likely to cross the daylight savings
        #       time boundary, so the end time will be 1 hour different from "now."
        #     * `foo AND start>90d AND stage<resolved` - unresolved signals from
        #       the past 90 days containing the word "foo"
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Maximum number of `signals` to return in the response.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in `next_page_token`. All
        #     field values except for page_size and page_token should be the same as the
        #     original query (may return an error or unexpected data otherwise).
        class SearchSignalsRequest; end

        # Response for the SearchSignals method.
        # @!attribute [rw] signals
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Signal>]
        #     Signals that matched the query in the request.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of signals.
        class SearchSignalsResponse; end

        # Request for the GetSignal method.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the Signal resource, for example,
        #     "projects/{project_id}/signals/{signal_id}".
        class GetSignalRequest; end

        # Request for the LookupSignal method.
        # @!attribute [rw] cscc_finding
        #   @return [String]
        #     Full resource name of the CSCC finding id this signal refers to (e.g.
        #     "organizations/abc/sources/123/findings/xyz")
        # @!attribute [rw] stackdriver_notification_id
        #   @return [String]
        #     The ID from the Stackdriver Alerting notification.
        class LookupSignalRequest; end

        # Request for the UpdateSignal method.
        # @!attribute [rw] signal
        #   @return [Google::Cloud::Irm::V1alpha2::Signal]
        #     The signal to update with the new values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     List of fields that should be updated.
        class UpdateSignalRequest; end

        # Request for the SearchIncidents method.
        # @!attribute [rw] parent
        #   @return [String]
        #     The resource name of the hosting Stackdriver project which requested
        #     incidents belong to.
        # @!attribute [rw] query
        #   @return [String]
        #     An expression that defines which incidents to return.
        #
        #     Search atoms can be used to match certain specific fields.  Otherwise,
        #     plain text will match text fields in the incident.
        #
        #     Search atoms:
        #     * `start` - (timestamp) The time the incident started.
        #     * `stage` - The stage of the incident, one of detected, triaged, mitigated,
        #       resolved, documented, or duplicate (which correspond to values in the
        #       Incident.Stage enum). These are ordered, so `stage<resolved` is
        #       equivalent to `stage:detected OR stage:triaged OR stage:mitigated`.
        #     * `severity` - (Incident.Severity) The severity of the incident.
        #       * Supports matching on a specific severity (for example,
        #         `severity:major`) or on a range (for example, `severity>medium`,
        #         `severity<=minor`, etc.).
        #
        #       Timestamp formats:
        #     * yyyy-MM-dd - an absolute date, treated as a calendar-day-wide window.
        #       In other words, the "<" operator will match dates before that date, the
        #       ">" operator will match dates after that date, and the ":" or "="
        #       operators will match the entire day.
        #     * Nd (for example, 7d) - a relative number of days ago, treated as a moment
        #       in time (as opposed to a day-wide span). A multiple of 24 hours ago (as
        #       opposed to calendar days).  In the case of daylight savings time, it will
        #       apply the current timezone to both ends of the range.  Note that exact
        #       matching (for example, `start:7d`) is unlikely to be useful because that
        #       would only match incidents created precisely at a particular instant in
        #       time.
        #
        #     Examples:
        #
        #     * `foo` - matches incidents containing the word "foo"
        #     * `"foo bar"` - matches incidents containing the phrase "foo bar"
        #     * `foo bar` or `foo AND bar` - matches incidents containing the words "foo"
        #       and "bar"
        #     * `foo -bar` or `foo AND NOT bar` - matches incidents containing the word
        #       "foo" but not the word "bar"
        #     * `foo OR bar` - matches incidents containing the word "foo" or the word
        #       "bar"
        #     * `start>2018-11-28` - matches incidents which started after November 11,
        #       2018.
        #     * `start<=2018-11-28` - matches incidents which started on or before
        #       November 11, 2018.
        #     * `start:2018-11-28` - matches incidents which started on November 11,
        #       2018.
        #     * `start>7d` - matches incidents which started after the point in time 7*24
        #       hours ago
        #     * `start>180d` - similar to 7d, but likely to cross the daylight savings
        #       time boundary, so the end time will be 1 hour different from "now."
        #     * `foo AND start>90d AND stage<resolved` - unresolved incidents from the
        #       past 90 days containing the word "foo"
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Number of incidents to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in `next_page_token`.
        # @!attribute [rw] time_zone
        #   @return [String]
        #     The time zone name. It should be an IANA TZ name, such as
        #     "America/Los_Angeles". For more information,
        #     see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones.
        #     If no time zone is specified, the default is UTC.
        class SearchIncidentsRequest; end

        # Response for the SearchIncidents method.
        # @!attribute [rw] incidents
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Incident>]
        #     Incidents.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of incidents.
        class SearchIncidentsResponse; end

        # Request to escalate an incident.
        # @!attribute [rw] incident
        #   @return [Google::Cloud::Irm::V1alpha2::Incident]
        #     The incident to escalate with the new values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     List of fields that should be updated.
        # @!attribute [rw] subscriptions
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Subscription>]
        #     Subscriptions to add or update. Existing subscriptions with the same
        #     channel and address as a subscription in the list will be updated.
        # @!attribute [rw] tags
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Tag>]
        #     Tags to add. Tags identical to existing tags will be ignored.
        # @!attribute [rw] roles
        #   @return [Array<Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment>]
        #     Roles to add or update. Existing roles with the same type (and title, for
        #     TYPE_OTHER roles) will be updated.
        # @!attribute [rw] artifacts
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Artifact>]
        #     Artifacts to add. All artifacts are added without checking for duplicates.
        class EscalateIncidentRequest; end

        # Response for EscalateIncident.
        # @!attribute [rw] incident
        #   @return [Google::Cloud::Irm::V1alpha2::Incident]
        #     The escalated incident.
        # @!attribute [rw] subscriptions
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Subscription>]
        #     New or modified subscriptions.
        # @!attribute [rw] tags
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Tag>]
        #     New or modified tags.
        # @!attribute [rw] roles
        #   @return [Array<Google::Cloud::Irm::V1alpha2::IncidentRole>]
        #     New or modified roles.
        # @!attribute [rw] artifacts
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Artifact>]
        #     New or modified artifacts.
        class EscalateIncidentResponse; end

        # Request for the CreateArtifact method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] artifact
        #   @return [Google::Cloud::Irm::V1alpha2::Artifact]
        #     The artifact to create.
        class CreateArtifactRequest; end

        # Request for the ListArtifacts method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Number of artifacts to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in `next_page_token`.
        class ListArtifactsRequest; end

        # Response for the ListArtifacts method.
        # @!attribute [rw] artifacts
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Artifact>]
        #     List of artifacts.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of artifacts.
        class ListArtifactsResponse; end

        # Request for the UpdateArtifact method.
        # @!attribute [rw] artifact
        #   @return [Google::Cloud::Irm::V1alpha2::Artifact]
        #     The artifact to update with the new values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     List of fields that should be updated.
        class UpdateArtifactRequest; end

        # Request for deleting an artifact.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the artifact.
        class DeleteArtifactRequest; end

        # SendShiftHandoff and PreviewShiftHandoff RPC request.
        # @!attribute [rw] parent
        #   @return [String]
        #     The resource name of the Stackdriver project that the handoff is being sent
        #     from. for example, `projects/{project_id}`
        # @!attribute [rw] recipients
        #   @return [Array<String>]
        #     Email addresses of the recipients of the handoff, for example,
        #     "user@example.com". Must contain at least one entry.
        # @!attribute [rw] cc
        #   @return [Array<String>]
        #     Email addresses that should be CC'd on the handoff. Optional.
        # @!attribute [rw] subject
        #   @return [String]
        #     The subject of the email. Required.
        # @!attribute [rw] notes_content_type
        #   @return [String]
        #     Content type string, for example, 'text/plain' or 'text/html'.
        # @!attribute [rw] notes_content
        #   @return [String]
        #     Additional notes to be included in the handoff. Optional.
        # @!attribute [rw] incidents
        #   @return [Array<Google::Cloud::Irm::V1alpha2::SendShiftHandoffRequest::Incident>]
        #     The set of incidents that should be included in the handoff. Optional.
        # @!attribute [rw] preview_only
        #   @return [true, false]
        #     If set to true a ShiftHandoffResponse will be returned but the handoff
        #     will not actually be sent.
        class SendShiftHandoffRequest
          # Describes an incident for inclusion in the handoff.
          # This is wrapped in a message to provide flexibility for potentially
          # attaching additional data to each incident in the future.
          # @!attribute [rw] name
          #   @return [String]
          #     Resource name of the incident, for example,
          #     "projects/{project_id}/incidents/{incident_id}".
          class Incident; end
        end

        # SendShiftHandoff and PreviewShiftHandoff RPC response.
        # @!attribute [rw] content_type
        #   @return [String]
        #     Content type string, for example, 'text/plain' or 'text/html'.
        # @!attribute [rw] content
        #   @return [String]
        #     The contents of the handoff that was sent or would have been sent (if the
        #     request was preview_only).
        #     This will typically contain a full HTML document.
        class SendShiftHandoffResponse; end

        # Request for the CreateSubscription method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] subscription
        #   @return [Google::Cloud::Irm::V1alpha2::Subscription]
        #     The subscription to create.
        class CreateSubscriptionRequest; end

        # Request for the UpdateSubscription method.
        # @!attribute [rw] subscription
        #   @return [Google::Cloud::Irm::V1alpha2::Subscription]
        #     The subscription to update, with new values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     List of fields that should be updated.
        class UpdateSubscriptionRequest; end

        # Request for the ListSubscriptions method.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Number of subscriptions to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in `next_page_token`.
        class ListSubscriptionsRequest; end

        # Response for the ListSubscriptions method.
        # @!attribute [rw] subscriptions
        #   @return [Array<Google::Cloud::Irm::V1alpha2::Subscription>]
        #     List of subscriptions.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of subscriptions.
        class ListSubscriptionsResponse; end

        # Request for deleting a subscription.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the subscription.
        class DeleteSubscriptionRequest; end

        # Request for creating a role assignment.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] incident_role_assignment
        #   @return [Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment]
        #     Role assignment to create.
        class CreateIncidentRoleAssignmentRequest; end

        # Request for deleting a role assignment.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the role assignment.
        class DeleteIncidentRoleAssignmentRequest; end

        # Request to list role assignments of an incident.
        # @!attribute [rw] parent
        #   @return [String]
        #     Resource name of the incident, for example,
        #     "projects/{project_id}/incidents/{incident_id}".
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Number of assignments to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Page token from an earlier query, as returned in `next_page_token`.
        class ListIncidentRoleAssignmentsRequest; end

        # Response for the ListIncidentRoleAssignments method.
        # @!attribute [rw] incident_role_assignments
        #   @return [Array<Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment>]
        #     List of assignments.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Page token to fetch the next set of assignments.
        class ListIncidentRoleAssignmentsResponse; end

        # Request to start a role handover.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the role assignment.
        # @!attribute [rw] new_assignee
        #   @return [Google::Cloud::Irm::V1alpha2::User]
        #     The proposed assignee.
        class RequestIncidentRoleHandoverRequest; end

        # Request to confirm a role handover.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the role assignment.
        # @!attribute [rw] new_assignee
        #   @return [Google::Cloud::Irm::V1alpha2::User]
        #     The proposed assignee, who will now be the assignee. This should be the
        #     current user; otherwise ForceRoleHandover should be called.
        class ConfirmIncidentRoleHandoverRequest; end

        # Request to force a role handover.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the role assignment.
        # @!attribute [rw] new_assignee
        #   @return [Google::Cloud::Irm::V1alpha2::User]
        #     The proposed assignee, who will now be the assignee. This should not be
        #     the current user; otherwise ConfirmRoleHandover should be called.
        class ForceIncidentRoleHandoverRequest; end

        # Request to cancel a role handover.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the role assignment.
        # @!attribute [rw] new_assignee
        #   @return [Google::Cloud::Irm::V1alpha2::User]
        #     Person who was proposed as the next assignee (i.e.
        #     IncidentRoleAssignment.proposed_assignee) and whose proposal is being
        #     cancelled.
        class CancelIncidentRoleHandoverRequest; end
      end
    end
  end
end