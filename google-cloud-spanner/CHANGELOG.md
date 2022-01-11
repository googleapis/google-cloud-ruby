# Release History

### 2.12.0 / 2022-01-11

No significant changes.

### 2.11.0 / 2021-12-10

#### Features

* add admin instance wrapper.
* Updated benchwrapper and proto for spanner.
* use gRPC clients for instance/database management.
* wrapper to create generated admin database client.

### 2.10.1 / 2021-11-09

#### Documentation

* Add documentation for quota_project Configuration attribute

### 2.10.0 / 2021-08-24

#### Features

* add field JSON type support

### 2.9.0 / 2021-07-26

#### Features

* support request tagging

### 2.8.1 / 2021-07-08

#### Documentation

* Update AUTHENTICATION.md in handwritten packages

### 2.8.0 / 2021-06-17

#### Features

* create instance using processing units/node count

### 2.7.0 / 2021-06-09

#### Features

* add the support of optimizer statistics package
* database create time access method 
* RPC priority request option.

#### Bug Fixes

* extract binary retry info from error

### 2.6.0 / 2021-03-31

#### Features

* add cmek backup support
* add cmek db support

### 2.5.0 / 2021-03-10

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 2.4.0 / 2021-02-18

#### Features

* Point In Time Recovery (PITR)

### 2.3.0 / 2021-02-09

#### Features

* CommitStats in CommitResponse
* optionalize `credentials` when using cloud spanner emulator host

### 2.2.0 / 2020-09-15

#### Features

* quota_project can be set via library configuration
* Support numeric type.

#### Bug Fixes

* retry or resume eos and rst_stream errors

### 2.1.0 / 2020-08-05

#### Features

* Support custom setting of timeout and retry

### 2.0.0 / 2020-07-23

This is a major update that removes the "low-level" client interface code, and
instead adds `google-cloud-spanner-v1`, `google-cloud-spanner-admin-database-v1`,
and `google-cloud-spanner-admin-instance-v1` as dependencies.
The new dependencies are rewritten low-level clients, produced by a next-
generation client code generator, with improved performance and stability.

This change should have no effect on the high-level interface that most users
will use. The one exception is that the (mostly undocumented) `client_config`
argument, for adjusting low-level parameters such as RPC retry settings on
client objects, has been removed. If you need to adjust these parameters, use
the configuration interface in low-level clients.

Substantial changes have been made in the low-level interfaces, however. If you
are using the low-level classes under the old `Google::Spanner::V1` module,
please review the docs for the new `google-cloud-spanner-v1` gem. In particular:

* Some classes have been renamed, notably the client class itself.
* The client constructor takes a configuration block instead of configuration
  keyword arguments.
* All RPC method arguments are now keyword arguments.

### 1.16.2 / 2020-05-28

#### Documentation

* Fix a few broken links

### 1.16.1 / 2020-05-21

#### Bug Fixes

* Increased default timeouts to match clients in other languages
* Run system tests against the emulator, skipping those not supported by the emulator
* Do not require a key file when running against the emulator

### 1.16.0 / 2020-03-20

#### Features

* Added support for backing up and restoring databases

### 1.15.0 / 2020-03-15

#### Features

* Added support for query options
* Support separate project setting for quota/billing

### 1.14.0 / 2020-02-18

#### Features

* allow custom lib name and version for telemetry purpose

### 1.13.1 / 2020-01-22

#### Documentation

* fix incorrect doc links in CONTRIBUTING.md
* Update copyright year
* Update Status documentation

### 1.13.0 / 2020-01-08

#### Features

* Add support for SPANNER_EMULATOR_HOST

### 1.12.2 / 2019-12-19

#### Bug Fixes

* Rename endpoint_urls to endpoint_uris
* Revert #commit mutations to positional in lower-level API
* Revert breaking change to test_iam_permissions in lower-level API

#### Performance Improvements

* Add Instance#endpoint_urls and GetInstanceRequest#field_mask in lower-level API
* Add service address and port for lower-level API clients

### 1.12.1 / 2019-11-12

#### Features

* Add InstanceConfig#replicas (ReplicaInfo) to the lower-level API.

#### Documentation

* Update lower-level API documentation.

#### Bug Fixes

* Update minimum runtime dependencies.

### 1.12.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform environments support automatic authentication

### 1.11.0 / 2019-10-07

#### BREAKING CHANGES (LOWER-LEVEL API ONLY)

* Make the session_count argument required in the lower-level API batch_create_sessions call

#### Performance Improvements

* Update Pool#init to use BatchCreateSessions
  * Update pool checkout to pop sessions for LIFO

#### Documentation

