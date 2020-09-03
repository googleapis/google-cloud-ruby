# Release History

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
