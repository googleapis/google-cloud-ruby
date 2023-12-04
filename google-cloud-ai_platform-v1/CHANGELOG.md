# Changelog

### 0.35.0 (2023-12-04)

#### Features

* add direct_predict, direct_raw_predict, streaming_predict, streaming_raw_predict to prediction_service 
* add llm_utility_service  

### 0.34.0 (2023-11-20)

#### Features

* add CountTokensRequest to Prediction 
* add FeatureGroup, FeatureOnlineStore, FeatureOnlineStoreAdminService, FeatureOnlineStoreService, FeatureRegistryService, FeatureView, FeatureViewSync 
* add numeric_restriction to Index 
* add protected_artifact_location_id to CustomJob ([#23538](https://github.com/googleapis/google-cloud-ruby/issues/23538)) 
* add tpu_topology to MachineSpec 
* add value_type, version_column_name to Feature 

### 0.33.0 (2023-10-06)

#### Features

* Support create_dataset_version, delete_dataset_version, get_dataset_version, list_dataset_versions, restore_dataset_version ([#23418](https://github.com/googleapis/google-cloud-ruby/issues/23418)) 

### 0.32.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.31.0 (2023-09-07)

#### Features

* Add field "encryption_spec" to Index ([#22903](https://github.com/googleapis/google-cloud-ruby/issues/22903)) 
* Support contexts for a Trial ([#22903](https://github.com/googleapis/google-cloud-ruby/issues/22903)) 

### 0.30.0 (2023-08-15)

#### Features

* Added disable_retries to custom job scheduling 
* Added open_evaluation_pipeline to PublisherModel::CallToAction 
* PipelineJob returns the schedule_name 
* Support the read_tensorboard_size RPC 

### 0.29.0 (2023-07-28)

#### Features

* support server_streaming_predict 
* support Tensor type 

### 0.28.0 (2023-07-25)

#### Features

* support ScheduleService 

### 0.27.0 (2023-07-13)

#### Features

* Non-structured Datasets report the count of DataItems 
* Support delete_saved_query RPC ([#22519](https://github.com/googleapis/google-cloud-ruby/issues/22519)) 
* Support for reserved IP range names for a PipelineJob 
* Support for the JOB_STATE_PARTIALLY_SUCCEEDED state 

### 0.26.0 (2023-06-20)

#### Features

* support UpdateExplanationDataset 

### 0.25.0 (2023-06-06)

#### Features

* Added ImportFeatureValuesOperationMetadata#blocking_operation_ids 
* Model resource includes the pipeline job that produced it 
* Support for model garden ([#21948](https://github.com/googleapis/google-cloud-ruby/issues/21948)) 
* Support for the NVIDIA_A100_80GB accelerator type 
* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.24.0 (2023-05-19)

#### Features

* add match service 
* support examples for ExplanationParameters 

### 0.24.0 (2023-05-18)

#### Features

* add match service 
* support examples for ExplanationParameters 

### 0.23.0 (2023-05-04)

#### Features

* Added AcceleratorType::NVIDIA_L4 
* Added EntityType#offline_storage_ttl_days 
* Added experiment and experiment_run fields to CustomJobSpec 
* Added Featurestore#online_storage_ttl_days 
* Added ModelSourceInfo::ModelSourceType::GENIE 
* Support for mutate_deployed_model 

### 0.22.0 (2023-04-21)

#### Features

* Support marking TensorBoard instance as default ([#21445](https://github.com/googleapis/google-cloud-ruby/issues/21445)) 

### 0.21.0 (2023-04-06)

#### Features

* Return copy information for a model source 
* Support for public endpoints ([#21046](https://github.com/googleapis/google-cloud-ruby/issues/21046)) 
* Support for the MODEL_GARDEN source 

### 0.20.0 (2023-03-03)

#### Features

* add support for batch_import_evaluated_annotations in model_service 
* add support for delete_feature_values in feature_store ([#20601](https://github.com/googleapis/google-cloud-ruby/issues/20601)) 
* add support for evaluated_annotation 

### 0.19.0 (2023-02-13)

#### Features

* Support for IndexEndpoint#private_service_connect_config 
* Support for MetricSpec#safety_config 
* Support for Model#original_model_info 
* Support for NasJob management RPCs ([#20117](https://github.com/googleapis/google-cloud-ruby/issues/20117)) 
* Support for NasTrialDetail RPCs 
* Support for the copy_model RPC 

### 0.18.0 (2023-01-19)

#### Features

* Support for enabling access to the customized dashboard in training chief container ([#20037](https://github.com/googleapis/google-cloud-ruby/issues/20037)) 

### 0.17.0 (2023-01-11)

#### Features

* Support for order_by in the list_model_versions RPC 
* Support for saved_queries in the Dataset resource 
* Support for the read_tensorboard_usage RPC ([#19979](https://github.com/googleapis/google-cloud-ruby/issues/19979)) 
* Support for update_all_stopped_trials in the ConvexAutomatedStoppingSpec resource 

### 0.16.0 (2022-12-09)

#### Features

* Added metadata_artifact field  to Dataset 
* Added source_uris field to ImportFeatureValuesOperationMetadata 
* Support for search_data_items RPC ([#19803](https://github.com/googleapis/google-cloud-ruby/issues/19803)) 
* Support for specifying a custom service account for model uploads ([#19842](https://github.com/googleapis/google-cloud-ruby/issues/19842)) 
* Support for the write_feature_values RPC ([#19481](https://github.com/googleapis/google-cloud-ruby/issues/19481)) 

### 0.15.0 (2022-11-16)

#### Features

* add service_account to BatchPredictionJob 

### 0.14.0 (2022-11-08)

#### Features

* add annotation_labels to ImportDataConfig 
* add failed_main_jobs and failed_pre_caching_check_jobs to ContainerDetail 
* add metadata_artifact to Model 
* add persist_ml_use_assignment to InputDataConfig 
* add start_time to BatchReadFeatureValuesRequest 

### 0.13.0 (2022-09-28)

#### Features

* Import calls report the number rows that weren't ingested due to having feature timestamps outside the retention boundary 
* Model now includes information about its source 
* Support for changing the order of results in list calls 
* Support for the remove_context_children call ([#19203](https://github.com/googleapis/google-cloud-ruby/issues/19203)) 

### 0.12.0 (2022-08-25)

#### Features

* Support for input artifacts for pipeline jobs 
* Support read mask when listing pipeline jobs ([#19071](https://github.com/googleapis/google-cloud-ruby/issues/19071)) 

### 0.11.0 (2022-08-24)

#### Features

* Support for index_stats and index_update_method 
* Support for upserting and removing datapoints ([#19053](https://github.com/googleapis/google-cloud-ruby/issues/19053)) 

### 0.10.0 (2022-08-01)

#### Features

* add SHARED_RESOURCES to DeploymentResourcesType  
#### Documentation

* cleanup docs 

### 0.9.1 (2022-07-27)

#### Bug Fixes

* Set x-goog-request-params on long-running-operations calls ([#18877](https://github.com/googleapis/google-cloud-ruby/issues/18877)) 

### 0.9.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.8.0 (2022-06-27)

#### Features

* add support for list_saved_queries and batch_import_model_evaluation_slices 

### 0.7.0 (2022-06-17)

#### Features

* Added default threshold to drift detection config
* Added default threshold to skew detection config
* Added model version ID to the upload_model response

### 0.6.0 (2022-06-15)

#### Features

* Added a monitor time window to ModelDeploymentMonitoringScheduleConfig
* Added support for location and iam_policy mixin clients
* Added support for model version calls
* Added version fields to Model, including ID, aliases, create and update time, and description
* CompletionStats includes successful_forecast_point_count
* Explanation includes a list of nearest neighbors
* ExplanationSpecOverride includes example-based parameter overrides
* TrainingPipeline includes model ID and parent
* You can now specify the parent model and model ID when uploading a model

### 0.5.0 (2022-05-26)

#### Features

* add latent_space_source to explanation metadata
* add pipeline template metadata template to pipeline jobs
* add scaling to online serving config
* add support for pipeline failure policy in pipeline runtime config

### 0.4.0 (2022-05-12)

#### Features

* Added display_name and metadata fields to ModelEvaluation

### 0.3.0 (2022-04-20)

#### Features

* Added reserved_ip_ranges to CustomJobSpec
* Added nfs_mounts to WorkPoolSpec
* Added JOB_STATE_UPDATING to JobState
* Added MfsMount
* Added ConvexAutomatedStoppingSpec to StudySpec

### 0.2.0 / 2022-03-30

#### Features

* Support for importing an externally generated ModelEvaluation
* Support for configuring the request-response logging for online prediction
* Support for monitoring_config on entity types
* Support for disabling the ingestion analysis pipeline when importing features
* Support for EvaluatedDataItemView and EvaluatedAnnotation schemas

### 0.1.0 / 2022-02-17

#### Features

* Initial generation of google-cloud-ai_platform-v1
