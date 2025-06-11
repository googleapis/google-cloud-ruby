# Changelog

### 2.0.1 (2025-03-18)

#### Documentation

* Minor updates to reference documentation ([#29364](https://github.com/googleapis/google-cloud-ruby/issues/29364)) 

### 2.0.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28825](https://github.com/googleapis/google-cloud-ruby/issues/28825))

#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28825](https://github.com/googleapis/google-cloud-ruby/issues/28825)) 

### 1.6.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.5.0 (2025-01-23)

#### Features

* Support for VpcFlowLogsService ([#28231](https://github.com/googleapis/google-cloud-ruby/issues/28231)) 

### 1.4.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.3.0 (2024-12-04)

#### Features

* add round-trip mode ([#27614](https://github.com/googleapis/google-cloud-ruby/issues/27614)) 

### 1.2.0 (2024-11-13)

#### Features

* add DNS endpoint of Google Kubernetes Engine cluster control plane ([#27577](https://github.com/googleapis/google-cloud-ruby/issues/27577)) 
* add more detailed drop causes to corresponding enum 
#### Documentation

* update outdated comments 

### 1.1.0 (2024-10-28)

#### Features

* add fields related to advertised routes to the RouteInfo proto 
* add firewall policy URI to the FirewallInfo proto 
* add load balancer name to the ForwardingRuleInfo proto 
* add messages and fields related to Redis Clusters 
* add messages and fields related to Redis Instances ([#27447](https://github.com/googleapis/google-cloud-ruby/issues/27447)) 
* add more detailed abort and drop causes to corresponding enums 
* add PSC network attachment URI to the InstanceInfo proto 
* add PSC target fields to the ForwardingRuleInfo proto 
* add region name field to the RouteInfo proto 
* add region name to the ForwardingRuleInfo proto 
* add subnet URI and region name to the NetworkInfo proto 
#### Documentation

* update outdated comments in the FirewallInfo proto 

### 1.0.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27010](https://github.com/googleapis/google-cloud-ruby/issues/27010)) 

### 1.0.1 (2024-08-08)

#### Documentation

* Formatting updates to README.md ([#26676](https://github.com/googleapis/google-cloud-ruby/issues/26676)) 

### 1.0.0 (2024-07-10)

#### Features

* Bump version to 1.0.0 

### 0.14.0 (2024-04-15)

#### Features

* add new fields and enum values related to round-trip ([#25417](https://github.com/googleapis/google-cloud-ruby/issues/25417)) 
#### Documentation

* update possible firewall rule actions comment ([#25445](https://github.com/googleapis/google-cloud-ruby/issues/25445)) 

### 0.13.0 (2024-03-18)

#### Features

* Support binding overrides for network management ([#25378](https://github.com/googleapis/google-cloud-ruby/issues/25378)) 

### 0.12.0 (2024-03-14)

#### Features

* Support metadata for load balancer ([#25352](https://github.com/googleapis/google-cloud-ruby/issues/25352)) 
* Support metadata for NAT ([#25352](https://github.com/googleapis/google-cloud-ruby/issues/25352)) 
* Support metadata for ProxyConnection ([#25352](https://github.com/googleapis/google-cloud-ruby/issues/25352)) 
* Support metadata for Storage Bucket ([#25352](https://github.com/googleapis/google-cloud-ruby/issues/25352)) 

### 0.11.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24873](https://github.com/googleapis/google-cloud-ruby/issues/24873)) 

### 0.10.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.10.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.10.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23782](https://github.com/googleapis/google-cloud-ruby/issues/23782)) 

### 0.9.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22921](https://github.com/googleapis/google-cloud-ruby/issues/22921)) 

### 0.8.0 (2023-08-15)

#### Features

* Add `CloudFunctionEndpoint`, `AppEngineVersionEndpoint`, `CloudRunRevisionEndpoint` endpoints ([#22762](https://github.com/googleapis/google-cloud-ruby/issues/22762)) 
* Add support for `CloudFunctionInfo`, `CloudRunRevisionInfo`, `AppEngineVersionInfo`, `VpcConnectorInfo` 
* A step in a forwarding path can be a Google Service 
* Added route scope, IP and port ranges, protocols, and NCC URIs to RouteInfo 
* Connectivity test runs now return probing details ([#22767](https://github.com/googleapis/google-cloud-ruby/issues/22767)) 
* Endpoint now includes forwarding rule and load balancer info 
* Support additional abort cause types and drop cause types 
* Support additional states for packet trace steps 
* Support additional target types for DeliverInfo and ForwardInfo 
* Support for EndpointInfo#source_agent_uri 
* Support for POLICY_BASED route type 
* Support for TARGET_INSTANCE load balancer backend type 

### 0.7.0 (2023-06-27)

#### Features

* Support forwarding_rule for Connectivity Test Endpoint ([#22449](https://github.com/googleapis/google-cloud-ruby/issues/22449)) 

### 0.6.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21676](https://github.com/googleapis/google-cloud-ruby/issues/21676)) 

### 0.5.1 (2023-04-20)

#### Documentation

* Improve docs in Connectivity Test ([#21448](https://github.com/googleapis/google-cloud-ruby/issues/21448)) 

### 0.5.0 (2023-03-08)

#### Features

* Support REST transport ([#20627](https://github.com/googleapis/google-cloud-ruby/issues/20627)) 

### 0.4.0 (2022-07-19)

#### Features

* Added router appliance next hop type  ([#18825](https://github.com/googleapis/google-cloud-ruby/issues/18825)) 

### 0.3.0 (2022-07-05)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.0 (2022-06-28)

#### Features

* introduce a projects_missing_permissions field in the AbortInfo structure 

### 0.1.3 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.1.0 / 2021-07-23

#### Features

* Initial generation of google-cloud-network_management-v1
