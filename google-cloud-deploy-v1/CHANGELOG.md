# Changelog

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
