# Release History

### 0.32.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22923](https://github.com/googleapis/google-cloud-ruby/issues/22923)) 

### 0.31.1 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.31.0 (2023-06-27)

#### Features

* Mark the Asset APIs as deprecated in client libraries ([#22448](https://github.com/googleapis/google-cloud-ruby/issues/22448)) 

### 0.30.0 (2023-06-16)

#### Features

* Add user agent and DLP parent type fields to finding's list of attributes ([#22380](https://github.com/googleapis/google-cloud-ruby/issues/22380)) 

### 0.29.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.29.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 

### 0.28.0 (2023-04-23)

#### Features

* Add DlpDataProfile & DlpInspection options to Finding ([#21461](https://github.com/googleapis/google-cloud-ruby/issues/21461)) 
#### Documentation

* Improve documentation ([#21461](https://github.com/googleapis/google-cloud-ruby/issues/21461)) 

### 0.27.0 (2023-04-12)

#### Features

* support security health analytics custom module 

### 0.26.0 (2023-03-08)

#### Features

* Support REST transport ([#20629](https://github.com/googleapis/google-cloud-ruby/issues/20629)) 

### 0.25.1 (2023-01-15)

#### Documentation

* Clarify some resource name formats ([#20012](https://github.com/googleapis/google-cloud-ruby/issues/20012)) 

### 0.25.0 (2022-12-14)

#### Features

* Added user name field to finding Access resource ([#19860](https://github.com/googleapis/google-cloud-ruby/issues/19860)) 

### 0.24.0 (2022-12-09)

#### Features

* Added kernel_rootkit field to Finding ([#19802](https://github.com/googleapis/google-cloud-ruby/issues/19802)) 

### 0.23.0 (2022-11-15)

#### Features

* add files to finding and :DEFAULT_ACCOUNT to mitre_attack technique 
* support service publishing and client libraries settings 

### 0.22.0 (2022-10-19)

#### Features

* Support for folder and project based notification config paths ([#19291](https://github.com/googleapis/google-cloud-ruby/issues/19291)) 

### 0.21.0 (2022-09-16)

#### Features

* Support for the source display name of a finding ([#19162](https://github.com/googleapis/google-cloud-ruby/issues/19162)) 

### 0.20.0 (2022-08-25)

#### Features

* Added attributes providing context about the principals associated with a finding ([#19069](https://github.com/googleapis/google-cloud-ruby/issues/19069)) 

### 0.19.0 (2022-08-24)

#### Features

* added ACCESS_TOKEN_MANIPULATION and ABUSE_ELEVATION_CONTROL_MECHANISM mitre attack techniques 
* Added database information to Findings ([#19055](https://github.com/googleapis/google-cloud-ruby/issues/19055)) 
* added uris field to indicator of compromise ([#19038](https://github.com/googleapis/google-cloud-ruby/issues/19038)) 

### 0.18.0 (2022-07-25)

#### Features

* Return containers and kubernetes resources associated with a finding ([#18851](https://github.com/googleapis/google-cloud-ruby/issues/18851)) 

### 0.17.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
* Added contacts field to findings attributes 
* Added process signature fields to the indicator attribute 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.16.0 (2022-06-08)

#### Features

* Add compliances, processes and exfiltration fields to findings attributes

### 0.15.0 (2022-04-20)

#### Features

* add new fields connection and description to finding

### 0.14.0 (2022-04-14)

#### Features

* Support for update masks when setting IAM policies
* Added IAM bindings and next steps to Findings
* Added two new Mitre Attack techniques
* Update grpc-google-iam-v1 dependency to 1.1

### 0.13.0 / 2022-03-03

#### Features

* Add CRUD operation of BigQueryExport

### 0.12.1 / 2022-02-20

#### Documentation

* Minor updates to reference documentation

### 0.12.0 / 2022-02-16

#### Features

* Add access details to the Finding type

### 0.11.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.11.0 / 2021-12-07

#### Features

* Support for mute configs
* Support for updating a finding with external system metadata

#### Documentation

* Formatting fixes in the reference docs

### 0.10.0 / 2021-11-11

#### Features

* Added fields display_name and resource type.

### 0.9.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.9.0 / 2021-10-18

#### Features

* Added vulnerability fields to findings

### 0.8.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.8.0 / 2021-07-29

#### Features

* Added class and indicator fields to security findings

### 0.7.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

#### Documentation

* Update currently supported Finding filter fields

### 0.7.0 / 2021-05-18

#### Features

* Support for folder information and asset canonical names

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.5.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.4.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.4.0 / 2020-12-15

#### Features

* Add field indicating severity of a finding

### 0.3.5 / 2020-09-03

#### Documentation

* Clarify Finding#event_time description

### 0.3.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.3.3 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.3.2 / 2020-07-16

#### Bug Fixes

* Update timeout settings

### 0.3.1 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.3.0 / 2020-06-12

#### Features

* Provide resource information in notifications.

### 0.2.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.2.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
