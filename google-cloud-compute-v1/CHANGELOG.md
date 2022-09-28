# Release History

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
