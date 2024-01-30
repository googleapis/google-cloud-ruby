# Release History

### 1.3.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24271](https://github.com/googleapis/google-cloud-ruby/issues/24271)) 

### 1.2.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.1.2 / 2022-01-11

#### Documentation

* Fix titles of documentation pages

### 1.1.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.1.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.0.1 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.0.0 / 2020-06-17

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Generic defaults do not default to Google's implementation. (Use the google-cloud-container_analysis gem for a Google-specific client.)
* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.3.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 0.3.0 / 2020-03-11

#### Features

* support separate project setting for quota/billing

### 0.2.1 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 0.2.0 / 2020-01-15

#### Features

* Add Upgrade types and attributes
  * Add UpgradeNote
  * Add UpgradeDistribution
  * Add WindowsUpdate
  * Add UpgradeOccurrence
  * Add NoteKind::UPGRADE
  * Add DiscoveryOccurrence#cpe
  * Add DiscoveryOccurrence#last_scan_time
  * Add Note#upgrade
  * Add Occurrence#upgrade
  * Add VulnerabilityNote#source_update_time
  * Add VulnerabilityNote::Detail#source_update_time

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
