# Changelog

### 1.0.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28826](https://github.com/googleapis/google-cloud-ruby/issues/28826))

#### Features

* Bump version to 1.0.0 ([#28941](https://github.com/googleapis/google-cloud-ruby/issues/28941)) 
#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28826](https://github.com/googleapis/google-cloud-ruby/issues/28826)) 

### 0.11.0 (2025-01-29)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.10.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.9.2 (2024-12-05)

#### Documentation

* Documentation improvements related to long-running operations ([#27633](https://github.com/googleapis/google-cloud-ruby/issues/27633)) 

### 0.9.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.9.0 (2024-07-22)

#### Features

* Support for Cluster autoscaling settings 
* Support for the ACTIVATING state of the HCX Cloud Manager appliance 
* Support for TLS, SSL, and RELP protocols for the logging server 

### 0.8.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24880](https://github.com/googleapis/google-cloud-ruby/issues/24880)) 

### 0.7.1 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.7.0 (2024-01-19)

#### Features

* Support fetch_network_policy_external_addresses RPC 
* Support for NetworkConfig#dns_server_ip 
* Support for node kind, families, and capabilities 
* Support for stretched cluster configs 
* Support for Subnet#vlan_id 
* Support for the optional username argument to show_vcenter_credentials and reset_vcenter_credentials 
* Support get and update operations on DNS forwarding resources 
* Support get, grant, and revoke operations on DNS bind permissions 
* Support getting and listing nodes 
* Support list_peering_routes RPC 
* Support listing and CRUD operations on external access rules 
* Support listing and CRUD operations on external addresses 
* Support listing and CRUD operations on logging servers 
* Support listing and CRUD operations on network peering resources 
* Support listing, repair, and CRUD operations on management DNS zone bindings 

### 0.6.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.6.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23788](https://github.com/googleapis/google-cloud-ruby/issues/23788)) 

### 0.5.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22925](https://github.com/googleapis/google-cloud-ruby/issues/22925)) 

### 0.4.0 (2023-06-16)

#### Features

* Added RECONCILING and FAILED subnet states 
* Added type field to PrivateCloud resource 
* Support for listing private connection peering routes 
* Support for private connection management RPCs 
* Support for the get_subnet and update_subnet RPCs 

### 0.3.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.3.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21680](https://github.com/googleapis/google-cloud-ruby/issues/21680)) 

### 0.2.0 (2023-03-08)

#### Features

* Support REST transport ([#20630](https://github.com/googleapis/google-cloud-ruby/issues/20630)) 

### 0.1.1 (2023-01-11)

#### Documentation

* Updated example resource names to reference a supported location ([#19989](https://github.com/googleapis/google-cloud-ruby/issues/19989)) 

### 0.1.0 (2022-12-06)

#### Features

* Initial generation of google-cloud-vmware_engine-v1 ([#19482](https://github.com/googleapis/google-cloud-ruby/issues/19482)) 

## Release History
