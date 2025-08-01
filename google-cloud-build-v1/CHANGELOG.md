# Release History

### 1.6.1 (2025-07-28)

#### Documentation

* Updated Private Service Connect IP ranges when route_all_traffic is false ([#30731](https://github.com/googleapis/google-cloud-ruby/issues/30731)) 

### 1.6.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.5.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.5.0 (2025-02-13)

#### Features

* Add option to enable fetching dependencies ([#29065](https://github.com/googleapis/google-cloud-ruby/issues/29065)) 
* Support for git proxy setup ([#29072](https://github.com/googleapis/google-cloud-ruby/issues/29072)) 
#### Documentation

* Updates to proto message comments 

### 1.4.0 (2025-01-28)

#### Features

* Support structured logging 
* Support uploading Go modules to Artifact Registry 
* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.3.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.2.0 (2024-10-31)

#### Features

* Add PrivateServiceConnect option to WorkerPool ([#27512](https://github.com/googleapis/google-cloud-ruby/issues/27512)) 

### 1.1.0 (2024-09-30)

#### Features

* Support for legacy bucket behavior ([#27354](https://github.com/googleapis/google-cloud-ruby/issues/27354)) 

### 1.0.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27007](https://github.com/googleapis/google-cloud-ruby/issues/27007)) 

### 1.0.0 (2024-07-08)

#### Features

* Bump version to 1.0.0 

### 0.27.1 (2024-06-05)

#### Documentation

* Fixed product documentation link ([#26045](https://github.com/googleapis/google-cloud-ruby/issues/26045)) 

### 0.27.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24865](https://github.com/googleapis/google-cloud-ruby/issues/24865)) 

### 0.26.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.26.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.26.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23775](https://github.com/googleapis/google-cloud-ruby/issues/23775)) 

### 0.25.0 (2023-11-06)

#### Features

* Add optional field "SourceFetcher" to choose source fetcher tool ([#23504](https://github.com/googleapis/google-cloud-ruby/issues/23504)) 

### 0.24.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.23.0 (2023-08-03)

#### Features

* Add update_mask field to UpdateBuildTriggerRequest ([#22668](https://github.com/googleapis/google-cloud-ruby/issues/22668)) 

### 0.22.0 (2023-07-28)

#### Features

* support automap_substitutions flag 

### 0.21.0 (2023-07-26)

#### Features

* support git_file_source and git_repo_source 
* support github_enterprise_config_path  

### 0.20.0 (2023-07-13)

#### Features

* Support for the UPDATING WorkerPool state 
#### Bug Fixes

* Send location routing headers with RPC calls ([#22516](https://github.com/googleapis/google-cloud-ruby/issues/22516)) 

### 0.19.0 (2023-07-10)

#### Features

* added e2-medium machine type ([#22489](https://github.com/googleapis/google-cloud-ruby/issues/22489)) 

### 0.18.0 (2023-07-07)

#### Features

* add repositoryevent to buildtrigger ([#22461](https://github.com/googleapis/google-cloud-ruby/issues/22461)) 

### 0.17.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified ([#22242](https://github.com/googleapis/google-cloud-ruby/issues/22242)) 

### 0.16.0 (2023-04-21)

#### Features

* Add `peered_network_ip_range` option to `NetworkConfig` ([#21447](https://github.com/googleapis/google-cloud-ruby/issues/21447)) 
* Support locating Git source repo ([#21447](https://github.com/googleapis/google-cloud-ruby/issues/21447)) 
* Support locating NPM packages ([#21447](https://github.com/googleapis/google-cloud-ruby/issues/21447)) 

### 0.15.0 (2023-03-15)

#### Features

* Provide default logging option to BuildOptions ([#20891](https://github.com/googleapis/google-cloud-ruby/issues/20891)) 

### 0.14.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.13.0 (2022-11-01)

#### Features

* Added allow_failure, exit_code, and allow_exit_code fields to BuildStep type ([#19349](https://github.com/googleapis/google-cloud-ruby/issues/19349)) 
* Support for uploading Python packages and Maven artifacts to Artifact Registry ([#19353](https://github.com/googleapis/google-cloud-ruby/issues/19353)) 

### 0.12.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.11.3 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.11.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.11.1 / 2021-10-21

#### Documentation

* Some documentation formatting fixes

### 0.11.0 / 2021-08-30

#### Features

* Support BuildStep#script and BuildTrigger#service_account fields

### 0.10.0 / 2021-08-19

#### Features

* Support for build approval

### 0.9.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.9.1 / 2021-07-29

#### Documentation

* Document the SETUPBUILD key for the build timing field

### 0.9.0 / 2021-07-21

#### Features

* Report build failure type and details
* Update worker pool interfaces to their final form

### 0.8.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.8.0 / 2021-06-30

#### Features

* Standardize resource paths, and support warnings, webhook config, and build config autodetect

#### Bug Fixes

* Fixed an exception when setting credentials using a Hash

### 0.7.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.7.0 / 2021-05-19

#### Features

* Support source manifests

### 0.6.0 / 2021-04-26

#### Features

* Add support for Pub/Sub triggers

### 0.5.0 / 2021-04-05

#### Features

* Support for receive_trigger_webhook and for available secrets in builds

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2020-09-16

#### Features

* Support for standard "name" and "parent" resource path arguments.

### 0.1.3 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.2 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

#### Documentation

* Fix documented format of BuildOptions#worker_pool

### 0.1.1 / 2020-07-21

#### Bug Fixes

* Fixed timeout and retry configuration for worker pool calls

### 0.1.0 / 2020-06-25

Initial release.
