# Release History

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
