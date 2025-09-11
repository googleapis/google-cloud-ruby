# Changelog

### 0.11.0 (2025-09-11)

#### Features

* update gapic-common dependency for generated libraries to 1.2 which requires google-protobuf v4.26+ ([#31015](https://github.com/googleapis/google-cloud-ruby/issues/31015)) 

### 0.10.0 (2025-08-29)

#### Features

* Added RequestOrderDateChange RPC - allows Customers to request date changes ([#30918](https://github.com/googleapis/google-cloud-ruby/issues/30918)) 

### 0.9.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 0.8.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 0.8.0 (2025-04-25)

#### Features

* Support deployment type and installation date for an Order 
* Support hardware count ranges for a SKU 
* Support step and details parameters to the signal_zone_state RPC 

### 0.7.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28824](https://github.com/googleapis/google-cloud-ruby/issues/28824))

#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28824](https://github.com/googleapis/google-cloud-ruby/issues/28824)) 

### 0.6.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.5.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.4.0 (2024-11-14)

#### Features

* add DNS address, Kubernetes primary VLAN ID, and provisioning state to the Zone resource ([#27605](https://github.com/googleapis/google-cloud-ruby/issues/27605)) 
* add MAC address-associated IP address to the Hardware resource 
* add provisioning_state_signal field in SignalZoneState method request 
#### Documentation

* change state_signal field in SignalZoneState method request as optional 

### 0.3.0 (2024-10-29)

#### Features

* add a DeleteSite method ([#27494](https://github.com/googleapis/google-cloud-ruby/issues/27494)) 
* add MAC address and disk info to the Hardware resource 
#### Documentation

* annotate rack_location field as required; this was always enforced 

### 0.2.0 (2024-09-19)

#### Features

* add an order type field to distinguish a fulfillment request from a sales inquiry ([#27333](https://github.com/googleapis/google-cloud-ruby/issues/27333)) 
* add support to mark comments as read or unread 
* rename zone state signal READY_FOR_SITE_TURNUP to FACTORY_TURNUP_CHECKS_PASSED 
#### Documentation

* clarify how access_times are used 

### 0.1.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.1.0 (2024-07-09)

#### Features

* Initial generation of google-cloud-gdc_hardware_management-v1alpha ([#26269](https://github.com/googleapis/google-cloud-ruby/issues/26269)) 

## Release History
