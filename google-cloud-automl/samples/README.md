# AutoML Samples

<a href="https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/GoogleCloudPlatform/ruby-docs-samples&page=editor&open_in_editor=automl/cloud-client/README.md">
<img alt="Open in Cloud Shell" src ="http://gstatic.com/cloudssh/images/open-btn.png"></a>

This directory contains samples for the [Google Cloud AutoML APIs](https://cloud.google.com/automl/) - [docs](https://cloud.google.com/automl/docs/)

We highly recommend that you refer to the official documentation pages:
* AutoML Natural Language
  * [Classification](https://cloud.google.com/natural-language/automl/docs)
  * [Entity Extraction](https://cloud.google.com/natural-language/automl/entity-analysis/docs)
  * [Sentiment Analysis](https://cloud.google.com/natural-language/automl/sentiment/docs)
* [AutoML Translation](https://cloud.google.com/translate/automl/docs)
<!--* AutoML Video Intelligence
  * [Classification](https://cloud.google.com/video-intelligence/automl/docs)
  * [Object Tracking](https://cloud.google.com/video-intelligence/automl/object-tracking/docs)-->
* AutoML Vision
  * [Classification](https://cloud.google.com/vision/automl/docs)
  <!--* [Edge](https://cloud.google.com/vision/automl/docs/edge-quickstart)-->
  * [Object Detection](https://cloud.google.com/vision/automl/object-detection/docs)
<!--* [AutoML Tables](https://cloud.google.com/automl-tables/docs)-->

This API is part of the larger collection of Cloud Machine Learning APIs.

These Ruby samples demonstrates how to access the Cloud AutoML API
using the [Google Cloud Client Library for Ruby][google-cloud-ruby].

[google-cloud-ruby]: https://github.com/GoogleCloudPlatform/google-cloud-ruby

## Sample Types

There are two types of samples: Base and API Specific

The base samples make up a set of samples that have code that
is identical or nearly identical for each AutoML Type. Meaning that for "Base" samples you can use them with any AutoML
Type. However, for API Specific samples, there will be a unique sample for each AutoML type. See the below list for more info.

## Base Samples

### Dataset Management

* [Import Dataset](import_dataset.rb)
* [List Datasets](list_datasets.rb) - For each AutoML Type the `metadata` field inside the dataset is unique, therefore each AutoML Type will have a
small section of code to print out the `metadata` field.
* [Get Dataset](get_dataset.rb) - For each AutoML Type the `metadata` field inside the dataset is unique, therefore each AutoML Type will have a
small section of code to print out the `metadata` field.
* [Export Dataset](export_dataset.rb)
* [Delete Dataset](delete_dataset.rb)

### Model Management

* [List Models](list_models.rb)
* [List Model Evaluation](list_model_evaluations.rb) - For each AutoML Type the `metrics` field inside the model is unique, therefore each AutoML Type will have a
small section of code to print out the `metrics` field.
* [Get Model](get_model.rb)
* [Get Model Evaluation](get_model_evaluation.rb) - For each AutoML Type the `metrics` field inside the model is unique, therefore each AutoML Type will have a
small section of code to print out the `metrics` field.
* [Delete Model](delete_model.rb)
* [Deploy Model](deploy_model.rb) - Not supported by Translation
* [Undeploy Model](undeploy_model.rb) - Not supported by Translation

### Operation Management

* [List Operation Statuses](list_operation_status.rb)
* [Get Operation Status](get_operation_status.rb)

## AutoML Type Specific Samples

### Translation

* [Translate Create Dataset](translate_create_dataset.rb)
* [Translate Create Model](translate_create_model.rb)
* [Translate Predict](translate_predict.rb)

### Natural Language Entity Extraction

* [Entity Extraction Create Dataset](language_entity_extraction_create_dataset.rb)
* [Entity Extraction Create Model](language_entity_extraction_create_model.rb)
* [Entity Extraction Predict](language_entity_extraction_predict.rb)
* [Entity Extraction Batch Predict](language_batch_predict.rb)

### Natural Language Sentiment Analysis

* [Sentiment Analysis Create Dataset](language_sentiment_analysis_create_dataset.rb)
* [Sentiment Analysis Create Model](language_sentiment_analysis_create_model.rb)
* [Sentiment Analysis Predict](language_sentiment_analysis_predict.rb)

### Natural Language Text Classification

* [Text Classification Create Dataset](language_text_classification_create_dataset.rb)
* [Text Classification Create Model](language_text_classification_create_model.rb)
* [Text Classification Predict](language_text_classification_predict.rb)

### Vision Classification

* [Classification Create Dataset](vision_classification_create_dataset.rb)
* [Classification Create Model](vision_classification_create_model.rb)
* [Classification Predict](vision_classification_predict.rb)
* [Classification Batch Predict](vision_batch_predict.rb)
* [Deploy Node Count](vision_classification_deploy_model_node_count.rb)

### Vision Object Detection

* [Object Detection Create Dataset](vision_object_detection_create_dataset.rb)
* [Object Detection Create Model](vision_object_detection_create_model.rb)
* [Object Detection Predict](vision_object_detection_predict.rb)
* [Object Detection Batch Predict](vision_batch_predict.rb)
* [Deploy Node Count](vision_object_detection_deploy_model_node_count.rb)
