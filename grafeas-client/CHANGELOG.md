# Release History

### 0.3.0 / 2019-10-01

#### Features

* Update VERSION location and constant
  * Move version.rb file so it matches the rubygems conventions.
  * Use Grafeas::Client::VERSION as the new constant.
  * Update previous Grafeas::VERSION constant to use the new constant.

### 0.2.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.2.0 / 2019-07-08

* Support overriding service host and port.
* VulnerabilityNote::Detail changes:
    * BREAKING CHANGE: Remove min_affected_version
    * Add affected_version_start
    * Add affected_version_end
* VulnerabilityOccurrence::PackageIssue changes:
    * Remove min_affected_version
    * Add affected_version

### 0.1.0 / 2019-06-21

* Initial release.
