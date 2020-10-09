# Release History

### 3.0.0 / 2020-10-09

#### ⚠ BREAKING CHANGES

* **bigtable:** Raise Google::Cloud::Error from Table#mutate_row and similar methods

#### Features

* Accept nil gc_rule arguments for column_family create/update
* Add service_address and service_port to client constructor
* Add Table-level IAM Policy support
* Raise Google::Cloud::Error from Table#mutate_row and similar methods
  * Refactor Table#client usages to Table#service.
  * Add the following methods to Service: read_rows, sample_row_keys, mutate_row,
    mutate_rows, check_and_mutate_row, and read_modify_write_row.
  * Remove duplicate module method definition MutationOperations#sample_row_keys.
  * Update acceptance and unit tests to expect Google::Cloud::Error.
* Support overriding of the service endpoint
* Support separate project setting for quota/billing
* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))

#### Bug Fixes

* Update GcRule#max_age to microsecond precision
* Update minimum runtime dependencies
* Update #to_hash to #to_h to fix for protobuf 3.9.0

#### Performance Improvements

* Update retry config in lower-level client

#### Documentation

* add doctest coverage and update sample code
* Add OVERVIEW guide with samples
* Add sample to README.md
* Correct error in lower-level API Table IAM documentation
* Fix role string in low-level IAM Policy JSON example
* Fix samples and copy edit all in-line documentation
  * Fix samples for Project#create_instance type development
  * Add acceptance test for Project#create_instance type development
* Fix timestamp param documentation
* Update copyright year
* Update documentation (no visible changes)
* Update documentation to indicate attributes as required
* Update generated IAM Policy documentation
* Update links to googleapis.dev
* Update low-level IAM documentation
  * Update GetPolicyOption#requested_policy_version docs
  * Un-deprecate Policy#version
* Update low-level IAM Policy class description and sample code
* Update low-level IAM Policy documentation
* Update lower-level API documentation
* Update release level to GA
* Update Status documentation
* fix bad links ([#3783](https://www.github.com/googleapis/google-cloud-ruby/issues/3783))
* update links to point to new docsite ([#3684](https://www.github.com/googleapis/google-cloud-ruby/issues/3684))
* Update the list of GCP environments for automatic authentication

### 2.1.0 / 2020-09-17

#### Features

* quota_project can be set via library configuration ([#7630](https://www.github.com/googleapis/google-cloud-ruby/issues/7630))

### 2.0.0 / 2020-08-06

This is a major update that removes the "low-level" client interface code, and
instead adds the new `google-cloud-bigtable-v2` and
`google-cloud-bigtable-admin-v2` gems as dependencies. The new dependencies
are rewritten low-level clients, produced by a next-generation client code
generator, with improved performance and stability.

This change should have no effect on the high-level interface that most users
will use. The one exception is that the (mostly undocumented) `client_config`
argument, for adjusting low-level parameters such as RPC retry settings on
client objects, has been removed. If you need to adjust these parameters, use
the configuration interface in `google-cloud-bigtable-v2` and
`google-cloud-bigtable-admin-v2`.

Substantial changes have been made in the low-level interfaces, however. If you
are using the low-level classes under the `Google::Cloud::Bigtable::V2` or
`Google::Cloud::Bigtable::Admin::V2` modules, please review the docs for the
new `google-cloud-bigtable-v2` and `google-cloud-bigtable-admin-v2` gems.
In particular:

* Some classes have been renamed, notably the client classes themselves.
* The client constructor takes a configuration block instead of configuration
  keyword arguments.
* All RPC method arguments are now keyword arguments.

### 1.3.0 / 2020-07-21

#### Features

* Add Managed Backups
  * Add Cluster#create_backup, Cluster#backup and Cluster#backups
  * Add Backup, Backup::Job and Backup::List
  * Add Table::RestoreJob
  * Add ClusterState#ready_optimizing?

### 1.2.2 / 2020-05-28

#### Documentation

* Fix a few broken links

### 1.2.1 / 2020-05-21

#### Bug Fixes

* Disable streaming RPC retries in lower-level client

### 1.2.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 1.1.0 / 2020-02-10

#### Features

* Add Table-level IAM Policy support

### 1.0.2 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 1.0.1 / 2020-01-15

#### Documentation

* Update lower-level API documentation

### 1.0.0 / 2019-12-03

#### Documentation

* Update release level to GA
* Add OVERVIEW.md guide with samples
* Add sample to README.md
* Fix samples and copy edit all in-line documentation
* Correct error in lower-level API Table IAM documentation
* Update lower-level API documentation to indicate attributes as required
* Update low-level IAM Policy documentation

### 0.8.0 / 2019-11-01

#### ⚠ BREAKING CHANGES

* The following methods now raise Google::Cloud::Error instead of
  Google::Gax::GaxError and/or GRPC::BadStatus:
  * Table#mutate_row
  * Table#read_modify_write_row
  * Table#check_and_mutate_row
  * Table#sample_row_keys

#### Features

* Raise Google::Cloud::Error from Table#mutate_row, Table#read_modify_write_row,
  Table#check_and_mutate_row, and Table#sample_row_keys.

#### Bug Fixes

* Update minimum runtime dependencies

#### Documentation

* Update the list of GCP environments for automatic authentication

### 0.7.0 / 2019-10-22

#### Features

* Update Table#column_families to yield ColumnFamilyMap for updates.
  * ColumnFamilyMap now manages ColumnFamily lifecycle.
* Add MutationOperations::Response.
* Add Bigtable::Status.
* Add Bigtable::RoutingPolicy.
* Update Ruby dependency to minimum of 2.4.

#### BREAKING CHANGES

* Remove ColumnFamily lifecycle methods (create, save, delete, and related class methods).
  * Replaced by Table#column_families yield block.
* Move Google::Cloud::Bigtable::Table::ColumnFamilyMap to Google::Cloud::Bigtable::ColumnFamilyMap.
  * This should only affect introspection, since the constructor was previously undocumented.
* Remove Project#modify_column_families.
  * Replaced by Table#column_families yield block.
* Remove Table#column_family.
  * Replaced by ColumnFamilyMap lifecycle methods.
* Remove Table#modify_column_families.
  * Replaced by Table#column_families yield block.
* Update GcRule#union and #intersection to not return lower-level API types.
* Update all return types and parameters associated with AppProfile routing policy to not use lower-level API types.
  * The new types have exactly the same API as the old types, so this change should only affect type introspection.
* Update return types of Chain and Interleave row filters to not use lower-level API types.
* Change return type of MutationOperations#mutate_rows from lower-level API types to wrapper types.
* Remove private MutationEntry#mutations from documentation.
* Update GcRule#max_age to microsecond precision.

#### Documentation

* Update sample code.
* Update documentation.

### 0.6.2 / 2019-10-01

#### Documentation

* Fix role string in low-level IAM Policy JSON example
* Update low-level IAM Policy class description and sample code

### 0.6.1 / 2019-09-05

#### Features
	
* Add IAM to low-level API client
  * Add BigtableTableAdminClient#get_iam_policy
  * Add BigtableTableAdminClient#set_iam_policy
  * Add BigtableTableAdminClient#test_iam_permissions

#### Documentation

* Update low-level IAM documentation
  * Update GetPolicyOption#requested_policy_version docs
  * Un-deprecate Policy#version

### 0.6.0 / 2019-08-23

#### Features

* Support overriding of the service endpoint

#### Documentation

* Update documentation

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
