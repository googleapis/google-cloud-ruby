# Changelog

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
