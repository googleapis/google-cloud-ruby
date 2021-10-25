# Release History

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
