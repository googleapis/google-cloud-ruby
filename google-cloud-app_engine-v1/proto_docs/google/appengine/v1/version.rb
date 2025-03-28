# frozen_string_literal: true

# Copyright 2021 Google LLC
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
  module Cloud
    module AppEngine
      module V1
        # A Version resource is a specific set of source code and configuration files
        # that are deployed into a service.
        # @!attribute [rw] name
        #   @return [::String]
        #     Full path to the Version resource in the API.  Example:
        #     `apps/myapp/services/default/versions/v1`.
        # @!attribute [rw] id
        #   @return [::String]
        #     Relative name of the version within the service.  Example: `v1`.
        #     Version names can contain only lowercase letters, numbers, or hyphens.
        #     Reserved names: "default", "latest", and any name with the prefix "ah-".
        # @!attribute [rw] automatic_scaling
        #   @return [::Google::Cloud::AppEngine::V1::AutomaticScaling]
        #     Automatic scaling is based on request rate, response latencies, and other
        #     application metrics. Instances are dynamically created and destroyed as
        #     needed in order to handle traffic.
        #
        #     Note: The following fields are mutually exclusive: `automatic_scaling`, `basic_scaling`, `manual_scaling`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] basic_scaling
        #   @return [::Google::Cloud::AppEngine::V1::BasicScaling]
        #     A service with basic scaling will create an instance when the application
        #     receives a request. The instance will be turned down when the app becomes
        #     idle. Basic scaling is ideal for work that is intermittent or driven by
        #     user activity.
        #
        #     Note: The following fields are mutually exclusive: `basic_scaling`, `automatic_scaling`, `manual_scaling`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] manual_scaling
        #   @return [::Google::Cloud::AppEngine::V1::ManualScaling]
        #     A service with manual scaling runs continuously, allowing you to perform
        #     complex initialization and rely on the state of its memory over time.
        #     Manually scaled versions are sometimes referred to as "backends".
        #
        #     Note: The following fields are mutually exclusive: `manual_scaling`, `automatic_scaling`, `basic_scaling`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] inbound_services
        #   @return [::Array<::Google::Cloud::AppEngine::V1::InboundServiceType>]
        #     Before an application can receive email or XMPP messages, the application
        #     must be configured to enable the service.
        # @!attribute [rw] instance_class
        #   @return [::String]
        #     Instance class that is used to run this version. Valid values are:
        #
        #     * AutomaticScaling: `F1`, `F2`, `F4`, `F4_1G`
        #     * ManualScaling or BasicScaling: `B1`, `B2`, `B4`, `B8`, `B4_1G`
        #
        #     Defaults to `F1` for AutomaticScaling and `B1` for ManualScaling or
        #     BasicScaling.
        # @!attribute [rw] network
        #   @return [::Google::Cloud::AppEngine::V1::Network]
        #     Extra network settings.
        #     Only applicable in the App Engine flexible environment.
        # @!attribute [rw] zones
        #   @return [::Array<::String>]
        #     The Google Compute Engine zones that are supported by this version in the
        #     App Engine flexible environment. Deprecated.
        # @!attribute [rw] resources
        #   @return [::Google::Cloud::AppEngine::V1::Resources]
        #     Machine resources for this version.
        #     Only applicable in the App Engine flexible environment.
        # @!attribute [rw] runtime
        #   @return [::String]
        #     Desired runtime. Example: `python27`.
        # @!attribute [rw] runtime_channel
        #   @return [::String]
        #     The channel of the runtime to use. Only available for some
        #     runtimes. Defaults to the `default` channel.
        # @!attribute [rw] threadsafe
        #   @return [::Boolean]
        #     Whether multiple requests can be dispatched to this version at once.
        # @!attribute [rw] vm
        #   @return [::Boolean]
        #     Whether to deploy this version in a container on a virtual machine.
        # @!attribute [rw] app_engine_apis
        #   @return [::Boolean]
        #     Allows App Engine second generation runtimes to access the legacy bundled
        #     services.
        # @!attribute [rw] beta_settings
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Metadata settings that are supplied to this version to enable
        #     beta runtime features.
        # @!attribute [rw] env
        #   @return [::String]
        #     App Engine execution environment for this version.
        #
        #     Defaults to `standard`.
        # @!attribute [rw] serving_status
        #   @return [::Google::Cloud::AppEngine::V1::ServingStatus]
        #     Current serving status of this version. Only the versions with a
        #     `SERVING` status create instances and can be billed.
        #
        #     `SERVING_STATUS_UNSPECIFIED` is an invalid value. Defaults to `SERVING`.
        # @!attribute [rw] created_by
        #   @return [::String]
        #     Email address of the user who created this version.
        # @!attribute [rw] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Time that this version was created.
        # @!attribute [rw] disk_usage_bytes
        #   @return [::Integer]
        #     Total size in bytes of all the files that are included in this version
        #     and currently hosted on the App Engine disk.
        # @!attribute [rw] runtime_api_version
        #   @return [::String]
        #     The version of the API in the given runtime environment. Please see the
        #     app.yaml reference for valid values at
        #     https://cloud.google.com/appengine/docs/standard/<language>/config/appref
        # @!attribute [rw] runtime_main_executable_path
        #   @return [::String]
        #     The path or name of the app's main executable.
        # @!attribute [rw] service_account
        #   @return [::String]
        #     The identity that the deployed version will run as.
        #     Admin API will use the App Engine Appspot service account as default if
        #     this field is neither provided in app.yaml file nor through CLI flag.
        # @!attribute [rw] handlers
        #   @return [::Array<::Google::Cloud::AppEngine::V1::UrlMap>]
        #     An ordered list of URL-matching patterns that should be applied to incoming
        #     requests. The first matching URL handles the request and other request
        #     handlers are not attempted.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] error_handlers
        #   @return [::Array<::Google::Cloud::AppEngine::V1::ErrorHandler>]
        #     Custom static error pages. Limited to 10KB per page.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] libraries
        #   @return [::Array<::Google::Cloud::AppEngine::V1::Library>]
        #     Configuration for third-party Python runtime libraries that are required
        #     by the application.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] api_config
        #   @return [::Google::Cloud::AppEngine::V1::ApiConfigHandler]
        #     Serving configuration for
        #     [Google Cloud Endpoints](https://cloud.google.com/appengine/docs/python/endpoints/).
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] env_variables
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Environment variables available to the application.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] build_env_variables
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Environment variables available to the build environment.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] default_expiration
        #   @return [::Google::Protobuf::Duration]
        #     Duration that static files should be cached by web proxies and browsers.
        #     Only applicable if the corresponding
        #     [StaticFilesHandler](https://cloud.google.com/appengine/docs/admin-api/reference/rest/v1/apps.services.versions#StaticFilesHandler)
        #     does not specify its own expiration time.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] health_check
        #   @return [::Google::Cloud::AppEngine::V1::HealthCheck]
        #     Configures health checking for instances. Unhealthy instances are
        #     stopped and replaced with new instances.
        #     Only applicable in the App Engine flexible environment.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] readiness_check
        #   @return [::Google::Cloud::AppEngine::V1::ReadinessCheck]
        #     Configures readiness health checking for instances.
        #     Unhealthy instances are not put into the backend traffic rotation.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] liveness_check
        #   @return [::Google::Cloud::AppEngine::V1::LivenessCheck]
        #     Configures liveness health checking for instances.
        #     Unhealthy instances are stopped and replaced with new instances
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] nobuild_files_regex
        #   @return [::String]
        #     Files that match this pattern will not be built into this version.
        #     Only applicable for Go runtimes.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] deployment
        #   @return [::Google::Cloud::AppEngine::V1::Deployment]
        #     Code and application artifacts that make up this version.
        #
        #     Only returned in `GET` requests if `view=FULL` is set.
        # @!attribute [rw] version_url
        #   @return [::String]
        #     Serving URL for this version. Example:
        #     "https://myversion-dot-myservice-dot-myapp.appspot.com"
        # @!attribute [rw] endpoints_api_service
        #   @return [::Google::Cloud::AppEngine::V1::EndpointsApiService]
        #     Cloud Endpoints configuration.
        #
        #     If endpoints_api_service is set, the Cloud Endpoints Extensible Service
        #     Proxy will be provided to serve the API implemented by the app.
        # @!attribute [rw] entrypoint
        #   @return [::Google::Cloud::AppEngine::V1::Entrypoint]
        #     The entrypoint for the application.
        # @!attribute [rw] vpc_access_connector
        #   @return [::Google::Cloud::AppEngine::V1::VpcAccessConnector]
        #     Enables VPC connectivity for standard apps.
        class Version
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class BetaSettingsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class EnvVariablesEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class BuildEnvVariablesEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # [Cloud Endpoints](https://cloud.google.com/endpoints) configuration.
        # The Endpoints API Service provides tooling for serving Open API and gRPC
        # endpoints via an NGINX proxy. Only valid for App Engine Flexible environment
        # deployments.
        #
        # The fields here refer to the name and configuration ID of a "service"
        # resource in the [Service Management API](https://cloud.google.com/service-management/overview).
        # @!attribute [rw] name
        #   @return [::String]
        #     Endpoints service name which is the name of the "service" resource in the
        #     Service Management API. For example "myapi.endpoints.myproject.cloud.goog"
        # @!attribute [rw] config_id
        #   @return [::String]
        #     Endpoints service configuration ID as specified by the Service Management
        #     API. For example "2016-09-19r1".
        #
        #     By default, the rollout strategy for Endpoints is `RolloutStrategy.FIXED`.
        #     This means that Endpoints starts up with a particular configuration ID.
        #     When a new configuration is rolled out, Endpoints must be given the new
        #     configuration ID. The `config_id` field is used to give the configuration
        #     ID and is required in this case.
        #
        #     Endpoints also has a rollout strategy called `RolloutStrategy.MANAGED`.
        #     When using this, Endpoints fetches the latest configuration and does not
        #     need the configuration ID. In this case, `config_id` must be omitted.
        # @!attribute [rw] rollout_strategy
        #   @return [::Google::Cloud::AppEngine::V1::EndpointsApiService::RolloutStrategy]
        #     Endpoints rollout strategy. If `FIXED`, `config_id` must be specified. If
        #     `MANAGED`, `config_id` must be omitted.
        # @!attribute [rw] disable_trace_sampling
        #   @return [::Boolean]
        #     Enable or disable trace sampling. By default, this is set to false for
        #     enabled.
        class EndpointsApiService
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Available rollout strategies.
          module RolloutStrategy
            # Not specified. Defaults to `FIXED`.
            UNSPECIFIED_ROLLOUT_STRATEGY = 0

            # Endpoints service configuration ID will be fixed to the configuration ID
            # specified by `config_id`.
            FIXED = 1

            # Endpoints service configuration ID will be updated with each rollout.
            MANAGED = 2
          end
        end

        # Automatic scaling is based on request rate, response latencies, and other
        # application metrics.
        # @!attribute [rw] cool_down_period
        #   @return [::Google::Protobuf::Duration]
        #     The time period that the
        #     [Autoscaler](https://cloud.google.com/compute/docs/autoscaler/)
        #     should wait before it starts collecting information from a new instance.
        #     This prevents the autoscaler from collecting information when the instance
        #     is initializing, during which the collected usage would not be reliable.
        #     Only applicable in the App Engine flexible environment.
        # @!attribute [rw] cpu_utilization
        #   @return [::Google::Cloud::AppEngine::V1::CpuUtilization]
        #     Target scaling by CPU usage.
        # @!attribute [rw] max_concurrent_requests
        #   @return [::Integer]
        #     Number of concurrent requests an automatic scaling instance can accept
        #     before the scheduler spawns a new instance.
        #
        #     Defaults to a runtime-specific value.
        # @!attribute [rw] max_idle_instances
        #   @return [::Integer]
        #     Maximum number of idle instances that should be maintained for this
        #     version.
        # @!attribute [rw] max_total_instances
        #   @return [::Integer]
        #     Maximum number of instances that should be started to handle requests for
        #     this version.
        # @!attribute [rw] max_pending_latency
        #   @return [::Google::Protobuf::Duration]
        #     Maximum amount of time that a request should wait in the pending queue
        #     before starting a new instance to handle it.
        # @!attribute [rw] min_idle_instances
        #   @return [::Integer]
        #     Minimum number of idle instances that should be maintained for
        #     this version. Only applicable for the default version of a service.
        # @!attribute [rw] min_total_instances
        #   @return [::Integer]
        #     Minimum number of running instances that should be maintained for this
        #     version.
        # @!attribute [rw] min_pending_latency
        #   @return [::Google::Protobuf::Duration]
        #     Minimum amount of time a request should wait in the pending queue before
        #     starting a new instance to handle it.
        # @!attribute [rw] request_utilization
        #   @return [::Google::Cloud::AppEngine::V1::RequestUtilization]
        #     Target scaling by request utilization.
        # @!attribute [rw] disk_utilization
        #   @return [::Google::Cloud::AppEngine::V1::DiskUtilization]
        #     Target scaling by disk usage.
        # @!attribute [rw] network_utilization
        #   @return [::Google::Cloud::AppEngine::V1::NetworkUtilization]
        #     Target scaling by network usage.
        # @!attribute [rw] standard_scheduler_settings
        #   @return [::Google::Cloud::AppEngine::V1::StandardSchedulerSettings]
        #     Scheduler settings for standard environment.
        class AutomaticScaling
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # A service with basic scaling will create an instance when the application
        # receives a request. The instance will be turned down when the app becomes
        # idle. Basic scaling is ideal for work that is intermittent or driven by
        # user activity.
        # @!attribute [rw] idle_timeout
        #   @return [::Google::Protobuf::Duration]
        #     Duration of time after the last request that an instance must wait before
        #     the instance is shut down.
        # @!attribute [rw] max_instances
        #   @return [::Integer]
        #     Maximum number of instances to create for this version.
        class BasicScaling
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # A service with manual scaling runs continuously, allowing you to perform
        # complex initialization and rely on the state of its memory over time.
        # @!attribute [rw] instances
        #   @return [::Integer]
        #     Number of instances to assign to the service at the start. This number
        #     can later be altered by using the
        #     [Modules API](https://cloud.google.com/appengine/docs/python/modules/functions)
        #     `set_num_instances()` function.
        class ManualScaling
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Target scaling by CPU usage.
        # @!attribute [rw] aggregation_window_length
        #   @return [::Google::Protobuf::Duration]
        #     Period of time over which CPU utilization is calculated.
        # @!attribute [rw] target_utilization
        #   @return [::Float]
        #     Target CPU utilization ratio to maintain when scaling. Must be between 0
        #     and 1.
        class CpuUtilization
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Target scaling by request utilization.
        # Only applicable in the App Engine flexible environment.
        # @!attribute [rw] target_request_count_per_second
        #   @return [::Integer]
        #     Target requests per second.
        # @!attribute [rw] target_concurrent_requests
        #   @return [::Integer]
        #     Target number of concurrent requests.
        class RequestUtilization
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Target scaling by disk usage.
        # Only applicable in the App Engine flexible environment.
        # @!attribute [rw] target_write_bytes_per_second
        #   @return [::Integer]
        #     Target bytes written per second.
        # @!attribute [rw] target_write_ops_per_second
        #   @return [::Integer]
        #     Target ops written per second.
        # @!attribute [rw] target_read_bytes_per_second
        #   @return [::Integer]
        #     Target bytes read per second.
        # @!attribute [rw] target_read_ops_per_second
        #   @return [::Integer]
        #     Target ops read per seconds.
        class DiskUtilization
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Target scaling by network usage.
        # Only applicable in the App Engine flexible environment.
        # @!attribute [rw] target_sent_bytes_per_second
        #   @return [::Integer]
        #     Target bytes sent per second.
        # @!attribute [rw] target_sent_packets_per_second
        #   @return [::Integer]
        #     Target packets sent per second.
        # @!attribute [rw] target_received_bytes_per_second
        #   @return [::Integer]
        #     Target bytes received per second.
        # @!attribute [rw] target_received_packets_per_second
        #   @return [::Integer]
        #     Target packets received per second.
        class NetworkUtilization
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Scheduler settings for standard environment.
        # @!attribute [rw] target_cpu_utilization
        #   @return [::Float]
        #     Target CPU utilization ratio to maintain when scaling.
        # @!attribute [rw] target_throughput_utilization
        #   @return [::Float]
        #     Target throughput utilization ratio to maintain when scaling
        # @!attribute [rw] min_instances
        #   @return [::Integer]
        #     Minimum number of instances to run for this version. Set to zero to disable
        #     `min_instances` configuration.
        # @!attribute [rw] max_instances
        #   @return [::Integer]
        #     Maximum number of instances to run for this version. Set to zero to disable
        #     `max_instances` configuration.
        class StandardSchedulerSettings
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Extra network settings.
        # Only applicable in the App Engine flexible environment.
        # @!attribute [rw] forwarded_ports
        #   @return [::Array<::String>]
        #     List of ports, or port pairs, to forward from the virtual machine to the
        #     application container.
        #     Only applicable in the App Engine flexible environment.
        # @!attribute [rw] instance_tag
        #   @return [::String]
        #     Tag to apply to the instance during creation.
        #     Only applicable in the App Engine flexible environment.
        # @!attribute [rw] name
        #   @return [::String]
        #     Google Compute Engine network where the virtual machines are created.
        #     Specify the short name, not the resource path.
        #
        #     Defaults to `default`.
        # @!attribute [rw] subnetwork_name
        #   @return [::String]
        #     Google Cloud Platform sub-network where the virtual machines are created.
        #     Specify the short name, not the resource path.
        #
        #     If a subnetwork name is specified, a network name will also be required
        #     unless it is for the default network.
        #
        #     * If the network that the instance is being created in is a Legacy network,
        #     then the IP address is allocated from the IPv4Range.
        #     * If the network that the instance is being created in is an auto Subnet
        #     Mode Network, then only network name should be specified (not the
        #     subnetwork_name) and the IP address is created from the IPCidrRange of the
        #     subnetwork that exists in that zone for that network.
        #     * If the network that the instance is being created in is a custom Subnet
        #     Mode Network, then the subnetwork_name must be specified and the
        #     IP address is created from the IPCidrRange of the subnetwork.
        #
        #     If specified, the subnetwork must exist in the same region as the
        #     App Engine flexible environment application.
        # @!attribute [rw] session_affinity
        #   @return [::Boolean]
        #     Enable session affinity.
        #     Only applicable in the App Engine flexible environment.
        class Network
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Volumes mounted within the app container.
        # Only applicable in the App Engine flexible environment.
        # @!attribute [rw] name
        #   @return [::String]
        #     Unique name for the volume.
        # @!attribute [rw] volume_type
        #   @return [::String]
        #     Underlying volume type, e.g. 'tmpfs'.
        # @!attribute [rw] size_gb
        #   @return [::Float]
        #     Volume size in gigabytes.
        class Volume
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Machine resources for a version.
        # @!attribute [rw] cpu
        #   @return [::Float]
        #     Number of CPU cores needed.
        # @!attribute [rw] disk_gb
        #   @return [::Float]
        #     Disk size (GB) needed.
        # @!attribute [rw] memory_gb
        #   @return [::Float]
        #     Memory (GB) needed.
        # @!attribute [rw] volumes
        #   @return [::Array<::Google::Cloud::AppEngine::V1::Volume>]
        #     User specified volumes.
        # @!attribute [rw] kms_key_reference
        #   @return [::String]
        #     The name of the encryption key that is stored in Google Cloud KMS.
        #     Only should be used by Cloud Composer to encrypt the vm disk
        class Resources
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # VPC access connector specification.
        # @!attribute [rw] name
        #   @return [::String]
        #     Full Serverless VPC Access Connector name e.g.
        #     /projects/my-project/locations/us-central1/connectors/c1.
        # @!attribute [rw] egress_setting
        #   @return [::Google::Cloud::AppEngine::V1::VpcAccessConnector::EgressSetting]
        #     The egress setting for the connector, controlling what traffic is diverted
        #     through it.
        class VpcAccessConnector
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Available egress settings.
          #
          # This controls what traffic is diverted through the VPC Access Connector
          # resource. By default PRIVATE_IP_RANGES will be used.
          module EgressSetting
            EGRESS_SETTING_UNSPECIFIED = 0

            # Force the use of VPC Access for all egress traffic from the function.
            ALL_TRAFFIC = 1

            # Use the VPC Access Connector for private IP space from RFC1918.
            PRIVATE_IP_RANGES = 2
          end
        end

        # The entrypoint for the application.
        # @!attribute [rw] shell
        #   @return [::String]
        #     The format should be a shell command that can be fed to `bash -c`.
        class Entrypoint
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Available inbound services.
        module InboundServiceType
          # Not specified.
          INBOUND_SERVICE_UNSPECIFIED = 0

          # Allows an application to receive mail.
          INBOUND_SERVICE_MAIL = 1

          # Allows an application to receive email-bound notifications.
          INBOUND_SERVICE_MAIL_BOUNCE = 2

          # Allows an application to receive error stanzas.
          INBOUND_SERVICE_XMPP_ERROR = 3

          # Allows an application to receive instant messages.
          INBOUND_SERVICE_XMPP_MESSAGE = 4

          # Allows an application to receive user subscription POSTs.
          INBOUND_SERVICE_XMPP_SUBSCRIBE = 5

          # Allows an application to receive a user's chat presence.
          INBOUND_SERVICE_XMPP_PRESENCE = 6

          # Registers an application for notifications when a client connects or
          # disconnects from a channel.
          INBOUND_SERVICE_CHANNEL_PRESENCE = 7

          # Enables warmup requests.
          INBOUND_SERVICE_WARMUP = 9
        end

        # Run states of a version.
        module ServingStatus
          # Not specified.
          SERVING_STATUS_UNSPECIFIED = 0

          # Currently serving. Instances are created according to the
          # scaling settings of the version.
          SERVING = 1

          # Disabled. No instances will be created and the scaling
          # settings are ignored until the state of the version changes
          # to `SERVING`.
          STOPPED = 2
        end
      end
    end
  end
end
