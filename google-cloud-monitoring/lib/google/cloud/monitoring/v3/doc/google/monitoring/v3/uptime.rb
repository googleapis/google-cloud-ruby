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

module Google
  module Monitoring
    module V3
      # Nimbus InternalCheckers.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The GCP project ID. Not necessarily the same as the project_id for the
      #     config.
      # @!attribute [rw] network
      #   @return [String]
      #     The internal network to perform this uptime check on.
      # @!attribute [rw] gcp_zone
      #   @return [String]
      #     The GCP zone the uptime check should egress from. Only respected for
      #     internal uptime checks, where internal_network is specified.
      # @!attribute [rw] checker_id
      #   @return [String]
      #     The checker ID.
      # @!attribute [rw] display_name
      #   @return [String]
      #     The checker's human-readable name.
      class InternalChecker; end

      # This message configures which resources and services to monitor for
      # availability.
      # @!attribute [rw] name
      #   @return [String]
      #     A unique resource name for this UptimeCheckConfig. The format is:
      #
      #
      #       +projects/[PROJECT_ID]/uptimeCheckConfigs/[UPTIME_CHECK_ID]+.
      #
      #     This field should be omitted when creating the uptime check configuration;
      #     on create, the resource name is assigned by the server and included in the
      #     response.
      # @!attribute [rw] display_name
      #   @return [String]
      #     A human-friendly name for the uptime check configuration. The display name
      #     should be unique within a Stackdriver Account in order to make it easier
      #     to identify; however, uniqueness is not enforced. Required.
      # @!attribute [rw] monitored_resource
      #   @return [Google::Api::MonitoredResource]
      #     The [monitored
      #     resource](https://cloud.google.com/monitoring/api/resources) associated
      #     with the configuration.
      #     The following monitored resource types are supported for uptime checks:
      #       uptime_url
      #       gce_instance
      #       gae_app
      #       aws_ec2_instance
      #       aws_elb_load_balancer
      # @!attribute [rw] resource_group
      #   @return [Google::Monitoring::V3::UptimeCheckConfig::ResourceGroup]
      #     The group resource associated with the configuration.
      # @!attribute [rw] http_check
      #   @return [Google::Monitoring::V3::UptimeCheckConfig::HttpCheck]
      #     Contains information needed to make an HTTP or HTTPS check.
      # @!attribute [rw] tcp_check
      #   @return [Google::Monitoring::V3::UptimeCheckConfig::TcpCheck]
      #     Contains information needed to make a TCP check.
      # @!attribute [rw] period
      #   @return [Google::Protobuf::Duration]
      #     How often, in seconds, the uptime check is performed.
      #     Currently, the only supported values are +60s+ (1 minute), +300s+
      #     (5 minutes), +600s+ (10 minutes), and +900s+ (15 minutes). Optional,
      #     defaults to +300s+.
      # @!attribute [rw] timeout
      #   @return [Google::Protobuf::Duration]
      #     The maximum amount of time to wait for the request to complete (must be
      #     between 1 and 60 seconds). Required.
      # @!attribute [rw] content_matchers
      #   @return [Array<Google::Monitoring::V3::UptimeCheckConfig::ContentMatcher>]
      #     The expected content on the page the check is run against.
      #     Currently, only the first entry in the list is supported, and other entries
      #     will be ignored. The server will look for an exact match of the string in
      #     the page response's content. This field is optional and should only be
      #     specified if a content match is required.
      # @!attribute [rw] selected_regions
      #   @return [Array<Google::Monitoring::V3::UptimeCheckRegion>]
      #     The list of regions from which the check will be run.
      #     If this field is specified, enough regions to include a minimum of
      #     3 locations must be provided, or an error message is returned.
      #     Not specifying this field will result in uptime checks running from all
      #     regions.
      # @!attribute [rw] is_internal
      #   @return [true, false]
      #     Denotes whether this is a check that egresses from InternalCheckers.
      # @!attribute [rw] internal_checkers
      #   @return [Array<Google::Monitoring::V3::InternalChecker>]
      #     The internal checkers that this check will egress from. If +is_internal+ is
      #     true and this list is empty, the check will egress from all
      #     InternalCheckers configured for the project that owns this CheckConfig.
      class UptimeCheckConfig
        # The resource submessage for group checks. It can be used instead of a
        # monitored resource, when multiple resources are being monitored.
        # @!attribute [rw] group_id
        #   @return [String]
        #     The group of resources being monitored. Should be only the
        #     group_id, not projects/<project_id>/groups/<group_id>.
        # @!attribute [rw] resource_type
        #   @return [Google::Monitoring::V3::GroupResourceType]
        #     The resource type of the group members.
        class ResourceGroup; end

        # Information involved in an HTTP/HTTPS uptime check request.
        # @!attribute [rw] use_ssl
        #   @return [true, false]
        #     If true, use HTTPS instead of HTTP to run the check.
        # @!attribute [rw] path
        #   @return [String]
        #     The path to the page to run the check against. Will be combined with the
        #     host (specified within the MonitoredResource) and port to construct the
        #     full URL. Optional (defaults to "/").
        # @!attribute [rw] port
        #   @return [Integer]
        #     The port to the page to run the check against. Will be combined with host
        #     (specified within the MonitoredResource) and path to construct the full
        #     URL. Optional (defaults to 80 without SSL, or 443 with SSL).
        # @!attribute [rw] auth_info
        #   @return [Google::Monitoring::V3::UptimeCheckConfig::HttpCheck::BasicAuthentication]
        #     The authentication information. Optional when creating an HTTP check;
        #     defaults to empty.
        # @!attribute [rw] mask_headers
        #   @return [true, false]
        #     Boolean specifiying whether to encrypt the header information.
        #     Encryption should be specified for any headers related to authentication
        #     that you do not wish to be seen when retrieving the configuration. The
        #     server will be responsible for encrypting the headers.
        #     On Get/List calls, if mask_headers is set to True then the headers
        #     will be obscured with ******.
        # @!attribute [rw] headers
        #   @return [Hash{String => String}]
        #     The list of headers to send as part of the uptime check request.
        #     If two headers have the same key and different values, they should
        #     be entered as a single header, with the value being a comma-separated
        #     list of all the desired values as described at
        #     https://www.w3.org/Protocols/rfc2616/rfc2616.txt (page 31).
        #     Entering two separate headers with the same key in a Create call will
        #     cause the first to be overwritten by the second.
        #     The maximum number of headers allowed is 100.
        class HttpCheck
          # A type of authentication to perform against the specified resource or URL
          # that uses username and password.
          # Currently, only Basic authentication is supported in Uptime Monitoring.
          # @!attribute [rw] username
          #   @return [String]
          #     The username to authenticate.
          # @!attribute [rw] password
          #   @return [String]
          #     The password to authenticate.
          class BasicAuthentication; end
        end

        # Information required for a TCP uptime check request.
        # @!attribute [rw] port
        #   @return [Integer]
        #     The port to the page to run the check against. Will be combined with host
        #     (specified within the MonitoredResource) to construct the full URL.
        #     Required.
        class TcpCheck; end

        # Used to perform string matching. Currently, this matches on the exact
        # content. In the future, it can be expanded to allow for regular expressions
        # and more complex matching.
        # @!attribute [rw] content
        #   @return [String]
        #     String content to match (max 1024 bytes)
        class ContentMatcher; end
      end

      # Contains the region, location, and list of IP
      # addresses where checkers in the location run from.
      # @!attribute [rw] region
      #   @return [Google::Monitoring::V3::UptimeCheckRegion]
      #     A broad region category in which the IP address is located.
      # @!attribute [rw] location
      #   @return [String]
      #     A more specific location within the region that typically encodes
      #     a particular city/town/metro (and its containing state/province or country)
      #     within the broader umbrella region category.
      # @!attribute [rw] ip_address
      #   @return [String]
      #     The IP address from which the uptime check originates. This is a full
      #     IP address (not an IP address range). Most IP addresses, as of this
      #     publication, are in IPv4 format; however, one should not rely on the
      #     IP addresses being in IPv4 format indefinitely and should support
      #     interpreting this field in either IPv4 or IPv6 format.
      class UptimeCheckIp; end

      # The regions from which an uptime check can be run.
      module UptimeCheckRegion
        # Default value if no region is specified. Will result in uptime checks
        # running from all regions.
        REGION_UNSPECIFIED = 0

        # Allows checks to run from locations within the United States of America.
        USA = 1

        # Allows checks to run from locations within the continent of Europe.
        EUROPE = 2

        # Allows checks to run from locations within the continent of South
        # America.
        SOUTH_AMERICA = 3

        # Allows checks to run from locations within the Asia Pacific area (ex:
        # Singapore).
        ASIA_PACIFIC = 4
      end

      # The supported resource types that can be used as values of
      # +group_resource.resource_type+.
      # +INSTANCE+ includes +gce_instance+ and +aws_ec2_instance+ resource types.
      # The resource types +gae_app+ and +uptime_url+ are not valid here because
      # group checks on App Engine modules and URLs are not allowed.
      module GroupResourceType
        # Default value (not valid).
        RESOURCE_TYPE_UNSPECIFIED = 0

        # A group of instances from Google Cloud Platform (GCP) or
        # Amazon Web Services (AWS).
        INSTANCE = 1

        # A group of Amazon ELB load balancers.
        AWS_ELB_LOAD_BALANCER = 2
      end
    end
  end
end