# Changelog

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
