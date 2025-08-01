# Release History

### 0.48.0 (2025-07-28)

#### Features

* A new enum `TransparentHugepageDefrag` is added 
* A new enum `TransparentHugepageEnabled` is added ([#30714](https://github.com/googleapis/google-cloud-ruby/issues/30714)) 

### 0.47.0 (2025-06-05)

#### Features

* add allowed_unsafe_sysctls in NodeKubeletConfig 
* add alpha_cluster_feature_gates in Cluster 
* add anonymous_authentication_config in Cluster 
* add auto_monitoring_config in ManagedPrometheusConfig 
* add autopilot_compatibility_auditing_enabled in WorkloadPolicyConfig 
* add ClusterUpgradeInfo 
* add confidential_instance_type in ConfidentialNodes 
* add container_log_max_files in NodeKubeletConfig 
* add container_log_max_size in NodeKubeletConfig 
* add control_plane_endpoints_config in Cluster 
* add data_cache_count in EphemeralStorageLocalSsdConfig 
* add desired_anonymous_authentication_config in ClusterUpdate 
* add desired_compliance_posture_config in ClusterUpdate 
* add desired_control_plane_endpoints_config in ClusterUpdate 
* add desired_default_enable_private_nodes in ClusterUpdate 
* add desired_disable_l4_lb_firewall_reconciliation in ClusterUpdate 
* add desired_enterprise_config in ClusterUpdate 
* add desired_node_pool_auto_config_linux_node_config in ClusterUpdate 
* add desired_pod_autoscaling in ClusterUpdate 
* add desired_rbac_binding_config in ClusterUpdate 
* add disable_l4_lb_firewall_reconciliation in NetworkConfig 
* add effective_cgroup_mode in NodeConfig 
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
* add linux_node_config in NodePoolAutoConfig 
* add local_ssd_encryption_mode in NodeConfig 
* add max_run_duration in NodeConfig 
* add max_run_duration in UpdateNodePoolRequest 
* add MemoryManager 
* add mitigated_versions in SecurityBulletinEvent 
* add NODE_SERVICE_ACCOUNT_MISSING_PERMISSIONS in StatusCondition.Code 
* add NodePoolUpgradeInfo 
* add parallelstore_csi_driver_config in AddonsConfig 
* add performance_monitoring_unit in AdvancedMachineFeatures 
* add pod_autoscaling in Cluster 
* add private_endpoint_enforcement_enabled in MasterAuthorizedNetworksConfig 
* add rbac_binding_config in Cluster 
* add standard_support_end_time in UpgradeInfoEvent 
* add storage_pools in NodeConfig 
* add storage_pools in UpdateNodePoolRequest 
* add topology_manager in NodeKubeletConfig ([#30479](https://github.com/googleapis/google-cloud-ruby/issues/30479)) 
* add TopologyManager 
* add UPGRADE_INFO_EVENT in NotificationConfig.EventType 
* add upgrade_target_version in ReleaseChannelConfig 
* add UpgradeDetails 
* add user_managed_keys_config in Cluster 
* add user_managed_keys_config in ClusterUpdate 
#### Documentation

* Minor documentation updates 

### 0.46.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 0.45.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 0.45.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Fixed an incorrect link ([#28757](https://github.com/googleapis/google-cloud-ruby/issues/28757)) 
* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.44.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.43.0 (2024-08-30)

#### Features

* add `EXTENDED` enum value for `ReleaseChannel.Channel` ([#27024](https://github.com/googleapis/google-cloud-ruby/issues/27024)) 
#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.42.1 (2024-08-09)

#### Documentation

* Formatting updates to README.md ([#26626](https://github.com/googleapis/google-cloud-ruby/issues/26626)) 

### 0.42.0 (2024-08-05)

#### Features

* Support for Ray Clusters ([#26481](https://github.com/googleapis/google-cloud-ruby/issues/26481)) 
#### Documentation

* Mark a number of fields as read-only (i.e. only for output) ([#26524](https://github.com/googleapis/google-cloud-ruby/issues/26524)) 

### 0.41.0 (2024-07-10)

#### Features

* add DCGM enum in monitoring config ([#26378](https://github.com/googleapis/google-cloud-ruby/issues/26378)) 

### 0.40.1 (2024-07-08)

#### Documentation

* Deprecated the CHANNEL_EXPERIMENTAL option for the Gateway API ([#26259](https://github.com/googleapis/google-cloud-ruby/issues/26259)) 

### 0.40.0 (2024-05-29)

#### Features

* Various changes to cluster service ([#25969](https://github.com/googleapis/google-cloud-ruby/issues/25969)) 

### 0.39.0 (2024-04-15)

#### Features

* add several fields to manage state of database encryption update ([#25441](https://github.com/googleapis/google-cloud-ruby/issues/25441)) 
* support optional secondary boot disk update strategy ([#25423](https://github.com/googleapis/google-cloud-ruby/issues/25423)) 

### 0.38.0 (2024-03-10)

#### Features

* support secret_manager_config for clusters 

### 0.37.0 (2024-03-04)

#### Features

* add secondary boot disks field to NodePool API ([#25269](https://github.com/googleapis/google-cloud-ruby/issues/25269)) 

### 0.36.0 (2024-02-26)

#### Features

* Enable queued provisioning on existing nodepools ([#24882](https://github.com/googleapis/google-cloud-ruby/issues/24882)) 
* Update minimum Ruby version to 2.7 
* Updated minimum Ruby version to 2.7 ([#24867](https://github.com/googleapis/google-cloud-ruby/issues/24867)) 

### 0.35.0 (2024-02-05)

#### Features

* support field stateful_ha_config for AddonsConfig 

### 0.34.3 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.34.2 (2024-01-25)

#### Documentation

* Remove Not GA comments for GetOpenIDConfig and GetJSONWebKeys ([#24457](https://github.com/googleapis/google-cloud-ruby/issues/24457)) 

### 0.34.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.34.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23776](https://github.com/googleapis/google-cloud-ruby/issues/23776)) 

### 0.33.0 (2024-01-03)

#### Features

* Add field `autoscaled_rollout_policy` ([#23682](https://github.com/googleapis/google-cloud-ruby/issues/23682)) 

### 0.32.0 (2023-12-04)

#### Features

* Added enable_relay field to AdvancedDatapathObservabilityConfig ([#23567](https://github.com/googleapis/google-cloud-ruby/issues/23567)) 
* support conversion_status for AutoPilot 
* support queued_provisioning for NodePool 

### 0.31.0 (2023-11-06)

#### Features

* Support cluster enterprise config ([#23502](https://github.com/googleapis/google-cloud-ruby/issues/23502)) 

### 0.30.0 (2023-11-02)

#### Features

* Support ResourceManagerTags API ([#23486](https://github.com/googleapis/google-cloud-ruby/issues/23486)) 

### 0.29.0 (2023-09-19)

#### Features

* Support enabling confidential storage on Hyperdisk ([#23332](https://github.com/googleapis/google-cloud-ruby/issues/23332)) 
* Support for enterprise vulnerability mode 

### 0.28.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.27.0 (2023-09-07)

#### Features

* Add config options for UpdateNodePoolRequest ([#22864](https://github.com/googleapis/google-cloud-ruby/issues/22864)) 

### 0.26.0 (2023-08-15)

#### Features

* add APIs for GKE OOTB metrics packages ([#22753](https://github.com/googleapis/google-cloud-ruby/issues/22753)) 
* Support for configuring a container's binary authorization policies ([#22774](https://github.com/googleapis/google-cloud-ruby/issues/22774)) 

### 0.25.0 (2023-07-25)

#### Features

* add enable_multi_networking to NetworkConfig 
* add policy_name to PlacementPolicy message within a node pool 
* add support for AdditionalPodNetworkConfig and AdditionalNodeNetworkConfig 
* add support for HostMaintenancePolicy 

### 0.24.0 (2023-07-13)

#### Features

* Support for advanced datapath observability configs ([#22520](https://github.com/googleapis/google-cloud-ruby/issues/22520)) 

### 0.23.0 (2023-07-10)

#### Features

* Added a flag for toggling the Kubelet readonly port 
* Report the utilization of the IPv4 range for a pod 
* Support for network performance configuration ([#22466](https://github.com/googleapis/google-cloud-ruby/issues/22466)) 
* Support for the TPU placement topology 
* Support for using KubeDNS for DNS resolution 

### 0.22.0 (2023-06-06)

#### Features

* Support enabling FQDN Network Policy for a Cluster 
* Support for best-effort provisioning in a NodePool 
* Support for check_autopilot_compatibility ([#21908](https://github.com/googleapis/google-cloud-ruby/issues/21908)) 
* Support for Kubernetes Beta APIs in a Cluster 
* Support parameters for node pools to be backed by shared sole tenant node groups 
* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.21.1 (2023-05-19)

#### Documentation

* clarify release channel defaulting behavior 

### 0.21.0 (2023-05-08)

#### Features

* Support for configuring the Cloud Storage Fuse CSI driver 
* Support for fleet registration via cluster update 

### 0.20.0 (2023-04-27)

#### Features

* Add option RESIZE_CLUSTER to enum Operation Type ([#21483](https://github.com/googleapis/google-cloud-ruby/issues/21483)) 
* Add state field to DatabaseEncryption ([#21483](https://github.com/googleapis/google-cloud-ruby/issues/21483)) 
#### Documentation

* Expand documentation for Operation Type ([#21483](https://github.com/googleapis/google-cloud-ruby/issues/21483)) 

### 0.19.0 (2023-04-21)

#### Features

* Support additional pod IPv4 ranges ([#21443](https://github.com/googleapis/google-cloud-ruby/issues/21443)) 

### 0.18.0 (2023-04-10)

#### Features

* support AdditionalPodRangesConfig for IPAllocationPolicy 

### 0.17.0 (2023-03-29)

#### Features

* Added support for fleet registration ([#21031](https://github.com/googleapis/google-cloud-ruby/issues/21031)) 

### 0.16.3 (2023-03-08)

#### Documentation

* minor typo fix ([#20607](https://github.com/googleapis/google-cloud-ruby/issues/20607)) 

### 0.16.2 (2023-02-13)

#### Documentation

* Improve documentation for NodePool ([#20114](https://github.com/googleapis/google-cloud-ruby/issues/20114)) 

### 0.16.1 (2023-01-31)

#### Documentation

* clarify wording around the NodePoolUpdateStrategy default behavior ([#20100](https://github.com/googleapis/google-cloud-ruby/issues/20100)) 

### 0.16.0 (2023-01-11)

#### Features

* Support for etags in clusters and node pools ([#19980](https://github.com/googleapis/google-cloud-ruby/issues/19980)) 

### 0.15.0 (2023-01-05)

#### Features

* add stack type for clusters ([#19895](https://github.com/googleapis/google-cloud-ruby/issues/19895)) 
* Support for local SSD configs in a node config 
* Support for setting windows node config when updating a node pool ([#19907](https://github.com/googleapis/google-cloud-ruby/issues/19907)) 

### 0.14.0 (2022-12-09)

#### Features

* Support for enabling NCCL Fast Sockets in a node pool ([#19477](https://github.com/googleapis/google-cloud-ruby/issues/19477)) 

### 0.13.0 (2022-11-08)

#### Features

* support enabling private nodes 
* support enabling private nodes 
* support GatewayAPIConfig 

### 0.12.0 (2022-10-18)

#### Features

* support workload vulnerability mode 

### 0.11.0 (2022-09-16)

#### Features

* Support for high throughput logging config ([#19177](https://github.com/googleapis/google-cloud-ruby/issues/19177)) 

### 0.10.1 (2022-08-04)

#### Documentation

* BinaryAuthorization.enabled field is marked as deprecated ([#18956](https://github.com/googleapis/google-cloud-ruby/issues/18956)) 

### 0.10.0 (2022-07-02)

#### Features

* Support for ignoring the pod disruption budget when rolling back node pool upgrades 
* Support for the complete_node_pool_upgrade call ([#18458](https://github.com/googleapis/google-cloud-ruby/issues/18458)) 
* Support network config and conventional nodes during node pool updates 
* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.9.0 / 2022-02-16

#### Features

* Support for additional node configs, including GCFS, Spot VMs, and placement policy

### 0.8.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.8.2 / 2021-12-07

#### Documentation

* Formatting fixes in the reference docs

### 0.8.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.8.0 / 2021-09-21

#### Features

* Support for updating tags, taints, labels, and gvnic on node pools

### 0.7.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.0 / 2021-07-12

#### Features

* Support for updating a cluster's authenticator_groups_config
  * changes without context
  * chore(ruby): Use latest microgenerator for Bazel GAPIC generation
  * chore(ruby): Use latest microgenerator for Bazel GAPIC generation
  * chore(ruby): Switch Bazel jobs to use the Ruby gapic-generator 0.9.0
  * feat: add new FieldBehavior NON_EMPTY_DEFAULT
  * feat: allow updating security group on existing clusters

#### Documentation

* Clarify some language around authentication configuration

### 0.6.0 / 2021-06-17

#### Features

* Support image_type for node autoprovisioning

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.1 / 2021-03-10

#### Documentation

* Fix a broken link in the reference documentation

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-02

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

### 0.2.1 / 2020-05-25

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.0 / 2020-05-05

Initial release.
