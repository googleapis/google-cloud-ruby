# Changelog

### 0.10.0 (2023-07-11)

#### Features

* Support for configuring the time to wait for route updates to propagate ([#22511](https://github.com/googleapis/google-cloud-ruby/issues/22511)) 
* Support resource state change and process aborted log entry types 

### 0.9.0 (2023-06-23)

#### Features

* support deploy_parameters for stage 

### 0.8.0 (2023-06-06)

#### Features

* Added ServiceNetworking#disable_pod_overprovisioning ([#22241](https://github.com/googleapis/google-cloud-ruby/issues/22241)) 
* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.7.0 (2023-05-04)

#### Features

* Added PhaseArtifact#job_manifests_path 
* Added support for DeployArtifacts 

### 0.6.0 (2023-03-24)

#### Features

* added support for RELEASE_RENDER log type and deprecated TYPE_RENDER_STATUES_CHANGE 
* added supported for Cloud Deploy Progressive Deployment Strategy ([#20974](https://github.com/googleapis/google-cloud-ruby/issues/20974)) 

### 0.5.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.4.0 (2022-09-28)

#### Features

* Support for Cloud Run deployment targets 
* Support for deployment strategies 
* Support for phases and metadata for a Rollout 
* Support for setting the timeout for a Cloud Build execution 
* Support for suspended delivery pipelines 
* Support for TargetRender failure messages 
* Support for the abandon_release call ([#19226](https://github.com/googleapis/google-cloud-ruby/issues/19226)) 
* Support for the auxiliary IAM Policy client 
* Support for the auxiliary Location client 
* Support for the get_job_run call 
* Support for the list_job_runs call 
* Support for the retry_job call 

### 0.3.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.0 (2022-04-14)

#### Features

* Support for specifying an Anthos Cluster target
* Support for specifying the execution worker pool
* Support for specifying the execution service account
* Support for specifying the storage bucket for artifacts
* Support for specifying the internal IP for a private GKE cluster
* Rollouts and renders now report the failure cause
* Defined types for notification payloads

### 0.1.3 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.1 / 2021-10-21

#### Documentation

* Some documentation formatting fixes

### 0.1.0 / 2021-09-23

#### Features

* Initial generation of google-cloud-deploy-v1
