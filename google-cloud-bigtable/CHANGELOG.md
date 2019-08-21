# Release History

### 0.6.0 / 2019-08-21

#### Features

* Update documentation
* Support overriding of the service endpoint

### 0.5.0 / 2019-08-05

* Accept nil gc_rule arguments for column_family create/update
* Update documentation

### 0.4.3 / 2019-07-12

* Update #to_hash to #to_h for compatibility with google-protobuf >= 3.9.0

### 0.4.2 / 2019-07-09

* Add IAM GetPolicyOptions in the lower-level interface.
* Custom metadata headers are honored by long running operations calls.
* Support overriding service host and port in the lower-level interface.

### 0.4.1 / 2019-06-11

* Enable grpc.service_config_disable_resolution
* Add VERSION constant

### 0.4.0 / 2019-05-21

* Add Google::Cloud::Bigtable::VERSION
* Set gRPC headers to allow maximum message size
* Fix errors in code sample documentation

### 0.3.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.
* Extract gRPC header values from request.

### 0.3.0 / 2019-02-01

* Move library to Beta.
* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.

### 0.2.0 / 2018-11-15

* Update network configuration.
* Allow the emulator host to be provided in the BIGTABLE_EMULATOR_HOST
  environment variable, or the emulator_host argument.
* Add EMULATOR guide to show how to configure and use the emulator.
* Update documentation.

### 0.1.3 / 2018-09-20

* Update connectivity configuration.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.1.2 / 2018-09-12

* Add missing documentation files to package.

### 0.1.1 / 2018-09-10

* Update documentation.

### 0.1.0 / 2018-08-16

* Initial release
