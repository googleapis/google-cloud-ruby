# Changelog

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
