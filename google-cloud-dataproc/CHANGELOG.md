# Release History

### 2.6.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24868](https://github.com/googleapis/google-cloud-ruby/issues/24868)) 

### 2.5.0 (2024-02-06)

#### Features

* support session controller and session template controller 

### 2.4.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24258](https://github.com/googleapis/google-cloud-ruby/issues/24258)) 

### 2.3.0 (2023-03-09)

#### Features

* Support REST transport ([#20766](https://github.com/googleapis/google-cloud-ruby/issues/20766)) 

### 2.2.0 (2023-01-05)

#### Features

* Support for NodeGroupController client ([#19852](https://github.com/googleapis/google-cloud-ruby/issues/19852)) 

### 2.1.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 2.0.0 (2022-05-05)

* BREAKING CHANGE: Removed the obsolete google-cloud-dataproc-v1beta2 from the dependencies

### 1.3.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.3.0 / 2021-10-25

#### Features

* Add support for batch workloads

### 1.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.2.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.1.3 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-06

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.10.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.9.1 / 2020-03-02

#### Documentation

* Update formatting
* Update product branding

### 0.9.0 / 2020-02-24

#### Features

* Add SparkRJob, PrestoJob, LifecycleConfig and ReservationAffinity
  * Add ClusterConfig#lifecycle_config (LifecycleConfig)
  * Add GceClusterConfig#reservation_affinity (ReservationAffinity)
  * Add SparkRJob
  * Add PrestoJob

### 0.8.0 / 2020-02-04

#### Features

* Add AutoscalingPolicyServiceClient

### 0.7.3 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 0.7.2 / 2019-12-19

#### Documentation

* Update product name to Dataproc

### 0.7.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.7.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.6.0 / 2019-10-18

#### Features

* Additional configuration options for clusters
  * Add ClusterConfig#autoscaling_config
  * Add ClusterConfig#security_config
  * Add InstanceGroupConfig#min_cpu_platform
  * Add AutoscalingConfig, SecurityConfig, and KerberosConfig classes

### 0.5.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.5.0 / 2019-07-08

* Custom metadata headers are honored by long running operations calls.
* Support overriding service host and port.

### 0.4.0 / 2019-06-11

* Add AutoscalingPolicyServiceClient
  * AutoscalingPolicyServiceClient#create_autoscaling_policy
  * AutoscalingPolicyServiceClient#update_autoscaling_policy
  * AutoscalingPolicyServiceClient#get_autoscaling_policy
  * AutoscalingPolicyServiceClient#list_autoscaling_policies
  * AutoscalingPolicyServiceClient#delete_autoscaling_policy
  * Add ClusterConfig attributes:
    * Add ClusterConfig#autoscaling_config (AutoscalingConfig)
    * Add ClusterConfig#endpoint_config (EndpointConfig)
    * Add ClusterConfig#security_config (SecurityConfig)
  * Add GceClusterConfig#reservation_affinity (ReservationAffinity)
  * Add SoftwareConfig#optional_components (Component)
  * Add Job#spark_r_job (SparkRJob)
* Add VERSION constant

### 0.3.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.
* Extract gRPC header values from request.

### 0.3.0 / 2019-02-01

* Correct documentation to be Alpha quality level.
* Add WorkflowTemplateService module and factory method.
* Add arguments to the following ClusterControllerClient methods:
  * Add request_id argument to #create_cluster method.
  * Add graceful_decommission_timeout argument to #update_cluster method.
  * Add request_id argument to #update_cluster method.
  * Add cluster_uuid argument to #delete_cluster method.
  * Add request_id argument to #delete_cluster method.
* Add EncryptionConfig class and ClusterConfig#encryption_config attribute.
* Add DiskConfig#boot_disk_type attribute.
* Add v1beta2 API version.
* Update documentation.

### 0.2.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.1 / 2018-09-10

* Update documentation.

### 0.2.0 / 2018-08-21

* Update dependencies.
* Update documentation.

### 0.1.0 / 2017-12-26

* Initial release
