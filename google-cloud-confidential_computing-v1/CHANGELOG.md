# Changelog

### 1.4.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.3.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.2.0 (2024-12-04)

#### Features

* Support for the AWS Principal Tags token type ([#27659](https://github.com/googleapis/google-cloud-ruby/issues/27659)) 

### 1.1.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27004](https://github.com/googleapis/google-cloud-ruby/issues/27004)) 

### 1.1.1 (2024-08-09)

#### Documentation

* Formatting updates to README.md ([#26625](https://github.com/googleapis/google-cloud-ruby/issues/26625)) 

### 1.1.0 (2024-07-22)

#### Features

* Add a new field `tee_attestation` to `VerifyAttestationRequest` message proto for SEV SNP and TDX attestations ([#26440](https://github.com/googleapis/google-cloud-ruby/issues/26440)) 

### 1.0.0 (2024-07-10)

#### Features

* Bump version to 1.0.0 

### 0.9.0 (2024-04-15)

#### Features

* Add additional `TokenType` options (`TOKEN_TYPE_PKI` and `TOKEN_TYPE_LIMITED_AWS`) ([#25444](https://github.com/googleapis/google-cloud-ruby/issues/25444)) 

### 0.8.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24867](https://github.com/googleapis/google-cloud-ruby/issues/24867)) 

### 0.7.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.7.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.7.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23776](https://github.com/googleapis/google-cloud-ruby/issues/23776)) 

### 0.6.0 (2023-11-20)

#### Features

* Add a new field token_type to TokenOptions ([#23534](https://github.com/googleapis/google-cloud-ruby/issues/23534)) 

### 0.5.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.4.0 (2023-08-15)

#### Features

* Add a new field `partial_errors` to `VerifyAttestationResponse` proto ([#22763](https://github.com/googleapis/google-cloud-ruby/issues/22763)) 
* Mark all fields `Optional` for `ContainerImageSignagure` proto ([#22744](https://github.com/googleapis/google-cloud-ruby/issues/22744)) 

### 0.3.0 (2023-07-27)

#### Features

* support confidential_space_info and token_options 

### 0.2.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.1.0 (2023-04-27)

#### Features

* Initial generation of google-cloud-confidential_computing-v1 ([#21489](https://github.com/googleapis/google-cloud-ruby/issues/21489)) 

## Release History
