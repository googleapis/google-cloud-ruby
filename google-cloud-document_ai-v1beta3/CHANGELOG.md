# Release History

### 0.13.0 (2022-08-17)

#### Features

* Added corrected_key_text and corrected_value_text to the FormField type 
* Added detected_barcodes to the Page type 
* Added field_mask argument to process requests 
* Added integer_value and float_value to the NormalizedValue type 
* Added parent_ids to the Revision type 
* Support for fetching processor resources ([#19026](https://github.com/googleapis/google-cloud-ruby/issues/19026)) 
* Support for listing processor types 
* Support for listing, fetching, deleting, deploying, and undeploying processor versions 
* Support for location management calls 
* Support for setting the default processor version 

### 0.12.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.11.0 / 2022-02-16

#### Features

* Report the detected symbols in a page

### 0.10.0 / 2022-02-08

#### Features

* Add the ReviewDocumentOperationMetadata#question_id field

### 0.9.4 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.9.3 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.9.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.9.1 / 2021-07-29

#### Documentation

* Clarify some language around authentication configuration

### 0.9.0 / 2021-06-23

#### Features

* Support processor management methods
* Use non-regionalized default host name

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.8.0 / 2021-05-06

#### Features

* Report confidence of detected page elements

### 0.7.0 / 2021-03-30

#### Features

* Support for the EVAL_SKIPPED operation type

### 0.6.0 / 2021-03-10

#### ⚠ BREAKING CHANGES

* **document_ai-v1beta3:** Remove the document translations field

#### Features

* Remove the document translations field

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-25

#### Features

* Support boolean normalized values

### 0.3.0 / 2021-02-17

#### Features

* Support for inline documents and human review status

### 0.2.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.1.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.0 / 2020-12-07

Initial release
