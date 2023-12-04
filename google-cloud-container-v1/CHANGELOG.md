# Release History

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
