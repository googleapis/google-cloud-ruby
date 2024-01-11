# Release History

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
