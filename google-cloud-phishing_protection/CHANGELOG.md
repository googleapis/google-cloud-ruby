# Release History

### 0.10.0 / 2020-06-01

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.5.0 / 2020-04-08

#### Features

* Move data type classes from Phishingprotection to PhishingProtection.
  * Note: Phishingprotection was left as an alias, so older code should still work.

### 0.4.1 / 2020-04-01

#### Documentation

* Fixed a number of broken links.

### 0.4.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.3.2 / 2020-01-23

#### Documentation

* Update copyright year

### 0.3.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.3.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.2.2 / 2019-10-01

#### Documentation

* Minor updates to documentation

### 0.2.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.2.0 / 2019-07-08

* Support overriding service host and port.

### 0.1.1 / 2019-06-11

* Add VERSION constant

### 0.1.0 / 2019-04-25

* Initial release
