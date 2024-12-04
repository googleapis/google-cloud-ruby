# Changelog

### 0.59.0 (2024-12-04)

#### Features

* Support for DedicatedResources#required_replica_count field 
* Support for DeployedModel#status field 
* Support for Endpoint#client_connection_config 
* Support for NotebookExecutionJob#custom_environment_spec 
* Support for REST resource paths that include RAG corpora 
* Support for Retrieval#vertex_rag_store 
* Support for the update_endpoint_long_running RPC in the EndpointService 
* Support for VertexRagDataService and all associated RPCs and types 
* Support for VertexRagService and all associated RPCs and types 

### 0.58.0 (2024-11-14)

#### Features

* add BYOSA field to tuning_job 
* add fast_tryout_enabled to FasterDeploymentConfig v1 proto ([#27596](https://github.com/googleapis/google-cloud-ruby/issues/27596)) 
* COMET added to evaluation service proto 
* metricX added to evaluation service proto 
#### Documentation

* A comment for field `annotation_schema_uri` in message `.google.cloud.aiplatform.v1.ExportDataConfig` is changed 
* A comment for field `attributions` in message `.google.cloud.aiplatform.v1.Explanation` is changed 
* A comment for field `bool_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `bytes_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `data_stats` in message `.google.cloud.aiplatform.v1.Model` is changed 
* A comment for field `deployed_index` in message `.google.cloud.aiplatform.v1.MutateDeployedIndexRequest` is changed 
* A comment for field `double_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `enable_logging` in message `.google.cloud.aiplatform.v1.ModelMonitoringAlertConfig` is changed 
* A comment for field `float_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `int_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `int64_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `next_page_token` in message `.google.cloud.aiplatform.v1.ListNotebookExecutionJobsResponse` is changed 
* A comment for field `page_token` in message `.google.cloud.aiplatform.v1.ListFeatureGroupsRequest` is changed 
* A comment for field `page_token` in message `.google.cloud.aiplatform.v1.ListNotebookExecutionJobsRequest` is changed 
* A comment for field `page_token` in message `.google.cloud.aiplatform.v1.ListPersistentResourcesRequest` is changed 
* A comment for field `page_token` in message `.google.cloud.aiplatform.v1.ListTuningJobsRequest` is changed 
* A comment for field `predictions` in message `.google.cloud.aiplatform.v1.EvaluatedAnnotation` is changed 
* A comment for field `request` in message `.google.cloud.aiplatform.v1.BatchMigrateResourcesOperationMetadata` is changed 
* A comment for field `restart_job_on_worker_restart` in message `.google.cloud.aiplatform.v1.Scheduling` is changed 
* A comment for field `saved_query_id` in message `.google.cloud.aiplatform.v1.ExportDataConfig` is changed 
* A comment for field `string_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `timeout` in message `.google.cloud.aiplatform.v1.Scheduling` is changed 
* A comment for field `uint_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `uint64_val` in message `.google.cloud.aiplatform.v1.Tensor` is changed 
* A comment for field `update_mask` in message `.google.cloud.aiplatform.v1.UpdateFeatureViewRequest` is changed 
* A comment for message `DeleteEntityTypeRequest` is changed 
* A comment for message `DeleteFeatureViewRequest` is changed 
* A comment for message `GetDatasetRequest` is changed 
* A comment for message `GetDatasetVersionRequest` is changed 
* A comment for message `ListPersistentResourcesRequest` is changed 
* A comment for message `StreamingReadFeatureValuesRequest` is changed 
* A comment for method `ListAnnotations` in service `DatasetService` is changed 
* A comment for method `RebaseTunedModel` in service `GenAiTuningService` is changed 
* A comment for method `ResumeSchedule` in service `ScheduleService` is changed 

### 0.57.0 (2024-11-13)

#### Features

* add BatchCreateFeatures rpc to feature_registry_service.proto 
* add system labels field to model garden deployments ([#27555](https://github.com/googleapis/google-cloud-ruby/issues/27555)) 
* added support for specifying function response type in `FunctionDeclaration` 
#### Documentation

* A comment for field `feature_group_id` in message `.google.cloud.aiplatform.v1.CreateFeatureGroupRequest` is changed 
* A comment for message `BatchCreateFeaturesRequest` is modified to call out BatchCreateFeatures 
* updated the maximum number of function declarations from 64 to 128 

### 0.56.0 (2024-11-07)

#### Features

* add StopNotebookRuntime method ([#27538](https://github.com/googleapis/google-cloud-ruby/issues/27538)) 

### 0.55.0 (2024-10-25)

#### Features

* add `text` field for Grounding metadata support chunk output ([#27458](https://github.com/googleapis/google-cloud-ruby/issues/27458)) 

### 0.54.0 (2024-10-08)

#### Features

* Added a continuous FeatureView sync option 
* Added a dynamic retrieval API 
* Added psc_automation_configs to DeployIndex 

### 0.53.0 (2024-09-30)

#### Features

* GenerateContentResponse includes the model version 
* Schemas support any_of subschemas 
* Support for logprobs results 
* Support for the rebase_tuned_model RPC 

### 0.52.0 (2024-09-19)

#### Features

* A new field `generation_config` is added to message `.google.cloud.aiplatform.v1.CountTokensRequest` 
* A new field `labels` is added to message `.google.cloud.aiplatform.v1.GenerateContentRequest` 
* A new field `property_ordering` is added to message `.google.cloud.aiplatform.v1.Schema` 
* Add CIVIC_INTEGRITY category to SafetySettings for prediction service ([#27331](https://github.com/googleapis/google-cloud-ruby/issues/27331)) 

### 0.51.0 (2024-09-11)

#### Features

* Support for FeatureGroup::BigQuery#static_data_source and FeatureGroup::BigQuery#dense 
* Support for FeatureView#vertex_rag_source 
* Support for FeatureViewSync::SyncSummary#system_watermark_time 
* Support for SafetySetting::HarmBlockThreshold::OFF 
* Support for Scheduling::Strategy::FLEX_START 

### 0.50.0 (2024-08-30)

#### Features

* add max_wait_duration to Scheduling ([#27023](https://github.com/googleapis/google-cloud-ruby/issues/27023)) 
* add v1 NotebookExecutionJob to Schedule ([#27032](https://github.com/googleapis/google-cloud-ruby/issues/27032)) 
#### Documentation

* Add field `experimental_features` to message `PythonSettings` 
* Add field `experimental_features` to message `PythonSettings` ([#27002](https://github.com/googleapis/google-cloud-ruby/issues/27002)) 

### 0.49.0 (2024-08-26)

#### Features

* A new field `avg_logprobs` is added to message `.google.cloud.aiplatform.v1.Candidate` 
* A new field `encryption_spec` is added to message `.google.cloud.aiplatform.v1.NotebookExecutionJob` 
* A new field `hugging_face_token` is added to message `.google.cloud.aiplatform.v1.GetPublisherModelRequest` 
* A new field `routing_config` is added to message `.google.cloud.aiplatform.v1.GenerationConfig` 
* A new field `sample_request` is added to message `.google.cloud.aiplatform.v1.PublisherModel` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.BatchPredictionJob` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.CustomJob` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.DataItem` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.Dataset` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.DatasetVersion` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.DeploymentResourcePool` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.EntityType` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.FeatureOnlineStore` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.Featurestore` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.FeatureView` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.FeatureViewSync` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.HyperparameterTuningJob` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.Index` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.IndexEndpoint` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.ModelDeploymentMonitoringJob` 
* A new field `satisfies_pzi` is added to message `.google.cloud.aiplatform.v1.NasJob` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.BatchPredictionJob` ([#26954](https://github.com/googleapis/google-cloud-ruby/issues/26954)) 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.CustomJob` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.DataItem` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.Dataset` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.DatasetVersion` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.DeploymentResourcePool` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.EntityType` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.FeatureOnlineStore` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.Featurestore` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.FeatureView` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.FeatureViewSync` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.HyperparameterTuningJob` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.Index` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.IndexEndpoint` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.ModelDeploymentMonitoringJob` 
* A new field `satisfies_pzs` is added to message `.google.cloud.aiplatform.v1.NasJob` 
* A new field `seed` is added to message `.google.cloud.aiplatform.v1.GenerationConfig` 
* A new field `service_attachment` is added to message `.google.cloud.aiplatform.v1.PrivateServiceConnectConfig` 
* A new field `time_series` is added to message `.google.cloud.aiplatform.v1.FeatureGroup` 
* A new field `total_truncated_example_count` is added to message `.google.cloud.aiplatform.v1.SupervisedTuningDataStats` 
* A new field `truncated_example_indices` is added to message `.google.cloud.aiplatform.v1.SupervisedTuningDataStats` 
* A new message `RoutingConfig` is added 
* A new message `TimeSeries` is added 
* A new resource_definition `compute.googleapis.com/NetworkAttachment` is added 
#### Documentation

* A comment for enum `Strategy` is changed 
* A comment for enum value `AUTO` in enum `Mode` is changed 
* A comment for enum value `BLOCKLIST` in enum `FinishReason` is changed 
* A comment for enum value `MAX_TOKENS` in enum `FinishReason` is changed 
* A comment for enum value `OTHER` in enum `FinishReason` is changed 
* A comment for enum value `PROHIBITED_CONTENT` in enum `FinishReason` is changed 
* A comment for enum value `RECITATION` in enum `FinishReason` is changed 
* A comment for enum value `SAFETY` in enum `FinishReason` is changed 
* A comment for enum value `SPII` in enum `FinishReason` is changed 
* A comment for enum value `STOP` in enum `FinishReason` is changed 
* A comment for enum value `STRATEGY_UNSPECIFIED` in enum `Strategy` is changed 
* A comment for field `model` in message `.google.cloud.aiplatform.v1.GenerateContentRequest` is changed 

### 0.48.0 (2024-08-08)

#### Features

* Add evaluation service proto to v1 
* Allow v1 API calls for some dataset_service, llm_utility_service, and prediction_service APIs without project and location 

### 0.47.0 (2024-08-06)

#### Features

* Add reservation affinity proto ([#26608](https://github.com/googleapis/google-cloud-ruby/issues/26608)) 
* Add spot field to Vertex Prediction's Dedicated Resources and Custom Training's Scheduling Strategy 
#### Documentation

* Update the description for the deprecated GPU (K80) 

### 0.46.0 (2024-08-02)

#### Features

* Support for Candidate#score 
* Support for Endpoint#dedicated_endpoint_enabled, Endpoint#dedicated_endpoint_dns, Endpoint#satisfies_pzs, and Endpoint#satisfies_pzi 
* Support for GroundingMetadata#grounding_chunks and GroundingMetadata#grounding_supports 
* Support for NearestNeighborQuery#numeric_filters 
* Support for RaySpec#ray_logs_spec 
* Support for Scheduling#strategy 
* Support for SupervisedTuningDatasetDistribution#billable_sum 
* Support for SupervisedTuningDataStats#total_billable_token_count 
* Support for the is_hugging_face_model parameter to the get_publisher_model RPC 
* Support for the system_instruction and tools parameters to the count_tokens RPC 
* Support operations on NotebookExecutionJob resources 
#### Documentation

* Deprecated Retrieval#disable_attribution 
* Deprecated Retrieval#disable_attribution 
* Deprecated SupervisedTuningDataStats#total_billable_character_count 

### 0.45.0 (2024-07-09)

#### Features

* enable rest_numeric_enums for aiplatform v1 and v1beta1 ([#26360](https://github.com/googleapis/google-cloud-ruby/issues/26360)) 

### 0.44.0 (2024-07-08)

#### Features

* add model and contents fields to ComputeTokensRequest v1 ([#26277](https://github.com/googleapis/google-cloud-ruby/issues/26277)) 
* add role field to TokensInfo v1 

### 0.43.0 (2024-07-08)

#### Features

* Support for metadata about a deployment config 
* Support for private service connect 
* Support the update_deployment_resource_pool call 

### 0.42.0 (2024-06-25)

#### Features

* Add encryption_spec to TuningJob 
* Add MALFORMED_FUNCTION_CALL to FinishReason ([#26140](https://github.com/googleapis/google-cloud-ruby/issues/26140)) 
* Add preflight_validations to PipelineJob 

### 0.41.0 (2024-05-31)

### ⚠ BREAKING CHANGES

* An existing message `Segment` is removed
* An existing message `GroundingAttribution` is removed
* An existing field `grounding_attributions` is removed from message `.google.cloud.aiplatform.v1beta1.GroundingMetadata`
* An existing field `disable_attribution` is removed from message `.google.cloud.aiplatform.v1beta1.GoogleSearchRetrieval`

#### Features

* add dataplex_config to MetadataStore 
* add direct_notebook_source to NotebookExecutionJob 
* add encryption_spec to FeatureOnlineStore 
* add encryption_spec to NotebookRuntimeTemplate 
* add encryption_spec, service_account, disable_container_logging to DeploymentResourcePool 
* add idle_shutdown_config, encryption_spec, satisfies_pzs, satisfies_pzi to NotebookRuntime 
* add INVALID_SPARSE_DIMENSIONS, INVALID_SPARSE_EMBEDDING, INVALID_EMBEDDING to NearestNeighborSearchOperationMetadata.RecordError 
* add model_reference to Dataset 
* add model_reference to DatasetVersion 
* add more fields in FindNeighborsRequest.Query 
* add RaySpec to PersistentResource 
* add sparse_distance to FindNeighborsResponse.Neighbor 
* add sparse_embedding to IndexDatapoint 
* add sparse_vectors_count to IndexStats 
* add struct_value to FeatureValue 
* add tool_config to GenerateContentRequest 
* add UpdateNotebookRuntimeTemplate to NotebookService 
* add valid_sparse_record_count, invalid_sparse_record_count to NearestNeighborSearchOperationMetadata.ContentValidationStats 
* add ValueType.STRUCT to Feature ([#25997](https://github.com/googleapis/google-cloud-ruby/issues/25997)) 
#### Bug Fixes

* An existing field `disable_attribution` is removed from message `.google.cloud.aiplatform.v1beta1.GoogleSearchRetrieval` 
* An existing field `grounding_attributions` is removed from message `.google.cloud.aiplatform.v1beta1.GroundingMetadata` 
* An existing message `GroundingAttribution` is removed 
* An existing message `Segment` is removed 
#### Documentation

* A comment for enum value `EMBEDDING_SIZE_MISMATCH` in enum `RecordErrorType` is changed 
* A comment for field `exec` in message `.google.cloud.aiplatform.v1beta1.Probe` is changed 
* A comment for field `feature_vector` in message `.google.cloud.aiplatform.v1beta1.IndexDatapoint` is changed 
* A comment for field `vectors_count` in message `.google.cloud.aiplatform.v1beta1.IndexStats` is changed 

### 0.40.0 (2024-05-23)

#### Features

* Add REST transport clients for all calls ([#25829](https://github.com/googleapis/google-cloud-ruby/issues/25829)) 
* Added follow-up Google search entry point to GroundingMetadata 
* Added private service connect configuration to Endpoint 
* Added the TPU_V5_LITEPOD accelerator type 
* Support for deploy task name in model metadata 
* Support for the INVALID_TOKEN_VALUE record error 

### 0.39.0 (2024-04-18)

#### Features

* GenAiTuningService aiplatform v1 initial release ([#25431](https://github.com/googleapis/google-cloud-ruby/issues/25431)) 

### 0.38.0 (2024-03-18)

#### Features

* Add APIs for cancelling & deleting pipeline jobs ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support "NOT_EQUAL" operator ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new enum option "NVIDIA_H100_80GB" in AcceleratorType ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new enum options "BLOCKLIST", "PROHIBITED_CONTENT" & "SPII" in Candidate ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new field "grounding_metadata" in Candidate ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new field "project_number" in FeatureRegistrySource ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new field "sync_summary" in FeatureViewSync ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new fields "display_name" & "metadata" in DatasetVersion ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new fields "probability_score", "severity" and "severity_score" in SafetyRating ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 
* Support new fields "retrieval" & "google_search_retrieval" in Tool ([#25370](https://github.com/googleapis/google-cloud-ruby/issues/25370)) 

### 0.37.0 (2024-02-26)

#### Features

* Support for FeatureViewDataKey#composite_key ([#24859](https://github.com/googleapis/google-cloud-ruby/issues/24859)) 
* Updated minimum Ruby version to 2.7 ([#24862](https://github.com/googleapis/google-cloud-ruby/issues/24862)) 

### 0.36.0 (2024-02-22)

#### Features

* Support CRUD operations on deployment resource pools 
* Support for universe_domain 
* Support for various additional fields on existing RPCs 
* Support the generate_content and stream_generate_content RPCs in the PredictionService 
* Support the query_deployed_models RPC 
* Support the search_nearest_entities RPC in the FeatureOnlineStoreService 
* Support the stream_raw_predict, stream_direct_predict, and stream_direct_raw_predict RPCs in the PredictionService 

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