* Update Policy example code
* Update IAM Policy class description and sample code

### 1.10.1 / 2019-09-04

#### Documentation

* Update low-level IAM documentation
  * Update GetPolicyOption#requested_policy_version docs
  * Un-deprecate Policy#version

### 1.10.0 / 2019-08-23

#### Features

* Add Batch Create Sessions to low-level API
  * Add SpannerClient#batch_create_sessions
  * Add BatchCreateSessionsRequest
  * Add BatchCreateSessionsResponse
* Support overriding of service endpoint

#### Bug Fixes

* Low-level admin clients now honor service_address and service_port

#### Documentation

* Update documentation

### 1.9.5 / 2019-07-31

* Reduce thread usage at startup
  * Allocate threads in pool as needed, not all up front
* Update documentation links

### 1.9.4 / 2019-07-08

* Add IAM GetPolicyOptions in the lower-level API.
* Support overriding service host and port in the lower-level interface.

### 1.9.3 / 2019-06-27

* Update network configuration for some initial_retry_delay_millis
  and timeout_millis settings

### 1.9.2 / 2019-06-13

* Update IAM:
  * Deprecate Policy#version
  * Add Binding#condition
  * Add Google::Type::Expr
  * Update documentation
* Update retry configuration
* Use VERSION constant in GAPIC client

### 1.9.1 / 2019-04-30

* Fix Spanner session limit bug.
* Update AUTHENTICATION.md guide.
* Update documentation for common types.
* Update generated documentation.
* Extract gRPC header values from request.

### 1.9.0 / 2019-03-08

* Spanner Batch DML.
  * Add Transaction#batch_update.
  * Add BatchUpdate.
  * Add BatchUpdateError.
  * Add SpannerClient#execute_batch_dml.

### 1.8.0 / 2019-02-01

* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.
* Performance improvements for Data#to_h
  * Add Data skip_dup_check optional arg
    * This enhancement allows users to skip the dupplicate name check
      when serializing Data to a Ruby Hash or Array.
      This speeds up the serialization, but data may be lost.
* Update network configuration
* Update Client#close to block on session release

### 1.7.2 / 2018-11-15

* Allow Spanner streams to recover from more errors.

### 1.7.1 / 2018-10-08

* Add DML and Partitioned DML support
  * Add execute_update to process DML statements
  * Add execute_partition_update for Partitioned DML
* Rename execute_query method
  * Maintain naming consistency with execute_update method.
  * Maintain compatibility by adding query, execute and execute_sql aliases.

### 1.6.4 / 2018-09-20

* Update Spanner generated files.
  * Add DML/PDML code structures.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 1.6.3 / 2018-09-12

* Add missing documentation files to package.

### 1.6.2 / 2018-09-10

* Update documentation.

### 1.6.1 / 2018-08-21

* Update documentation.

### 1.6.0 / 2018-06-28

* Add Session labels
  * Add labels optional argument to Project#client and #batch_client.
  * Add labels optional argument to Project#batch_client.
* Bug fix when an error is raised while returning results.

### 1.5.0 / 2018-06-12

* Support STRUCT values in query parameters.
  * Add `Fields#struct` to create a `Data` object.
* Documentation updates.

### 1.4.0 / 2018-03-26

* Add support for commit_timestamp.

### 1.3.1 / 2018-02-27

* Add Batch Client
  * Support partitioned reads and queries.
* Support Shared Configuration.
* Fix issue with IAM Policy not refreshing properly.
* Fix issue when using Time objects as keys.

### 1.2.0 / 2017-12-19

* Update Low Level API code
  * Remove deprecated constructor arguments.
  * Update documentation.
* Update google-gax dependency to 1.0.

### 1.1.1 / 2017-11-15

* Fix Admin Credentials (GAPIC) environment variable names.

### 1.1.0 / 2017-11-14

* Add `Google::Cloud::Spanner::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Update generated low level GAPIC code.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 1.0.0 / 2017-09-29

* Release 1.0

### 0.23.2 / 2017-09-12

* Update connection configuration.

### 0.23.1 / 2017-08-18

* Update connection configuration.

### 0.23.0 / 2017-07-27

* Add `Job#error` returning `Spanner::Status`.

### 0.22.0 / 2017-07-11

* Remove `Policy#deep_dup`.
* Add thread pool size to `Session` pool configuration.
* Add error handling for some GRPC errors.
* Do not allow nested snapshots or transactions.
* Update initialization to raise a better error if project ID is not specified.
* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update example code in the API documentation and guide.

### 0.21.0 / 2017-06-08

Initial implementation of the Google Cloud Spanner API Ruby client.
