# Release History

### 0.1.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.1.0 / 2019-10-24

* Renamed gem from grafeas-client to grafeas.
* Now requires Ruby 2.4 or later.

### grafeas-client 0.3.0 / 2019-10-01

* Update VERSION location and constant to match rubygems conventions.

### grafeas-client 0.2.1 / 2019-08-23

* Update documentation

### grafeas-client 0.2.0 / 2019-07-08

* Support overriding service host and port.
* VulnerabilityNote::Detail changes:
    * BREAKING CHANGE: Remove min_affected_version
    * Add affected_version_start
    * Add affected_version_end
* VulnerabilityOccurrence::PackageIssue changes:
    * Remove min_affected_version
    * Add affected_version

### grafeas-client 0.1.0 / 2019-06-21

* Initial release.
