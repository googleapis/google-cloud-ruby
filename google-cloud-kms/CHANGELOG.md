# Release History

### 2.2.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 2.2.0 / 2021-11-09

#### Features

* Add a factory method for the IAM client

### 2.1.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 2.1.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 2.1.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 2.0.2 / 2021-02-03

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 2.0.1 / 2021-01-18

#### Documentation

* Timeout config description correctly gives the units as seconds

### 2.0.0 / 2020-06-01

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 1.6.0 / 2020-04-08

#### Features

* Support additional options for external protection level.

### 1.5.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 1.5.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 1.4.1 / 2020-01-23

#### Documentation

* Update copyright year

### 1.4.0 / 2020-01-07

#### Features

* Add ProtectionLevel::EXTERNAL
  * Update documentation

### 1.3.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 1.3.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 1.2.1 / 2019-08-23

#### Performance Improvements

* Update network configuration for many RPCs to retryable

#### Documentation

* Update documentation

### 1.2.0 / 2019-07-08

* Add IAM GetPolicyOptions.
* Support overriding service host and port.

### 1.1.0 / 2019-06-17

* KeyManagementServiceClient  changes:
  * Added methods
    * create_import_job
    * get_import_job
    * list_import_jobs
    * import_crypto_key_version
  * Argument changes
    * Add filter and order_by arguments to:
      * list_key_rings
      * list_crypto_keys
      * list_crypto_key_versions
    * Add skip_initial_version_creation argument to create_crypto_key
* CryptoKeyVersion changes:
  * Add CryptoKeyVersionAlgorithm constants:
    * RSA_SIGN_PSS_4096_SHA512
    * RSA_SIGN_PKCS1_4096_SHA512
    * RSA_DECRYPT_OAEP_4096_SHA512
  * Add CryptoKeyVersionState constants:
    * PENDING_IMPORT
    * IMPORT_FAILED
* Add import_job_path helper method
* Update documentation

### 1.0.2 / 2019-06-11

* Update IAM Policy documentation.
* Add VERSION constant.

### 1.0.1 / 2019-04-29

* Update RPC retry configuration.
* Add AUTHENTICATION.md guide.
* Update documentation for common types.
* Update generated code examples.

### 1.0.0 / 2019-03-11

* Bump release level to GA.
* Support Cavium V2 compression.
* Add example to readme.

### 0.3.0 / 2019-02-07

* Move library to Beta.

### 0.2.5 / 2018-12-13

* Alias the following KeyManagementServiceClient class methods to instance methods.
  * crypto_key_version_path
  * key_ring_path
  * crypto_key_path_path
  * crypto_key_path
  * location_path

### 0.2.4 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.3 / 2018-09-12

* Add Assymetric Sign/Decrypt.
* Add CryptoKeyVersion template and view classes.
* Add KeyOperationAttestation.

### 0.2.2 / 2018-09-10

* Update documentation.

### 0.2.1 / 2018-08-21

* Update documentation.

### 0.2.0 / 2018-07-09

* Minor rework to how requests are nested.

### 0.1.0 / 2018-07-06

* Initial release
