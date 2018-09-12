# Release History

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
