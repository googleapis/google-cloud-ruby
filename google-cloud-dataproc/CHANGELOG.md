# Release History

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
