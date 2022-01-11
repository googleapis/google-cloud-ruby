# Release History

### 1.2.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.2.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.1.4 / 2021-02-03

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.3 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.2 / 2020-09-03

Version bump; no significant changes.

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-06

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.10.0 / 2020-04-01

#### Features

* Provide a path helper for the security_marks resource.

### 0.9.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.8.0 / 2020-03-04

#### Features

* Add NotificationConfig
  * Add SecurityCenter#create_notification_config
  * Add SecurityCenter#delete_notification_config
  * Add SecurityCenter#get_notification_config
  * Add SecurityCenter#list_notification_configs
  * Add SecurityCenter#update_notification_config

### 0.7.0 / 2020-03-02

#### ⚠ BREAKING CHANGES

* **security_center:** Remove unused resource path helpers

#### Bug Fixes

* Remove unused resource path helpers

### 0.6.0 / 2020-02-10

#### Features

* add support for v1p1beta1

### 0.5.1 / 2020-01-23

#### Bug Fixes

* Add missing require

#### Documentation

* Update copyright year
* Update Status documentation

### 0.5.0 / 2019-12-20

#### Features

* Add attributes to SecurityCenterProperties and ListFindingsResult
  * Add SecurityCenterProperties#resource_display_name
  * Add SecurityCenterProperties#resource_parent_display_name
  * Add SecurityCenterProperties#resource_project_display_name
  * Add ListFindingsResult#resource (Resource)
  * Update network configuration

### 0.4.3 / 2019-12-19

#### Documentation

* Update in-code samples

### 0.4.2 / 2019-11-19

#### Documentation

* Update IAM Policy documentation

### 0.4.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.4.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.3.3 / 2019-10-01

#### Documentation

* Fix role string in IAM Policy JSON example
* Update IAM Policy class description and sample code

### 0.3.2 / 2019-09-04

#### Documentation

* Update IAM documentation
  * Update GetPolicyOption#requested_policy_version docs
  * Un-deprecate Policy#version

### 0.3.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.3.0 / 2019-07-08

* Add IAM GetPolicyOptions.
* Support overriding service host and port.
* Explicitly require all protobuf classes.

### 0.2.1 / 2019-06-11

* Update IAM:
  * Deprecate Policy#version
  * Add Binding#condition
  * Add Google::Type::Expr
  * Update documentation
* Add VERSION constant

### 0.2.0 / 2019-05-06

* Update SecurityCenterClient#run_asset_discovery response value.
  * The long running Operation response type has been updated to
    RunAssetDiscoveryResponse instead of Google::Protobuf::Empty.
* Add RunAssetDiscoveryResponse.

### 0.1.1 / 2019-04-29

* Add AUTHENTICATION.md guide.

### 0.1.0 / 2019-04-25

* Initial release.
