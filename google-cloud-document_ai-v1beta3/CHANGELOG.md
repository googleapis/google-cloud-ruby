# Release History

### 0.33.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24869](https://github.com/googleapis/google-cloud-ruby/issues/24869)) 

### 0.32.0 (2024-02-21)

#### Features

* adds display_name to DocumentSchema 
* adds foundation_model_tuning_options to TrainProcessorVersionRequest ([#24825](https://github.com/googleapis/google-cloud-ruby/issues/24825)) 
* adds labels to ProcessRequest and BatchProcessRequest 
#### Bug Fixes

* deprecates Dataset.document_warehouse_config 
#### Documentation

* updates to comments 

### 0.31.0 (2024-02-06)

#### Features

* Expose model_type field in processor version APIs ([#24746](https://github.com/googleapis/google-cloud-ruby/issues/24746)) 

### 0.30.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.30.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.30.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23778](https://github.com/googleapis/google-cloud-ruby/issues/23778)) 

### 0.29.0 (2023-09-28)

#### Features

* add schema_override to ProcessOptions and field_Extraction_metadata to Property Metadata 
* support list documents 
* support SummaryOptions 

### 0.28.0 (2023-09-14)

#### Features

* Support for Enterprise OCR add-ons ([#23321](https://github.com/googleapis/google-cloud-ruby/issues/23321)) 

### 0.27.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.26.0 (2023-07-27)

#### Features

* support external_processor_version_source 

### 0.25.0 (2023-07-18)

#### Features

* added ImportDocuments, GetDocument and BatchDeleteDocuments RPCs for v1beta3 ([#22536](https://github.com/googleapis/google-cloud-ruby/issues/22536)) 

### 0.24.0 (2023-06-20)

#### Features

* support document service with dataset and datasetSchema resources 

### 0.23.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.22.0 (2023-03-23)

#### Features

* Add support for ImportProcessorVersion ([#20946](https://github.com/googleapis/google-cloud-ruby/issues/20946)) 

### 0.21.0 (2023-03-09)

#### Features

* Support hints for the OCR model ([#20764](https://github.com/googleapis/google-cloud-ruby/issues/20764)) 
* Support OCR image quality scores 
* Support symbol level OCR information 

### 0.20.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.19.0 (2023-02-13)

#### Features

* Support for ProcessorVersion#latest_evaluation ([#20134](https://github.com/googleapis/google-cloud-ruby/issues/20134)) 
* Support for the UPDATE OperationType 

### 0.18.0 (2023-01-28)

#### Features

* Add field advanced_ocr_options in OcrConfig ([#20083](https://github.com/googleapis/google-cloud-ruby/issues/20083)) 

### 0.17.0 (2023-01-19)

#### Features

* Support for the get_processor_type RPC ([#20032](https://github.com/googleapis/google-cloud-ruby/issues/20032)) 

### 0.16.0 (2022-12-15)

#### Features

* Added sample_document_uris field to ProcessorType 
* Added process_options argument to process_document RPC ([#19878](https://github.com/googleapis/google-cloud-ruby/issues/19878)) 

### 0.15.0 (2022-12-14)

#### Features

* Support for configuring sharding for a GCS output document ([#19855](https://github.com/googleapis/google-cloud-ruby/issues/19855)) 

### 0.14.0 (2022-11-16)

#### Features

* add documentSchema to ProcessorVersion 
* add field_mask to GcsOutputConfig 
* add image_quality_scores to Font_size and Provenance to Dimension 
* support train_processor_version, evaluate_processor_version and evaluations api 

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
