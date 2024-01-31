# Release History

### 2.14.0 (2024-01-31)

#### Features

* Support sum & avg aggregate functions ([#23446](https://github.com/googleapis/google-cloud-ruby/issues/23446)) 

### 2.13.1 (2023-06-16)

#### Documentation

* Fixed broken links in authentication documentation ([#21619](https://github.com/googleapis/google-cloud-ruby/issues/21619)) 

### 2.13.0 (2023-05-10)

#### Features

* Added support for bulk writer ([#21426](https://github.com/googleapis/google-cloud-ruby/issues/21426)) 

### 2.12.0 (2023-04-20)

#### Features

* Add support for OR query ([#20920](https://github.com/googleapis/google-cloud-ruby/issues/20920)) 

### 2.11.0 (2023-02-23)

#### Features

* Support REST transport ([#20446](https://github.com/googleapis/google-cloud-ruby/issues/20446)) 

### 2.10.1 (2023-02-16)

#### Bug Fixes

* update version of firestore-v1 in gemspec ([#20433](https://github.com/googleapis/google-cloud-ruby/issues/20433)) 

### 2.10.0 (2023-02-09)

#### Features

* Added support for multiple databases ([#20029](https://github.com/googleapis/google-cloud-ruby/issues/20029)) 

### 2.9.1 (2023-02-03)

#### Bug Fixes

* Change "aggregate_alias" to optional param ([#20082](https://github.com/googleapis/google-cloud-ruby/issues/20082)) 

### 2.9.0 (2023-01-26)

#### Features

* Added support for read time ([#19851](https://github.com/googleapis/google-cloud-ruby/issues/19851)) 

### 2.8.0 (2023-01-05)

#### Features

* Support query count for Firestore ([#19457](https://github.com/googleapis/google-cloud-ruby/issues/19457)) 
#### Bug Fixes

* Add support for merging null field in a document ([#19918](https://github.com/googleapis/google-cloud-ruby/issues/19918)) 

### 2.7.2 (2022-08-24)

#### Documentation

* fix firestore emulator guide ([#19045](https://github.com/googleapis/google-cloud-ruby/issues/19045)) 

### 2.7.1 (2022-07-15)

#### Bug Fixes

* Fix a regression in fields conversion ([#18833](https://github.com/googleapis/google-cloud-ruby/issues/18833)) 
#### Documentation

* Fix typo in data model reference ([#18835](https://github.com/googleapis/google-cloud-ruby/issues/18835)) 

### 2.7.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18446](https://github.com/googleapis/google-cloud-ruby/issues/18446)) 

### 2.6.6 / 2022-01-11

#### Documentation

* Fix samples/CONTRIBUTING.md
* Update version managers list in CONTRIBUTING.md

### 2.6.5 / 2021-10-25

#### Documentation

* Add documentation for quota_project Configuration attribute

### 2.6.4 / 2021-08-26

#### Bug Fixes

* Fix google-cloud-resource-prefix header

### 2.6.3 / 2021-08-24

#### Bug Fixes

* Fix transaction retry behavior

### 2.6.2 / 2021-07-26

#### Bug Fixes

* Update FieldPath#formatted_string to correctly escape non-simple characters

### 2.6.1 / 2021-07-08

#### Documentation

* Update AUTHENTICATION.md in handwritten packages

### 2.6.0 / 2021-06-15

#### Features

* Add support for Query Partitions
  * Add CollectionGroup
  * Update Client#col_group to return CollectionGroup (subclass of Query)
  * Add QueryPartition
  * Add QueryPartition::List
  * Add Query#to_json and Query.from_json

### 2.5.1 / 2021-04-19

#### Bug Fixes

* Add GRPC::Unknown to retryable errors in Watch::Listener

### 2.5.0 / 2021-03-10

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 2.4.1 / 2021-01-06

#### Bug Fixes

* Replace usage of Write.transform with Write.update_transforms

### 2.4.0 / 2020-11-19

#### Features

* add support for != and NOT_IN queries

### 2.3.0 / 2020-09-30

#### Features

* Add error callbacks for listener threads
  * Add DocumentListener#last_error
  * Add DocumentListener#on_error
  * Add QueryListener#last_error
  * Add QueryListener#on_error

### 2.2.0 / 2020-09-17

#### Features

* quota_project can be set via library configuration ([#7630](https://www.github.com/googleapis/google-cloud-ruby/issues/7630))

#### Documentation

* Add snapshot query cursor sample ([#7601](https://www.github.com/googleapis/google-cloud-ruby/issues/7601))

### 2.1.0 / 2020-09-10

#### Features

* Add Query#limit_to_last

### 2.0.0 / 2020-08-06

This is a major update that removes the "low-level" client interface code, and
instead adds the new `google-cloud-firestore-v1` gem as a dependency.
The new dependency is a rewritten low-level client, produced by a next-
generation client code generator, with improved performance and stability.

This change should have no effect on the high-level interface that most users
will use. The one exception is that the (mostly undocumented) `client_config`
argument, for adjusting low-level parameters such as RPC retry settings on
client objects, has been removed. If you need to adjust these parameters, use
the configuration interface in `google-cloud-firestore-v1`.

Substantial changes have been made in the low-level interfaces, however. If you
are using the low-level classes under the `Google::Cloud::Firestore::V1` module,
please review the docs for the new `google-cloud-firestore-v1` gem. In
particular:

* Some classes have been renamed, notably the client class itself.
* The client constructor takes a configuration block instead of configuration
  keyword arguments.
* All RPC method arguments are now keyword arguments.

### 1.4.4 / 2020-05-28

#### Documentation

* Fix a few broken links

### 1.4.3 / 2020-05-21

#### Bug Fixes

* Adjusted some default timeout and retry settings

### 1.4.2 / 2020-05-14

#### Bug Fixes

* Fix Ruby 2.7 keyword argument warning

### 1.4.1 / 2020-04-14

#### Bug Fixes

* Update the low-level interface to match service changes

### 1.4.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 1.3.0 / 2020-03-02

#### Features

* Add IN and ARRAY_CONTAINS_ANY query operators

### 1.2.4 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 1.2.3 / 2020-01-08

#### Bug Fixes

* Use client instead of service in DocumentReference::List

### 1.2.2 / 2019-12-18

#### Bug Fixes

* Fix MonitorMixin usage on Ruby 2.7
  * Ruby 2.7 will error if new_cond is called before super().
  * Make the call to super() be the first call in initialize

#### Documentation

* Update lower-level API documentation

### 1.2.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 1.2.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform environments support automatic authentication

### 1.1.0 / 2019-08-23

#### Features

* Support overriding of service endpoint
* Add low-level client for the admin API

#### Documentation

* Update documentation

### 1.0.0 / 2019-07-15

* Bump release level to GA.

### 0.26.2 / 2019-07-12

* Update #to_hash to #to_h for compatibility with google-protobuf >= 3.9.0

### 0.26.1 / 2019-07-08

* Support overriding service host and port in the low-level interface.

### 0.26.0 / 2019-06-13

BREAKING CHANGE: The default return value of Client#transaction has been
changed to the return value of the yielded block. Pass commit_response: true
for the previous default behavior of returning the CommitResponse.

* Add commit_response to Client#transaction
* Add Collection Group queries
* Add CollectionReference#list_documents
* Enable grpc.service_config_disable_resolution
* Use VERSION constant in GAPIC client

### 0.25.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for V1 Server API to GA.
* Update generated documentation.
* Extract gRPC header values from request.

### 0.25.0 / 2019-02-01

* Switch Firestore to use the V1 API:
  * Add V1 service to the low level API.
* Add numeric transform methods
  * Add the following methods to Client:
    * Client#field_increment
    * Client#field_maximum
    * Client#field_minimum
  * Add the following methods to FieldValue:
    * FieldValue.increment
    * FieldValue.maximum
    * FieldValue.minimum
* Add field_mask argument to get_all method:
  * Allows specific portions of the document data to be returned.
* Add list_collections alias.
* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.
* Add Firestore emulator support.

### 0.24.2 / 2018-09-20

* Add fix for comparing NaN values
  * NaN values should not be compared, as this may raise with Active Support.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 0.24.1 / 2018-09-12

* Add missing documentation files to package.

### 0.24.0 / 2018-09-10

* Add array_union and array_delete FieldValue configuration.
* Add array-contains as an operator to the Query#where method.
* Update documentation.

### 0.23.0 / 2018-08-17

* Add Firestore Watch
  * A document reference or a collection reference/query can now be
    listened to for changes.
  * The following methods were added:
    * DocumentReference#listen
    * Query#listen
  * The following classes were added:
    * DocumentSnapshot
    * DocumentChange
    * DocumentListener
    * QuerySnapshot
    * QueryListener
* Support DocumentSnapshot objects as cursors.
* Fix mapping of geo Hash to GeoPoint resource.
* Query#select is no longer additive, it now replaces any previously
  selected fields.
* Documentation updates.

### 0.22.0 / 2018-07-05

* Remove Base64 encoding for BYTES values, as it is unnecessary for gRPC endpoints.
* Add documentation for enabling gRPC logging.

### 0.21.1 / 2018-05-24

* Fix bug where some DocumentReference/DocumentSnapshot actions
  were failing due to a bad object configuration.
* Updates to documentation and code examples.

### 0.21.0 / 2018-02-27

* Add Shared Configuration.

### 0.20.0 / 2018-01-10

* First release
