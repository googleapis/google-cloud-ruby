# Changelog

### 0.3.0 (2022-04-20)

### ⚠ BREAKING CHANGES

* feat: add reserved_ip_ranges to CustomJobSpec in aiplatform v1 custom_job.proto feat: add nfs_mounts to WorkPoolSpec in aiplatform v1 custom_job.proto feat: add JOB_STATE_UPDATING to JobState in aiplatform v1 job_state.proto feat: add MfsMount in aiplatform v1 machine_resources.proto feat: add ConvexAutomatedStoppingSpec to StudySpec in aiplatform v1 study.proto

#### Features

* add reserved_ip_ranges,  nfs_mounts,  JOB_STATE_UPDATING and ConvexAutomatedStoppingSpec([#18006](https://github.com/googleapis/google-cloud-ruby/issues/18006))

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
