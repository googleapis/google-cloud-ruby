# Release History

### 1.2.4 / 2022-01-20

#### Documentation

* Updating reference documentation

### 1.2.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.2.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.1.2 / 2021-02-03

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.1 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

#### Documentation

*  Update BigQuery Data Transfer Service product name

### 1.0.0 / 2020-05-06

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.
* More consistent spelling of module names.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.9.0 / 2020-04-09

#### Features

* Move data type classes from Bigquery::Datatransfer to Bigquery::DataTransfer.
  * Note: Datatransfer was left as an alias, so older code should still work.

### 0.8.0 / 2020-04-01

#### Features

* Support FIRST_PARTY_OAUTH for data sources.

### 0.7.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.6.0 / 2020-02-13

#### Features

* Deprecate multi-pattern resource path helpers
  * Update network configuration

### 0.5.1 / 2020-01-22

#### Documentation

* Update copyright year
* Update Status documentation

### 0.5.0 / 2019-12-19

#### Features

* Update TransferConfig attributes
  * Add TransferConfig#notification_pubsub_topic
  * Add TransferConfig#email_preferences (EmailPreferences)
  * Add TransferRun#notification_pubsub_topic
  * Add TransferRun#email_preferences (EmailPreferences)
  * Add CreateTransferConfigRequest#service_account_name
  * Add UpdateTransferConfigRequest#service_account_name

### 0.4.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.4.0 / 2019-10-29

* This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.3.1 / 2019-10-03

#### Documentation

* Update library description and mark several fields as required

### 0.3.0 / 2019-08-23

#### Features

* Add StartManualTransferRuns
  * DataTransferServiceClient changes:
    * Add DataTransferServiceClient#start_manual_transfer_runs
    * Deprecate DataTransferServiceClient#schedule_transfer_runs
    * Add version_info argument to DataTransferServiceClient#create_transfer_config
    * Add version_info argument to DataTransferServiceClient#update_transfer_config
  * DataSourceParameter changes:
    * Add DataSourceParameter#deprecated attribute
    * Deprecate DataSourceParameter#repeated attribute
    * Deprecate DataSourceParameter#fields attribute
    * Deprecate DataSourceParameter::Type::RECORD value
  * TransferConfig changes:
    * Deprecate TransferConfig#schedule_options
    * Deprecate TransferConfig#user_id
  * TransferRun changes:
    * Deprecate TransferRun#user_id
* Add location path helpers
* Add service_address and service_port to client constructor

#### Documentation

* Update documentation

### 0.2.5 / 2019-06-11

* Add VERSION constant

### 0.2.4 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.
* Extract gRPC header values from request.

### 0.2.3 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.2 / 2018-09-10

* Update documentation.

### 0.2.1 / 2018-08-21

* Update documentation.

### 0.2.0 / 2018-08-02

* Update google-gax dependency to version 1.3
* Credentials env_vars change

### 0.1.0 / 2018-03-14

* Initial release
