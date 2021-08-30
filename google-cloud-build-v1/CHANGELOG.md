# Release History

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
