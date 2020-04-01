# Release History

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
