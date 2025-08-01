# Release History

### 1.9.0 (2025-07-17)

#### Features

* Support for configuring the transparent hugepage on Linux nodes 
* The update_node_pool RPC supports the boot disk parameter 

### 1.8.0 (2025-06-05)

#### Features

* add allowed_unsafe_sysctls in NodeKubeletConfig 
* add alpha_cluster_feature_gates in Cluster 
* add auto_monitoring_config in ManagedPrometheusConfig 
* add autopilot_compatibility_auditing_enabled in WorkloadPolicyConfig 
* add ClusterUpgradeInfo 
* add confidential_instance_type in ConfidentialNodes 
* add container_log_max_files in NodeKubeletConfig 
* add container_log_max_size in NodeKubeletConfig 
* add data_cache_count in EphemeralStorageLocalSsdConfig 
* add desired_anonymous_authentication_config in ClusterUpdate 
* add desired_disable_l4_lb_firewall_reconciliation in ClusterUpdate 
* add desired_pod_autoscaling in ClusterUpdate 
* add disable_l4_lb_firewall_reconciliation in NetworkConfig 
* add event_type in UpgradeInfoEvent 
* add extended_support_end_time in UpgradeInfoEvent 
* add FetchClusterUpgradeInfoRequest 
* add FetchNodePoolUpgradeInfoRequest 
* add flex_start in NodeConfig 
* add flex_start in UpdateNodePoolRequest 
* add high_scale_checkpointing_config in AddonsConfig 
* add image_gc_high_threshold_percent in NodeKubeletConfig 
* add image_gc_low_threshold_percent in NodeKubeletConfig 
* add image_maximum_gc_age in NodeKubeletConfig 
* add image_minimum_gc_age in NodeKubeletConfig 
* add JOBSET in MonitoringComponentConfig.Component 
* add KCP_HPA in LoggingComponentConfig.Component 
* add max_run_duration in NodeConfig 
* add max_run_duration in UpdateNodePoolRequest 
* add mitigated_versions in SecurityBulletinEvent 
* add NODE_SERVICE_ACCOUNT_MISSING_PERMISSIONS in StatusCondition.Code 
* add NodePoolUpgradeInfo 
* add performance_monitoring_unit in AdvancedMachineFeatures 
* add pod_autoscaling in Cluster 
* add standard_support_end_time in UpgradeInfoEvent 
* add topology_manager in NodeKubeletConfig ([#30442](https://github.com/googleapis/google-cloud-ruby/issues/30442)) 
* add UPGRADE_INFO_EVENT in NotificationConfig.EventType 
* add UpgradeDetails 
#### Documentation

* Minor documentation updates 

### 1.7.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.6.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.6.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Fixed an incorrect link ([#28758](https://github.com/googleapis/google-cloud-ruby/issues/28758)) 
* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.5.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.4.0 (2024-11-13)

#### Features

* add desired_enterprise_config,desired_node_pool_auto_config_linux_node_config to ClusterUpdate. 
* add desired_tier to EnterpriseConfig. 
* add DesiredEnterpriseConfig proto message 
* add LinuxNodeConfig in NodePoolAutoConfig 
* add LocalSsdEncryptionMode in NodeConfig ([#27579](https://github.com/googleapis/google-cloud-ruby/issues/27579)) 
* add UpgradeInfoEvent proto message 
#### Documentation

* Minor documentation updates 

### 1.3.0 (2024-10-15)

#### Features

* Added storage pools field to NodePool API ([#27429](https://github.com/googleapis/google-cloud-ruby/issues/27429)) 

### 1.2.0 (2024-08-30)

#### Features

* add ReleaseChannel EXTENDED value ([#27022](https://github.com/googleapis/google-cloud-ruby/issues/27022)) 
#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.1.1 (2024-08-09)

#### Documentation

* Formatting updates to README.md ([#26626](https://github.com/googleapis/google-cloud-ruby/issues/26626)) 

### 1.1.0 (2024-08-05)

#### Features

* Support for DCGM monitoring ([#26447](https://github.com/googleapis/google-cloud-ruby/issues/26447)) 
* Support for Ray Clusters ([#26480](https://github.com/googleapis/google-cloud-ruby/issues/26480)) 
#### Documentation

* Mark a number of fields as read-only (i.e. only for output) ([#26515](https://github.com/googleapis/google-cloud-ruby/issues/26515)) 

### 1.0.0 (2024-07-08)

#### Features

* Bump version to 1.0.0 

### 0.42.0 (2024-06-12)

#### Features

* support for REST transport ([#26088](https://github.com/googleapis/google-cloud-ruby/issues/26088)) 

### 0.41.0 (2024-06-10)

#### Features

* A new field `accelerators` is added to message `.google.container.v1.UpdateNodePoolRequest` 
* A new field `additive_vpc_scope_dns_domain` is added to message `.google.container.v1.DNSConfig` 
* A new field `containerd_config` is added to message `.google.container.v1.NodeConfig` 
* A new field `containerd_config` is added to message `.google.container.v1.NodeConfigDefaults` 
* A new field `containerd_config` is added to message `.google.container.v1.UpdateNodePoolRequest` 
* A new field `desired_containerd_config` is added to message `.google.container.v1.ClusterUpdate` 
* A new field `desired_node_kubelet_config` is added to message `.google.container.v1.ClusterUpdate` 
* A new field `desired_node_pool_auto_config_kubelet_config` is added to message `.google.container.v1.ClusterUpdate` 
* A new field `enable_nested_virtualization` is added to message `.google.container.v1.AdvancedMachineFeatures` 
* A new field `hugepages` is added to message `.google.container.v1.LinuxNodeConfig` 
* A new field `node_kubelet_config` is added to message `.google.container.v1.NodeConfigDefaults` 
* A new field `node_kubelet_config` is added to message `.google.container.v1.NodePoolAutoConfig` 
* A new field `satisfies_pzi` is added to message `.google.container.v1.Cluster` 
* A new field `satisfies_pzs` is added to message `.google.container.v1.Cluster` 
* A new message `ContainerdConfig` is added 
* A new message `HugepagesConfig` is added ([#26082](https://github.com/googleapis/google-cloud-ruby/issues/26082)) 
* A new value `CADVISOR` is added to enum `Component` 
* A new value `ENTERPRISE` is added to enum `Mode` 
* A new value `KUBELET` is added to enum `Component` 
* A new value `MPS` is added to enum `GPUSharingStrategy` 
#### Documentation

* A comment for field `desired_private_cluster_config` in message `.google.container.v1.ClusterUpdate` is changed 
* A comment for field `in_transit_encryption_config` in message `.google.container.v1.NetworkConfig` is changed 

### 0.40.0 (2024-04-15)

#### Features

* add several fields to manage state of database encryption update ([#25442](https://github.com/googleapis/google-cloud-ruby/issues/25442)) 
* support optional secondary boot disk update strategy ([#25422](https://github.com/googleapis/google-cloud-ruby/issues/25422)) 

### 0.39.0 (2024-03-10)

#### Features

* support desired_enable_cilium_clusterwide_network_policy for clusters 
* support enable_cilium_clusterwide_network_policy for NetworkConfig 

### 0.38.0 (2024-03-07)

#### Features

* add secondary boot disks field to NodePool API 

### 0.37.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24867](https://github.com/googleapis/google-cloud-ruby/issues/24867)) 

### 0.36.0 (2024-02-22)

#### Features

* Support queued provisioning on existing node pools ([#24849](https://github.com/googleapis/google-cloud-ruby/issues/24849)) 

### 0.35.0 (2024-02-08)

#### Features

* Add `stateful_ha_config` field to AddonsConfig ([#24773](https://github.com/googleapis/google-cloud-ruby/issues/24773)) 

### 0.34.1 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.34.0 (2024-01-25)

#### Features

* add fields desired_in_transit_encryption_config and in_transit_encryption_config ([#24458](https://github.com/googleapis/google-cloud-ruby/issues/24458)) 
#### Documentation

* Remove Not GA comments for GetOpenIDConfig and GetJSONWebKeys 

### 0.33.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.33.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23776](https://github.com/googleapis/google-cloud-ruby/issues/23776)) 

### 0.32.0 (2023-12-04)

#### Features

* Added enable_relay field to AdvancedDatapathObservabilityConfig ([#23566](https://github.com/googleapis/google-cloud-ruby/issues/23566)) 
* support queued_provisioning for NodePool 

### 0.31.0 (2023-11-06)

#### Features

* Support cluster enterprise config ([#23503](https://github.com/googleapis/google-cloud-ruby/issues/23503)) 

### 0.30.0 (2023-11-02)

#### Features

* Support ResourceManagerTags API ([#23488](https://github.com/googleapis/google-cloud-ruby/issues/23488)) 

### 0.29.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.28.0 (2023-09-05)

#### Features

* add support for NodeConfig Update ([#22863](https://github.com/googleapis/google-cloud-ruby/issues/22863)) 

### 0.27.0 (2023-08-15)

#### Features

* add APIs for GKE OOTB metrics packages ([#22752](https://github.com/googleapis/google-cloud-ruby/issues/22752)) 

### 0.26.0 (2023-07-19)

#### Features

* Add Multi-networking API ([#22547](https://github.com/googleapis/google-cloud-ruby/issues/22547)) 
* Add policy_name to PlacementPolicy message within a node pool 

### 0.25.0 (2023-07-13)

#### Features

* Support for advanced datapath observability configs ([#22521](https://github.com/googleapis/google-cloud-ruby/issues/22521)) 
* Support for Cloud Storage Fuse CSI driver configs 
* Support for enabling/disabling the Kubelet readonly port 
* Support for IPv4 range utilization 

### 0.24.0 (2023-07-10)

#### Features

* Support for network performance configuration ([#22464](https://github.com/googleapis/google-cloud-ruby/issues/22464)) 
* Support for using KubeDNS for DNS resolution 

### 0.23.0 (2023-06-16)

#### Features

* add API for GPU driver installation config ([#22377](https://github.com/googleapis/google-cloud-ruby/issues/22377)) 
* add SecurityPostureConfig API field to allow customers to enable GKE Security Posture capabilities for their clusters 
* add workloadPolicyConfig API field to allow customer enable NET_ADMIN capability for their autopilot clusters 

### 0.22.0 (2023-06-06)

#### Features

* Support enabling FQDN Network Policy for a Cluster 
* Support for best-effort provisioning in a NodePool 
* Support for check_autopilot_compatibility ([#21907](https://github.com/googleapis/google-cloud-ruby/issues/21907)) 
* Support for Kubernetes Beta APIs in a Cluster 
* Support parameters for node pools to be backed by shared sole tenant node groups 
* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.21.1 (2023-05-19)

#### Documentation

* clarify release channel defaulting behavior 

### 0.21.0 (2023-05-04)

#### Features

* support fleet registration via cluster update ([#21535](https://github.com/googleapis/google-cloud-ruby/issues/21535)) 

### 0.20.0 (2023-04-24)

#### Features

* Add option RESIZE_CLUSTER to enum Operation Type ([#21471](https://github.com/googleapis/google-cloud-ruby/issues/21471)) 
* Add state field to DatabaseEncryption ([#21471](https://github.com/googleapis/google-cloud-ruby/issues/21471)) 
#### Documentation

* Expand documentation for Operation Type ([#21471](https://github.com/googleapis/google-cloud-ruby/issues/21471)) 

### 0.19.0 (2023-04-21)

#### Features

* Support additional pod IPv4 ranges ([#21442](https://github.com/googleapis/google-cloud-ruby/issues/21442)) 

### 0.18.0 (2023-04-10)

#### Features

* support AdditionalPodRangesConfig for IPAllocationPolicy 

### 0.17.0 (2023-03-29)

#### Features

* Added support for fleet registration ([#21020](https://github.com/googleapis/google-cloud-ruby/issues/21020)) 

### 0.16.3 (2023-03-08)

#### Documentation

* minor typo fix ([#20606](https://github.com/googleapis/google-cloud-ruby/issues/20606)) 

### 0.16.2 (2023-02-13)

#### Documentation

* Add clarification on whether NodePool.version is a required field ([#20118](https://github.com/googleapis/google-cloud-ruby/issues/20118)) 

### 0.16.1 (2023-01-31)

#### Documentation

* clarify wording around the NodePoolUpdateStrategy default behavior ([#20099](https://github.com/googleapis/google-cloud-ruby/issues/20099)) 

### 0.16.0 (2023-01-19)

#### Features

* Added support for viewing the subnet IPv6 CIDR and services IPv6 CIDR assigned to dual stack clusters ([#20035](https://github.com/googleapis/google-cloud-ruby/issues/20035)) 

### 0.15.0 (2023-01-05)

#### Features

* Support for local SSD configs in a node config 
* Support for setting etag and windows node config when updating a node pool ([#19908](https://github.com/googleapis/google-cloud-ruby/issues/19908)) 

### 0.14.0 (2022-12-15)

#### Features

* Added support for specifying stack type for clusters ([#19881](https://github.com/googleapis/google-cloud-ruby/issues/19881)) 

### 0.13.0 (2022-12-09)

#### Features

* Support for enabling NCCL Fast Sockets in a node pool ([#19475](https://github.com/googleapis/google-cloud-ruby/issues/19475)) 

### 0.12.0 (2022-11-16)

#### Features

* support placement_policy 

### 0.11.0 (2022-10-18)

#### Features

* add stacktype and IPV6AccessType to IPAllocationPolicy 
* support cost management config 
* support GKE backup agent config 

### 0.10.0 (2022-09-16)

#### Features

* Support for high throughput logging config ([#19180](https://github.com/googleapis/google-cloud-ruby/issues/19180)) 

### 0.9.1 (2022-08-04)

#### Documentation

* BinaryAuthorization.enabled field is marked as deprecated ([#18957](https://github.com/googleapis/google-cloud-ruby/issues/18957)) 

### 0.9.0 (2022-07-02)

#### Features

* Support for ignoring the pod disruption budget when rolling back node pool upgrades 
* Support for the complete_node_pool_upgrade call ([#18479](https://github.com/googleapis/google-cloud-ruby/issues/18479)) 
* Support network config and conventional nodes during node pool updates 
* Support updating tags, taints, and labels for node pools 
* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.8.0 / 2022-02-16

#### Features

* Support for Linux kernel configuration
* Support for node Kubelet configuration
* Support for Google Container File System configuration
* Support for enabling Virtual NIC on node pools
* Support for several advanced machine features
* Support for node pool-level network configuration
* Support for additional CSI driver add-on configurations
* Support for mesh certificates
* Support for cluster logging, monitoring, and notifications
* Support for configuring the cluster autoscaling profile
* Support for Autopilot
* Support for confidential nodes
* Various additional cluster-level networking configurations

### 0.7.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.0 / 2021-07-12

#### Features

* Support for configuring authenticator groups when updating a cluster

#### Documentation

* Clarify some language around authentication configuration

### 0.6.0 / 2021-06-17

#### Features

* Support image_type for node autoprovisioning

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.3.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.0 / 2020-12-02

#### Features

* Support get_json_web_keys and additional node pool options

### 0.2.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.2.2 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fixed broken links in the reference documentation

### 0.2.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.0 / 2020-05-05

Initial release.
