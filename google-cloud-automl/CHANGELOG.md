# Release History

### 1.1.4 / 2022-01-13

#### Documentation

* Minor updates to the reference documentation

### 1.1.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.1.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.1.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.1.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.0.2 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.0.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.0.0 / 2020-06-30

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.7.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 0.7.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.6.0 / 2020-03-04

#### Features

* Add TablesAnnotation#baseline_score

### 0.5.1 / 2020-01-22

#### Documentation

* Update copyright year
* Update product documentation

### 0.5.0 / 2019-12-18

#### Features

* Add Long Running Operation methods
  * Add AutoMLClient#get_operation
  * Add AutoMLClient#list_operations

#### Documentation

* Update TablesModelColumnInfo documentation

### 0.4.0 / 2019-11-05

#### Features

* Add new metadata fields
  * Add ImageClassificationModelMetadata#node_qps
  * Add ImageClassificationModelMetadata#node_count
  * Add TablesModelMetadata#optimization_objective_recall_value
  * Add TablesModelMetadata#optimization_objective_precision_value
  * Add TextClassificationModelMetadata#classification_type

#### Bug Fixes

* Update minimum runtime dependencies

#### Documentation

* Update the list of GCP environments for automatic authentication

#### Other

* Update Ruby dependency to minimum of 2.4

### 0.3.0 / 2019-10-01

#### Features

* Support model deployment metadata for image classification
  * Add image_classification_model_deployment_metadata argument to AutoMLClient#deploy_model
  * Add ImageClassificationModelDeploymentMetadata class

### 0.2.0 / 2019-08-23

#### Features

* Update Document
  * Add Document#document_text (TextSnippet)
  * Add Document#layout (Document::Layout)
  * Add Document#document_dimensions (DocumentDimensions)
  * Add Document#page_count
  * Add Document::Layout
  * Add DocumentDimensions
* Update PredictionServiceClient#predict response
  * Add PredictResponse#preprocessed_input (ExamplePayload)
* Add BatchPredictResult#metadata.
* Add ConfusionMatrix#display_name
* Add TableSpec#valid_row_count
* Deprecate ColumnSpec#top_correlated_columns

#### Documentation

* Update documentation

### 0.1.0 / 2019-07-15

* Initial release.
