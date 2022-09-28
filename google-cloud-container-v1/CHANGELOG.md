# Release History

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
