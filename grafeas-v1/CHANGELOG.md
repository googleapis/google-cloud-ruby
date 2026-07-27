# Release History

### 1.10.0 (2026-07-27)

#### Features

* A new enum `AttackRequirements` is added 
* A new enum `ExploitMaturity` is added 
* A new field `cvss_v4` is added to message `.grafeas.v1.VulnerabilityNote` 
* A new field `cvss_v4` is added to message `.grafeas.v1.VulnerabilityOccurrence` 
* A new field `exploit_maturity` is added to message `.grafeas.v1.CVSS` 
* A new field `subsequent_system_availability_impact` is added to message `.grafeas.v1.CVSS` 
* A new field `subsequent_system_confidentiality_impact` is added to message `.grafeas.v1.CVSS` 
* A new field `subsequent_system_integrity_impact` is added to message `.grafeas.v1.CVSS` 
* A new field `vulnerable_system_availability_impact` is added to message `.grafeas.v1.CVSS` 
* A new field `vulnerable_system_confidentiality_impact` is added to message `.grafeas.v1.CVSS` 
* A new field `vulnerable_system_integrity_impact` is added to message `.grafeas.v1.CVSS` 
* A new field attack_requirements is added to message .grafeas.v1.CVSS 
* A new value `CVSS_VERSION_4` is added to enum `CVSSVersion` 
* A new value `USER_INTERACTION_ACTIVE` is added to enum `UserInteraction` 
* A new value `USER_INTERACTION_PASSIVE` is added to enum `UserInteraction` 
#### Documentation

* A comment for enum `AttackComplexity` is changed 
* A comment for enum `AttackVector` is changed 
* A comment for enum `Authentication` is changed 
* A comment for enum `Impact` is changed 
* A comment for enum `PrivilegesRequired` is changed 
* A comment for enum `Scope` is changed 
* A comment for enum `UserInteraction` is changed 
* A comment for enum value `ATTACK_COMPLEXITY_HIGH` in enum `AttackComplexity` is changed 
* A comment for enum value `ATTACK_COMPLEXITY_LOW` in enum `AttackComplexity` is changed 
* A comment for enum value `ATTACK_COMPLEXITY_MEDIUM` in enum `AttackComplexity` is changed 
* A comment for enum value `ATTACK_COMPLEXITY_UNSPECIFIED` in enum `AttackComplexity` is changed 
* A comment for enum value `ATTACK_VECTOR_ADJACENT` in enum `AttackVector` is changed 
* A comment for enum value `ATTACK_VECTOR_LOCAL` in enum `AttackVector` is changed 
* A comment for enum value `ATTACK_VECTOR_NETWORK` in enum `AttackVector` is changed 
* A comment for enum value `ATTACK_VECTOR_PHYSICAL` in enum `AttackVector` is changed 
* A comment for enum value `ATTACK_VECTOR_UNSPECIFIED` in enum `AttackVector` is changed 
* A comment for enum value `AUTHENTICATION_MULTIPLE` in enum `Authentication` is changed 
* A comment for enum value `AUTHENTICATION_NONE` in enum `Authentication` is changed 
* A comment for enum value `AUTHENTICATION_SINGLE` in enum `Authentication` is changed 
* A comment for enum value `AUTHENTICATION_UNSPECIFIED` in enum `Authentication` is changed 
* A comment for enum value `CVSS_VERSION_2` in enum `CVSSVersion` is changed 
* A comment for enum value `CVSS_VERSION_3` in enum `CVSSVersion` is changed 
* A comment for enum value `CVSS_VERSION_UNSPECIFIED` in enum `CVSSVersion` is changed 
* A comment for enum value `IMPACT_COMPLETE` in enum `Impact` is changed 
* A comment for enum value `IMPACT_HIGH` in enum `Impact` is changed 
* A comment for enum value `IMPACT_LOW` in enum `Impact` is changed 
* A comment for enum value `IMPACT_NONE` in enum `Impact` is changed 
* A comment for enum value `IMPACT_PARTIAL` in enum `Impact` is changed 
* A comment for enum value `IMPACT_UNSPECIFIED` in enum `Impact` is changed 
* A comment for enum value `PRIVILEGES_REQUIRED_HIGH` in enum `PrivilegesRequired` is changed 
* A comment for enum value `PRIVILEGES_REQUIRED_LOW` in enum `PrivilegesRequired` is changed 
* A comment for enum value `PRIVILEGES_REQUIRED_NONE` in enum `PrivilegesRequired` is changed 
* A comment for enum value `PRIVILEGES_REQUIRED_UNSPECIFIED` in enum `PrivilegesRequired` is changed 
* A comment for enum value `SCOPE_CHANGED` in enum `Scope` is changed 
* A comment for enum value `SCOPE_UNCHANGED` in enum `Scope` is changed 
* A comment for enum value `SCOPE_UNSPECIFIED` in enum `Scope` is changed 
* A comment for enum value `USER_INTERACTION_NONE` in enum `UserInteraction` is changed 
* A comment for enum value `USER_INTERACTION_REQUIRED` in enum `UserInteraction` is changed 
* A comment for enum value `USER_INTERACTION_UNSPECIFIED` in enum `UserInteraction` is changed 
* A comment for field `attack_complexity` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `attack_vector` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `authentication` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `availability_impact` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `confidentiality_impact` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `integrity_impact` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `privileges_required` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `scope` in message `.grafeas.v1.CVSS` is changed 
* A comment for field `user_interaction` in message `.grafeas.v1.CVSS` is changed 

