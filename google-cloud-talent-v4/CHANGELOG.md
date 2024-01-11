# Release History

### 0.12.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23787](https://github.com/googleapis/google-cloud-ruby/issues/23787)) 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22924](https://github.com/googleapis/google-cloud-ruby/issues/22924)) 

### 0.10.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.10.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21679](https://github.com/googleapis/google-cloud-ruby/issues/21679)) 
* Add three per company option to diversification levels ([#21904](https://github.com/googleapis/google-cloud-ruby/issues/21904)) 

### 0.9.1 (2023-05-04)

#### Bug Fixes

* Fixed timeout settings for search_jobs_for_alert 

### 0.9.0 (2023-03-08)

#### Features

* Support REST transport ([#20629](https://github.com/googleapis/google-cloud-ruby/issues/20629)) 

### 0.8.1 (2022-11-09)

#### Documentation

* mark company_size and keyword_searchable_job_custom_attributes deprecated 

### 0.8.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.7.0 (2022-05-26)

#### Features

* update TelecommutePreference filter to add TELECOMMUTE_JOBS_EXCLUDED filter option

### 0.6.4 / 2022-03-30

#### Documentation

* Document fuzzy matching in company_display_names

### 0.6.3 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.6.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.6.1 / 2021-11-02

#### Documentation

* Formatting fixes in the reference documentation

### 0.6.0 / 2021-09-21

#### Features

* Replaced disable_keyword_match with keyword_match_mode in the search_jobs call

### 0.5.0 / 2021-08-19

#### Features

* Support for additional commute methods

### 0.4.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.4.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2020-10-05

#### ⚠ BREAKING CHANGES

* Removed walking and cycling commute methods

### 0.1.0 / 2020-09-18

Initial release.
