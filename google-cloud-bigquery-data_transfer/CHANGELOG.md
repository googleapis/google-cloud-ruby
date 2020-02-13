# Release History

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
