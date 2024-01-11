# Changelog

### 0.17.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23778](https://github.com/googleapis/google-cloud-ruby/issues/23778)) 

### 0.16.2 (2023-12-13)

#### Documentation

* fix typo in the OccurrenceType documentation 

### 0.16.1 (2023-11-06)

#### Documentation

* Update documentation ([#23498](https://github.com/googleapis/google-cloud-ruby/issues/23498)) 

### 0.16.0 (2023-09-28)

#### Features

* support PremiumFeatures and IndividualPageSelector 

### 0.15.0 (2023-09-26)

#### Features

* support display_name for RawDocument feat(document_ai): support ProcessorVersionAlias 

### 0.14.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.13.0 (2023-06-20)

#### Features

* support styleInfo for document 

### 0.12.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.11.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.10.0 (2023-02-23)

#### Features

* Support for getting the most recently invoked evaluation for a processor version 
* Support for the evaluate_processor_version RPC 
* Support for the get_evaluation RPC 
* Support for the list_evaluations RPC 
* Support for the train_processor_version RPC ([#20491](https://github.com/googleapis/google-cloud-ruby/issues/20491)) 
#### Documentation

* Marked the EVAL_REQUESTED, EVAL_APPROVED, and EVAL_SKIPPED operation types as deprecated. 

### 0.9.0 (2023-01-19)

#### Features

* Support for the get_processor_type RPC ([#20034](https://github.com/googleapis/google-cloud-ruby/issues/20034)) 

### 0.8.0 (2022-12-15)

#### Features

* Added sample_document_uris field to ProcessorType ([#19877](https://github.com/googleapis/google-cloud-ruby/issues/19877)) 

### 0.7.0 (2022-12-14)

#### Features

* Support for configuring sharding for a GCS output document ([#19856](https://github.com/googleapis/google-cloud-ruby/issues/19856)) 

### 0.6.0 (2022-11-09)

#### Features

* add document_schema to processor 
* add font_family, ImageQualityScores and Provenance to document 

### 0.5.0 (2022-08-10)

#### Features

* Added corrected_key_text and corrected_value_text to the FormField type 
* Added detected_barcodes to the Page type 
* Added field_mask argument to process requests 
* Added integer_value and float_value to the NormalizedValue type 
* Added parent_ids to the Revision type 
* Support for listing and fetching processor types 
* Support for listing, fetching, creating, deleting, enabling, and disabling processors ([#18998](https://github.com/googleapis/google-cloud-ruby/issues/18998)) 
* Support for listing, fetching, deploying, and undeploying processor versions 
* Support for location management calls 
#### Documentation

* fix minor docstring formatting ([#19009](https://github.com/googleapis/google-cloud-ruby/issues/19009)) 

### 0.4.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.3.0 / 2022-02-16

#### Features

* Add ReviewDocumentOperationMetadata#question_id field
* Report the detected symbols in a page

### 0.2.4 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.2.3 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.2.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.2.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.2.0 / 2021-06-22

#### Features

* Support schema validation and priority in the review_document call

### 0.1.0 / 2021-06-21

#### Features

* Initial generation of google-cloud-document_ai-v1
