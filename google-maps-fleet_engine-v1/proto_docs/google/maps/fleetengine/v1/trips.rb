# frozen_string_literal: true

# Copyright 2024 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Maps
    module FleetEngine
      module V1
        # Trip metadata.
        # @!attribute [r] name
        #   @return [::String]
        #     Output only. In the format "providers/\\{provider}/trips/\\{trip}"
        # @!attribute [rw] vehicle_id
        #   @return [::String]
        #     ID of the vehicle making this trip.
        # @!attribute [rw] trip_status
        #   @return [::Google::Maps::FleetEngine::V1::TripStatus]
        #     Current status of the trip.
        # @!attribute [rw] trip_type
        #   @return [::Google::Maps::FleetEngine::V1::TripType]
        #     The type of the trip.
        # @!attribute [rw] pickup_point
        #   @return [::Google::Maps::FleetEngine::V1::TerminalLocation]
        #     Location where customer indicates they will be picked up.
        # @!attribute [rw] actual_pickup_point
        #   @return [::Google::Maps::FleetEngine::V1::StopLocation]
        #     Input only. The actual location when and where customer was picked up.
        #     This field is for provider to provide feedback on actual pickup
        #     information.
        # @!attribute [rw] actual_pickup_arrival_point
        #   @return [::Google::Maps::FleetEngine::V1::StopLocation]
        #     Input only. The actual time and location of the driver arrival at
        #     the pickup point.
        #     This field is for provider to provide feedback on actual arrival
        #     information at the pickup point.
        # @!attribute [r] pickup_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Either the estimated future time when the rider(s) will be
        #     picked up, or the actual time when they were picked up.
        # @!attribute [rw] intermediate_destinations
        #   @return [::Array<::Google::Maps::FleetEngine::V1::TerminalLocation>]
        #     Intermediate stops in order that the trip requests (in addition
        #     to pickup and dropoff). Initially this will not be supported for shared
        #     trips.
        # @!attribute [rw] intermediate_destinations_version
        #   @return [::Google::Protobuf::Timestamp]
        #     Indicates the last time the `intermediate_destinations` was modified.
        #     Your server should cache this value and pass it in `UpdateTripRequest`
        #     when update `intermediate_destination_index` to ensure the
        #     `intermediate_destinations` is not changed.
        # @!attribute [rw] intermediate_destination_index
        #   @return [::Integer]
        #     When `TripStatus` is `ENROUTE_TO_INTERMEDIATE_DESTINATION`, a number
        #     between [0..N-1] indicating which intermediate destination the vehicle will
        #     cross next. When `TripStatus` is `ARRIVED_AT_INTERMEDIATE_DESTINATION`, a
        #     number between [0..N-1] indicating which intermediate destination the
        #     vehicle is at. The provider sets this value. If there are no
        #     `intermediate_destinations`, this field is ignored.
        # @!attribute [rw] actual_intermediate_destination_arrival_points
        #   @return [::Array<::Google::Maps::FleetEngine::V1::StopLocation>]
        #     Input only. The actual time and location of the driver's arrival at
        #     an intermediate destination.
        #     This field is for provider to provide feedback on actual arrival
        #     information at intermediate destinations.
        # @!attribute [rw] actual_intermediate_destinations
        #   @return [::Array<::Google::Maps::FleetEngine::V1::StopLocation>]
        #     Input only. The actual time and location when and where the customer was
        #     picked up from an intermediate destination. This field is for provider to
        #     provide feedback on actual pickup information at intermediate destinations.
        # @!attribute [rw] dropoff_point
        #   @return [::Google::Maps::FleetEngine::V1::TerminalLocation]
        #     Location where customer indicates they will be dropped off.
        # @!attribute [rw] actual_dropoff_point
        #   @return [::Google::Maps::FleetEngine::V1::StopLocation]
        #     Input only. The actual time and location when and where customer was
        #     dropped off. This field is for provider to provide feedback on actual
        #     dropoff information.
        # @!attribute [r] dropoff_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Either the estimated future time when the rider(s) will be
        #     dropped off at the final destination, or the actual time when they were
        #     dropped off.
        # @!attribute [r] remaining_waypoints
        #   @return [::Array<::Google::Maps::FleetEngine::V1::TripWaypoint>]
        #     Output only. The full path from the current location to the dropoff point,
        #     inclusive. This path could include waypoints from other trips.
        # @!attribute [rw] vehicle_waypoints
        #   @return [::Array<::Google::Maps::FleetEngine::V1::TripWaypoint>]
        #     This field supports manual ordering of the waypoints for the trip. It
        #     contains all of the remaining waypoints for the assigned vehicle, as well
        #     as the pickup and drop-off waypoints for this trip. If the trip hasn't been
        #     assigned to a vehicle, then Fleet Engine ignores this field. For privacy
        #     reasons, this field is only populated by the server on `UpdateTrip` and
        #     `CreateTrip` calls, NOT on `GetTrip` calls.
        # @!attribute [r] route
        #   @return [::Array<::Google::Type::LatLng>]
        #     Output only. Anticipated route for this trip to the first entry in
        #     remaining_waypoints. Note that the first waypoint may belong to a different
        #     trip.
        # @!attribute [r] current_route_segment
        #   @return [::String]
        #     Output only. An encoded path to the next waypoint.
        #
        #     Note: This field is intended only for use by the Driver SDK and Consumer
        #     SDK. Decoding is not yet supported.
        # @!attribute [r] current_route_segment_version
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Indicates the last time the route was modified.
        #
        #     Note: This field is intended only for use by the Driver SDK and Consumer
        #     SDK.
        # @!attribute [r] current_route_segment_traffic
        #   @return [::Google::Maps::FleetEngine::V1::ConsumableTrafficPolyline]
        #     Output only. Indicates the traffic conditions along the
        #     `current_route_segment` when they're available.
        #
        #     Note: This field is intended only for use by the Driver SDK and Consumer
        #     SDK.
        # @!attribute [r] current_route_segment_traffic_version
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Indicates the last time the `current_route_segment_traffic`
        #     was modified.
        #
        #     Note: This field is intended only for use by the Driver SDK and Consumer
        #     SDK.
        # @!attribute [r] current_route_segment_end_point
        #   @return [::Google::Maps::FleetEngine::V1::TripWaypoint]
        #     Output only. The waypoint where `current_route_segment` ends.
        # @!attribute [r] remaining_distance_meters
        #   @return [::Google::Protobuf::Int32Value]
        #     Output only. The remaining driving distance in the `current_route_segment`
        #     field. The value is unspecified if the trip is not assigned to a vehicle,
        #     or the trip is completed or cancelled.
        # @!attribute [r] eta_to_first_waypoint
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The ETA to the next waypoint (the first entry in the
        #     `remaining_waypoints` field). The value is unspecified if the trip is not
        #     assigned to a vehicle, or the trip is inactive (completed or cancelled).
        # @!attribute [r] remaining_time_to_first_waypoint
        #   @return [::Google::Protobuf::Duration]
        #     Output only. The duration from when the Trip data is returned to the time
        #     in `Trip.eta_to_first_waypoint`. The value is unspecified if the trip is
        #     not assigned to a vehicle, or the trip is inactive (completed or
        #     cancelled).
        # @!attribute [r] remaining_waypoints_version
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Indicates the last time that `remaining_waypoints` was changed
        #     (a waypoint was added, removed, or changed).
        # @!attribute [r] remaining_waypoints_route_version
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Indicates the last time the
        #     `remaining_waypoints.path_to_waypoint` and
        #     `remaining_waypoints.traffic_to_waypoint` were modified. Your client app
        #     should cache this value and pass it in `GetTripRequest` to ensure the
        #     paths and traffic for `remaining_waypoints` are only returned if updated.
        # @!attribute [rw] number_of_passengers
        #   @return [::Integer]
        #     Immutable. Indicates the number of passengers on this trip and does not
        #     include the driver. A vehicle must have available capacity to be returned
        #     in a `SearchVehicles` response.
        # @!attribute [r] last_location
        #   @return [::Google::Maps::FleetEngine::V1::VehicleLocation]
        #     Output only. Indicates the last reported location of the vehicle along the
        #     route.
        # @!attribute [r] last_location_snappable
        #   @return [::Boolean]
        #     Output only. Indicates whether the vehicle's `last_location` can be snapped
        #     to the current_route_segment. False if `last_location` or
        #     `current_route_segment` doesn't exist.
        #     It is computed by Fleet Engine. Any update from clients will be ignored.
        # @!attribute [rw] view
        #   @return [::Google::Maps::FleetEngine::V1::TripView]
        #     The subset of Trip fields that are populated and how they should be
        #     interpreted.
        # @!attribute [rw] attributes
        #   @return [::Array<::Google::Maps::FleetEngine::V1::TripAttribute>]
        #     A list of custom Trip attributes. Each attribute must have a unique key.
        class Trip
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The actual location where a stop (pickup/dropoff) happened.
        # @!attribute [rw] point
        #   @return [::Google::Type::LatLng]
        #     Required. Denotes the actual location.
        # @!attribute [rw] timestamp
        #   @return [::Google::Protobuf::Timestamp]
        #     Indicates when the stop happened.
        # @!attribute [rw] stop_time
        #   @deprecated This field is deprecated and may be removed in the next major version update.
        #   @return [::Google::Protobuf::Timestamp]
        #     Input only. Deprecated.  Use the timestamp field.
        class StopLocation
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The status of a trip indicating its progression.
        module TripStatus
          # Default, used for unspecified or unrecognized trip status.
          UNKNOWN_TRIP_STATUS = 0

          # Newly created trip.
          NEW = 1

          # The driver is on their way to the pickup point.
          ENROUTE_TO_PICKUP = 2

          # The driver has arrived at the pickup point.
          ARRIVED_AT_PICKUP = 3

          # The driver has arrived at an intermediate destination and is waiting for
          # the rider.
          ARRIVED_AT_INTERMEDIATE_DESTINATION = 7

          # The driver is on their way to an intermediate destination
          # (not the dropoff point).
          ENROUTE_TO_INTERMEDIATE_DESTINATION = 8

          # The driver has picked up the rider and is on their way to the
          # next destination.
          ENROUTE_TO_DROPOFF = 4

          # The rider has been dropped off and the trip is complete.
          COMPLETE = 5

          # The trip was canceled prior to pickup by the driver, rider, or
          # rideshare provider.
          CANCELED = 6
        end

        # A set of values that indicate upon which platform the request was issued.
        module BillingPlatformIdentifier
          # Default. Used for unspecified platforms.
          BILLING_PLATFORM_IDENTIFIER_UNSPECIFIED = 0

          # The platform is a client server.
          SERVER = 1

          # The platform is a web browser.
          WEB = 2

          # The platform is an Android mobile device.
          ANDROID = 3

          # The platform is an IOS mobile device.
          IOS = 4

          # Other platforms that are not listed in this enumeration.
          OTHERS = 5
        end

        # Selector for different sets of Trip fields in a `GetTrip` response.  See
        # [AIP-157](https://google.aip.dev/157) for context. Additional views are
        # likely to be added.
        module TripView
          # The default value. For backwards-compatibility, the API will default to an
          # SDK view. To ensure stability and support, customers are
          # advised to select a `TripView` other than `SDK`.
          TRIP_VIEW_UNSPECIFIED = 0

          # Includes fields that may not be interpretable or supportable using
          # publicly available libraries.
          SDK = 1

          # Trip fields are populated for the Journey Sharing use case. This view is
          # intended for server-to-server communications.
          JOURNEY_SHARING_V1S = 2
        end
      end
    end
  end
end
