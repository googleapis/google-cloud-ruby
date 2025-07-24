# Changelog

### 1.3.0 (2025-07-15)

#### Features

* Support for File operations 
* Support for various additional Finding fields 

### 1.2.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.1.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.1.0 (2025-02-19)

#### Features

* Added data access events, data flow events, data retention deletion events, and associated disk to the Finding resource 
* Added earliest known exploitation date to the Cvs resource 
* Renamed volume_pps and volume_bps to volume_pps_long and volume_bps_long, respectively, in the Attack resource, and deprecated the old fields 
* Support Azure Entra tenant 

### 1.0.0 (2025-02-11)

#### Features

* Bump version to 1.0.0 ([#28969](https://github.com/googleapis/google-cloud-ruby/issues/28969)) 

### 0.6.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.5.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.4.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27012](https://github.com/googleapis/google-cloud-ruby/issues/27012)) 

### 0.4.0 (2024-08-05)

#### Features

* Support for mute state and dynamic mute ([#26566](https://github.com/googleapis/google-cloud-ruby/issues/26566)) 
#### Documentation

* Various fixes to reference documentation formatting and links 

### 0.3.0 (2024-06-28)

#### Features

* Added cloud provider field to list findings response ([#26242](https://github.com/googleapis/google-cloud-ruby/issues/26242)) 
* Added http configuration rule to ResourceValueConfig and ValuedResource API methods 
* Added toxic combination field to finding 
#### Documentation

* Updated comments for ResourceValueConfig 

### 0.2.0 (2024-06-26)

#### Features

* Add toxic_combination and group_memberships fields to finding ([#26170](https://github.com/googleapis/google-cloud-ruby/issues/26170)) 

### 0.1.0 (2024-04-19)

#### Features

* Initial generation of google-cloud-security_center-v2 ([#25738](https://github.com/googleapis/google-cloud-ruby/issues/25738)) 

## Release History
