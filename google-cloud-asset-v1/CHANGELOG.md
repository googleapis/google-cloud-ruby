# Release History

### 0.29.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.29.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23773](https://github.com/googleapis/google-cloud-ruby/issues/23773)) 

### 0.28.1 (2024-01-09)

#### Documentation

* Various documentation updates ([#23709](https://github.com/googleapis/google-cloud-ruby/issues/23709)) 

### 0.28.0 (2024-01-04)

#### Features

* Support for directly attached and effective tags ([#23370](https://github.com/googleapis/google-cloud-ruby/issues/23370)) 
* Support for Security Command Center security marks 

### 0.27.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.26.1 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.26.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.25.0 (2023-04-09)

#### Features

* Add client library support for AssetService v1 AnalyzeOrgPolicies API ([#21045](https://github.com/googleapis/google-cloud-ruby/issues/21045)) 

### 0.24.0 (2023-03-08)

#### Features

* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 

### 0.23.0 (2023-01-15)

#### Features

* Added support for RPCs for analyzing org policies ([#20015](https://github.com/googleapis/google-cloud-ruby/issues/20015)) 

### 0.22.0 (2022-10-18)

#### Features

* Added new searchable field "kms_keys", deprecating old field "kms_key" ([#19264](https://github.com/googleapis/google-cloud-ruby/issues/19264)) 

### 0.21.1 (2022-09-28)

#### Bug Fixes

* Configured timeouts and retry policies for saved query calls ([#19201](https://github.com/googleapis/google-cloud-ruby/issues/19201)) 

### 0.21.0 (2022-08-17)

#### Features

* Support for asset query system ([#19014](https://github.com/googleapis/google-cloud-ruby/issues/19014)) 
#### Bug Fixes

* Configure timeouts and retries for batch_get_effective_iam_policies ([#19025](https://github.com/googleapis/google-cloud-ruby/issues/19025)) 

### 0.20.1 (2022-08-14)

#### Bug Fixes

* Update timeout and retry settings for batch_get_effective_iam_policies ([#18997](https://github.com/googleapis/google-cloud-ruby/issues/18997)) 
#### Documentation

* Document relationship clauses in search queries 

### 0.20.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.19.0 (2022-06-08)

#### Features

* Added a call to get effective IAM policies for a batch of resources
* Added relationship_type field to RelatedAsset
* Added support for saved analysis queries
* Added tag key and value fields to search results
* Deprecated Asset#related_assets and replaced with Asset#related_asset

### 0.18.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.17.3 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.17.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.17.1 / 2021-09-24

#### Bug Fixes

* Depend on the existing access_context_manager and os_config clients rather than copying their classes into the asset client

### 0.17.0 / 2021-09-07

#### Features

* Support for OsConfig inventory name and update time
* Support for relationships in resource search results

### 0.16.0 / 2021-08-31

#### Features

* Support Windows applications in the software package inventory

### 0.15.0 / 2021-08-19

#### Features

* Support for related assets and asset relationship information

### 0.14.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.14.0 / 2021-07-29

#### Features

* Support for analyze_move.
* Support for read masks in search_all_resources.
* Returned versioned resources and attached resources from searches.
* Support ingress and egress policies in the AccessContextManager service perimeter config

### 0.13.1 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 0.13.0 / 2021-06-29

#### Features

* Support ordering and asset type filtering in search_all_iam_policies

### 0.12.0 / 2021-06-17

#### Features

* Support list_assets call, and add a number of additional fields to ResourceSearchResult

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.11.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.10.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.9.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.9.0 / 2020-12-07

#### Features

* Support for runtime OS inventory information

### 0.8.0 / 2020-11-02

#### Features

* Support analyze_iam_policy call

### 0.7.0 / 2020-09-17

#### Features

* Support per type and partition export

### 0.6.1 / 2020-09-10

#### Bug Fixes

* Remove analyze_iam_policy and export_iam_policy_analysis methods. These are not yet working, and were exposed in the client by mistake.

### 0.6.0 / 2020-09-03

#### Features

* Added ExportAssetsResponse#output_result
* Added support for analyze_iam_policy and export_iam_policy_analysis

### 0.5.3 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.5.2 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.5.1 / 2020-06-25

#### Bug Fixes

* Update timeouts and retry settings for feed-related calls

### 0.5.0 / 2020-06-18

#### Features

* Support for real-time notification conditions

### 0.4.3 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.4.2 / 2020-05-27

#### Documentation

* Properly format some literal strings

### 0.4.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.4.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.3.0 / 2020-05-18

#### Features

* Support search_all_resources and search_all_iam_policies methods

### 0.2.3 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.2.2 / 2020-04-22

#### Bug Fixes

* Operations client honors its main client's custom endpoint.

### 0.2.1 / 2020-04-13

* Update docs for IAM Policy data types.
* Expanded the readme to include quickstart and logging information.
* Added documentation for package and service modules.
* Fixed and expanded documentation for the two method calling conventions.
* Fixed some circular require warnings.

### 0.2.0 / 2020-04-01

#### Features

* Support for Asset org policy and access context.

### 0.1.0 / 2020-03-25

Initial release.
