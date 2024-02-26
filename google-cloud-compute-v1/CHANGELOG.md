# Release History

### 2.9.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24867](https://github.com/googleapis/google-cloud-ruby/issues/24867)) 

### 2.8.0 (2024-02-08)

#### Features

* Add PerformMaintenance API ([#24781](https://github.com/googleapis/google-cloud-ruby/issues/24781)) 
* Support config for SecurityPolicyRuleMatcherExprOptions ([#24781](https://github.com/googleapis/google-cloud-ruby/issues/24781)) 
* Support Region Zones API ([#24781](https://github.com/googleapis/google-cloud-ruby/issues/24781)) 

### 2.7.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 2.7.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 2.7.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23776](https://github.com/googleapis/google-cloud-ruby/issues/23776)) 

### 2.6.0 (2023-12-12)

#### Features

* Update Compute Engine API to revision 20231110 ([#23639](https://github.com/googleapis/google-cloud-ruby/issues/23639)) 

### 2.5.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 2.4.0 (2023-07-27)

#### Features

* support patch with resource policy 

### 2.3.0 (2023-07-10)

#### Features

* Numerous changes to track the latest API features ([#22468](https://github.com/googleapis/google-cloud-ruby/issues/22468)) 

### 2.2.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 2.1.0 (2023-03-21)

#### Features

* Add support for SimulateMaintenanceEvent ([#20917](https://github.com/googleapis/google-cloud-ruby/issues/20917)) 
* Added support for Disks, RegionDisks 
* Added support for field proto_reference_documentation_uri to proto reference documentation. 
* Added support for Instances, RegionInstanceTemplates and InstanceTemplates 
* Added support for overrides_by_request_protocol to backend.proto 
* Added support for SERVICE_NOT_VISIBLE and GCP_SUSPENDED into error reason 

### 2.0.0 (2023-02-14)

### ⚠ BREAKING CHANGES

* Calling an RPC with a block yields a TransportOperation rather than a Faraday object ([#20404](https://github.com/googleapis/google-cloud-ruby/issues/20404))

#### Features

* Calling an RPC with a block yields a TransportOperation rather than a Faraday object ([#20404](https://github.com/googleapis/google-cloud-ruby/issues/20404)) 

### 1.10.0 (2023-01-26)

#### Features

* Added AllocationSpecificSKUReservation#source_instance_template ([#20054](https://github.com/googleapis/google-cloud-ruby/issues/20054)) 
* Added NetworkInterface#network_attachment 
* Added Reservation#resource_status 

### 1.9.0 (2023-01-10)

#### Features

* Support for adding resource policies to a reservation 
* Support for bundle aggregation type and bundle operational status in Interconnect 
* Support for discarding local SSDs when stopping or suspending an instance 
* Support for quota projects 
* Support for retry policy confguration 
* Support for specifying the network URL when setting ServiceAttachmentConsumerProjectLimit 
* Support for the Network Attachments service 
* Support for the TargetTcpProxies#aggregated_list call ([#19463](https://github.com/googleapis/google-cloud-ruby/issues/19463)) 
* Support for VM internal DNS settings 
* Use self-signed JWT credentials if available 

### 1.8.0 (2022-10-25)

#### Features

* Added Address#ipv6_endpoint_type 
* Added enable_ipv6, ipv6_nexthop_address, md5_auth_enabled, peer_ipv6_nexthop_address, and status_reason fields to RouterStatusBgpPeerStatus 
* Added ErrorDetails#quota_info 
* Added Instance#resource_status 
* Added InstanceGroupManager#list_managed_instances_results 
* Added NetworkEndpointGroup#psc_data 
* Added Router#md5_authentication_keys 
* Added RouterBgpPeer#md5_authentication_key_name 
* Updated Compute Engine API to revision 20221011 ([#19324](https://github.com/googleapis/google-cloud-ruby/issues/19324)) 
#### Documentation

* Numerous documentation improvements 

### 1.7.1 (2022-09-28)

#### Bug Fixes

* Ensure exceptions have the correct cause ([#19227](https://github.com/googleapis/google-cloud-ruby/issues/19227)) 

### 1.7.0 (2022-09-16)

#### Features

* Support for additional Disk params 
* Support for AdvancedMachineFeatures#visible_core_count 
* Support for AttachedDisk#force_attach 
* Support for BackendBucket#compression_mode 
* Support for BackendService#compression_mode 
* Support for Commitment#merge_source_commitments and Commitment#split_source_commitment 
* Support for getting an aggregated list of SslPolicy resources 
* Support for managing access control policies on backend services 
* Support for managing RegionSslPolicies 
* Support for managing RegionTargetTcpProxies 
* Support for NodeGroup#share_settings 
* Support for NodeGroupNode#consumed_resources, NodeGroupNode#instance_consumption_data, and NodeGroupNode#total_resources 
* Support for SecurityPolicyAdvancedOptionsConfig#json_custom_config 
* Support for setting labels on various resource types ([#19164](https://github.com/googleapis/google-cloud-ruby/issues/19164)) 
* Support for SslPolicy#region 
* Support for TargetTclPolicy#region 

### 1.6.0 (2022-08-09)

#### Features

* Catch path formatting errors on the client side ([#18962](https://github.com/googleapis/google-cloud-ruby/issues/18962)) 
* Report the resource policy that created a scheduled snapshot 
* Report the size of a snapshot at creation time 
* Support for architecture of instance-attached disk resources 
* Support for error details and localized error messages 
* Support for KeyRevocationActionType 
* Support for LocationPolicyLocationConstraints 
* Support for NAT rule mappings information 
* Support for network firewall policy 
* Support for SnapshotType 

### 1.5.0 (2022-07-19)

#### Features

* Updated minimum required Ruby to 2.6 ([#18442](https://github.com/googleapis/google-cloud-ruby/issues/18442)) 
#### Bug Fixes

* Transcoding methods in the service stub classes are now private 

### 1.4.0 (2022-06-08)

#### Features

* Various updates

### 1.3.0 (2022-04-13)

#### Features

* Support for the NetworkEdgeSecurity service
* Support for the NetworkFirewallPolicies service
* Support for the RegionSecurityPolicies service
* Support for patching RegionTargetHttpsProxies
* Support for retrieving aggregated lists of security policies

### 1.2.0 / 2022-03-15

#### Features

* use the new nonstandard LRO helpers

### 1.1.0 / 2022-02-15

#### Features

* Support for machine image management
* Support for source machine images when creating an instance
* Support for enabling UEFI networking when creating an instance
* Support for instance suspend and resume
* Support for edge security policy, cache key policy, and connection tracking policy for backends
* Support for updating region commitments
* Support for updating reservations
* Support for creating snapshots

### 1.0.0 / 2022-01-11

#### Features

* GA release of google-cloud-compute-v1

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.5.0 / 2021-12-08

#### Bug Fixes

* BREAKING CHANGE: A number of fields have changed from enumerations to strings
* BREAKING CHANGE: Renamed IPProtocol to IPProtocolEnum

### 0.4.0 / 2021-11-11

#### Features

* Updated to reflect the latest API definitions

### 0.3.0 / 2021-09-09

#### Features

* Various updates for beta

### 0.2.0 / 2021-06-21

#### Features

* Numerous updates targeting public preview

### 0.1.0 / 2021-05-10

* Initial alpha release