### 1.9.0 (2026-06-11)

#### Features

* update gapic-common dependency to 1.3 and document retry jitter ([#34062](https://github.com/googleapis/google-cloud-ruby/issues/34062)) 

### 1.8.0 (2026-04-15)

#### Features

* publish client batch config schema ([#33443](https://github.com/googleapis/google-cloud-ruby/issues/33443)) 
#### Documentation

* update SelectiveGapicGeneration usage doc ([#33485](https://github.com/googleapis/google-cloud-ruby/issues/33485)) 

### 1.7.0 (2026-02-18)

#### Features

* A new field `last_vulnerability_update_time` is added to message `.grafeas.v1.DiscoveryOccurrence` ([#32397](https://github.com/googleapis/google-cloud-ruby/issues/32397)) 

### 1.6.0 (2026-01-13)

#### Features

* A new field `files` is added to message `.grafeas.v1.DiscoveryOccurrence` 
* A new message `File` is added ([#32345](https://github.com/googleapis/google-cloud-ruby/issues/32345)) 

### 1.5.1 (2025-10-27)

#### Documentation

* add warning about loading unvalidated credentials 

### 1.5.0 (2025-09-10)

#### Features

* update gapic-common dependency for generated libraries to 1.2 which requires google-protobuf v4.26+ ([#30989](https://github.com/googleapis/google-cloud-ruby/issues/30989)) 

### 1.4.0 (2025-05-11)

#### Features

* Support for Layer Details of a package 
* Support for Secrets 
* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.3.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.3.0 (2025-01-29)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.2.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.1.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.1.0 (2024-08-02)

#### Features

* Support for ComplianceOccurrence#version 
* Support for DiscoveryOccurrence#vulnerability_attestation 

### 1.0.0 (2024-07-08)

#### Features

* Bump version to 1.0.0 

### 0.16.1 (2024-04-19)

#### Bug Fixes

* Set the transport of grafeas back to grpc only ([#25439](https://github.com/googleapis/google-cloud-ruby/issues/25439)) 

### 0.16.0 (2024-03-18)

#### Features

* Support InTotoSlsaProvenanceV1 ([#25380](https://github.com/googleapis/google-cloud-ruby/issues/25380)) 
* Support new field "extra_details" in VulnerabilityOccurrence ([#25380](https://github.com/googleapis/google-cloud-ruby/issues/25380)) 
* Support new field "impact" in Impact ([#25380](https://github.com/googleapis/google-cloud-ruby/issues/25380)) 
* Support new field "in_toto_slsa_provenance_v1" in BuildOccurrence ([#25380](https://github.com/googleapis/google-cloud-ruby/issues/25380)) 
* Support new field "sbom_status" in DiscoveryOccurence, Occurence and Note ([#25380](https://github.com/googleapis/google-cloud-ruby/issues/25380)) 
* Support new field "vulnerability_id" in Assessment ([#25380](https://github.com/googleapis/google-cloud-ruby/issues/25380)) 

### 0.15.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24881](https://github.com/googleapis/google-cloud-ruby/issues/24881)) 

### 0.14.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files ([#24517](https://github.com/googleapis/google-cloud-ruby/issues/24517)) 

### 0.14.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.14.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23790](https://github.com/googleapis/google-cloud-ruby/issues/23790)) 

### 0.13.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22926](https://github.com/googleapis/google-cloud-ruby/issues/22926)) 

### 0.12.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.12.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21681](https://github.com/googleapis/google-cloud-ruby/issues/21681)) 

### 0.11.0 (2023-05-04)

#### Features

* Added support for bulk writer ([#21426](https://github.com/googleapis/google-cloud-ruby/issues/21426)) 

### 0.10.0 (2023-04-16)

#### Features

* Update AttackComplexity and Authentication enums 

### 0.9.0 (2023-03-15)

#### Features

* Add vulnerability assessment options ([#20892](https://github.com/googleapis/google-cloud-ruby/issues/20892)) 

### 0.8.0 (2023-03-05)

#### Features

* Report the CVSS V2 score for a vulnerability ([#20597](https://github.com/googleapis/google-cloud-ruby/issues/20597)) 

### 0.7.0 (2022-10-03)

#### Features

* add new analysis status and cvss version fields ([#19238](https://github.com/googleapis/google-cloud-ruby/issues/19238)) 

### 0.6.1 (2022-07-27)

* No significant updates

### 0.6.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.5.0 (2022-06-14)

#### Features

* Added a number of fields, including package type, CPE URI, and architecture, to the PackageNoteand PackageOccurrence data structures
* Added benchmark document name field to ComplianceVersion
* Added file location field to the PackageIssue data structure
* Added support for SLSA provenance version 0.2
#### Bug Fixes

* Deprecated the CPE URI from the Location data structure

### 0.4.0 / 2022-01-13

#### Features

* BREAKING CHANGE: Changed the type of VulnerabilityOccurrence#cvssv3 to a generalized CVSS Score data type that can cover multiple CVSS versions.
* Added DiscoveryOccurrence#archive_time, providing the time when occurrences were archived.

### 0.3.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages

### 0.3.0 / 2021-11-08

#### Features

* Support compliance and in-toto attestation

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.2.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.2.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.1.4 / 2021-02-02

#### Documentation

* Update readme to clarify the difference between this library and grafeas

### 0.1.3 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credential values

### 0.1.1 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.0 / 2020-06-03

Initial release
