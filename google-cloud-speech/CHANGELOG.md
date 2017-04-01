# Release History

### 0.23.0 / 2017-03-31

* Updated documentation
* Automatic retry on `UNAVAILABLE` errors

### 0.22.2 / 2017-03-03

* No public API changes.
* Update GRPC header value sent to the Speech API.

### 0.22.1 / 2017-03-01

* No public API changes.
* Update GRPC header value sent to the Speech API.

### 0.22.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies
* Update links in documentation

### 0.21.1 / 2016-11/19

* Fix issue with language as a Symbol (frankyn)

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Speech.new
* New constructor argument client_config
* Streaming support added

### 0.20.0 / 2016-09-30

Initial implementation of the Google Cloud Speech API Ruby client.
