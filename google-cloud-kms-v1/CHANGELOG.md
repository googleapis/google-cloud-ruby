# Release History

### 0.10.2 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.10.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.10.0 / 2021-10-21

#### Features

* Support for raw PKCS1 signing keys

### 0.9.0 / 2021-10-18

#### Features

* Added OAEP+SHA1 to the list of supported algorithms
* Support RSA encrypt with SHA-1 digest

### 0.8.0 / 2021-09-02

#### Features

* Ability to target an existing crypto_key_version for import

### 0.7.0 / 2021-08-11

#### Features

* Support for signing and verifying MAC tags
  * Support for the mac_sign call
  * Support for the mac_verify call
  * Support for the generate_random_bytes call
  * Support the import_only and destroy_scheduled_duration fields of CryptoKey
  * Support the protection_level field of PublicKey

#### Bug Fixes

* Honor client-level timeout configuration

### 0.6.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.6.1 / 2021-07-08

#### Bug Fixes

* Removed a proto file that is duplicated from the iam-v1 gem

### 0.6.0 / 2021-06-17

#### Features

* Add ECDSA secp256k1 to the list of supported algorithms

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.1 / 2021-02-16

#### Bug Fixes

* No longer retry on internal backend errors

### 0.4.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.3.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.0 / 2020-09-03

#### Features

* Support for client integrity verification fields

### 0.2.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.3 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.2 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.2.1 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fixed broken links in the reference documentation

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
