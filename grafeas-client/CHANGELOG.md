# Release History

### 0.4.0 / 2019-10-29

#### Features

* Rename grafeas gem
  * Rename grafeas gem from grafeas-client
  * Create new grafeas-client gem that depends on grafeas
  * Update google-cloud-container_analysis to use grafeas
* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))

### 0.3.0 / 2019-10-01

#### Cleanup

* Update VERSION location and constant to match rubygems conventions.

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
