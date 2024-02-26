# Release History

### 1.5.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24867](https://github.com/googleapis/google-cloud-ruby/issues/24867)) 

### 1.4.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24257](https://github.com/googleapis/google-cloud-ruby/issues/24257)) 

### 1.3.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.2.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

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

### 1.1.2 / 2021-01-18

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
* More consistent spelling of module names.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.11.0 / 2020-04-10

#### Features

* Move data type classes from Google::Container to Google::Cloud::Container.
  * Note: Google::Container was left as an alias, so older code should still work.

#### Documentation

* Change relative URLs to absolute URLs to fix broken links.
* Render path formats in code font.

### 0.10.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 0.10.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.9.0 / 2020-02-18

#### ⚠ BREAKING CHANGES

* **container:** Change deprecated but required parameters to keyword arguments in most public methods

#### Features

* Change deprecated but required parameters to keyword arguments in most public methods

### 0.8.1 / 2020-01-23

#### Documentation

* Update copyright year

### 0.8.0 / 2019-12-18

#### Features

* Add various new types and attributes
  * Add NodeConfig#shielded_instance_config (ShieldedInstanceConfig)
  * Add Cluster#authenticator_groups_config (AuthenticatorGroupsConfig)
  * Add Cluster#database_encryption(DatabaseEncryption)
  * Add ClusterUpdate#desired_intra_node_visibility_config (IntraNodeVisibilityConfig)
  * Add UpdateNodePoolRequest#workload_metadata_config (WorkloadMetadataConfig)
  * Add NodePool#pod_ipv4_cidr_size
  * Add MaintenancePolicy#resource_version
  * Add MaintenanceWindow#maintenance_exclusions (TimeWindow)
  * Add MaintenanceWindow::Policy#recurring_window (RecurringTimeWindow)
  * Add ClusterAutoscaling#autoprovisioning_node_pool_defaults (AutoprovisioningNodePoolDefaults)
  * Add ClusterAutoscaling#autoprovisioning_locations
  * Add StatusCondition::Code::CLOUD_KMS_KEY_ERROR
  * Add NetworkConfig#enable_intra_node_visibility
  * Add ResourceUsageExportConfig#consumption_metering_config (ConsumptionMeteringConfig)

### 0.7.0 / 2019-11-19

#### Features

* New RPC methods
  * Add ClusterManagerClient#list_usable_subnetworks
* New attributes
  * Add NodeConfig#taints
  * Add NodeConfig#shielded_instance_config
  * Add AddonsConfig#cloud_run_config
  * Add IPAllocationPolicy#tpu_ipv4_cidr_block
  * Add Cluster#binary_authorization
  * Add Cluster#autoscaling
  * Add Cluster#default_max_pods_constraint
  * Add Cluster#resource_usage_export_config
  * Add Cluster#authenticator_groups_config
  * Add Cluster#database_encryption
  * Add Cluster#vertical_pod_autoscaling
  * Add Cluster#enable_tpu
  * Add Cluster#tpu_ipv4_cidr_block
  * Add Cluster#conditions
  * Add ClusterUpdate#desired_database_encryption
  * Add ClusterUpdate#desired_cluster_autoscaling
  * Add ClusterUpdate#desired_binary_authorization
  * Add ClusterUpdate#desired_logging_service
  * Add ClusterUpdate#desired_resource_usage_export_config
  * Add ClusterUpdate#desired_vertical_pod_autoscaling
  * Add ClusterUpdate#desired_intra_node_visibility_config
  * Add Operation#cluster_conditions
  * Add Operation#nodepool_conditions
  * Add NodePool#max_pods_constraint
  * Add NodePool#conditions
  * Add NodePool#pod_ipv4_cidr_size
  * Add MaintenancePolicy#resource_version
  * Add MaintenanceWindow#maintenance_exclusions
  * Add MaintenanceWindow#recurring_window (optional)
  * Add NodePoolAutoscaling#autoprovisioned
* New classes
  * Add NodeTaint
  * Add ShieldedInstanceConfig
  * Add CloudRunConfig
  * Add AuthenticatorGroupsConfig
  * Add BinaryAuthorization
  * Add TimeWindow
  * Add RecurringTimeWindow
  * Add ClusterAutoscaling
  * Add AutoprovisioningNodePoolDefaults
  * Add ResourceLimit
  * Add StatusCondition
  * Add IntraNodeVisibilityConfig
  * Add MaxPodsConstraint
  * Add DatabaseEncryption
  * Add UsableSubnetwork
  * Add UsableSubnetworkSecondaryRange
  * Add ResourceUsageExportConfig
  * Add ResourceUsageExportConfig::BigQueryDestination
  * Add ResourceUsageExportConfig::ConsumptionMeteringConfig
  * Add VerticalPodAutoscaling

### 0.6.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.6.0 / 2019-10-29

* This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.5.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.5.0 / 2019-07-08

* Support overriding service host and port

### 0.4.2 / 2019-06-11

* Add VERSION constant

### 0.4.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Extract gRPC header values from request.

### 0.4.0 / 2019-03-11

* Add v1beta1 API version

### 0.3.0 / 2018-12-10

* Add support for Regional Clusters.
  * Client methods deprecate many positional arguments in
    favor of name/parent named argument.
  * Maintains backwards compatibility.

### 0.2.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.1 / 2018-09-10

* Update documentation.

### 0.2.0 / 2018-08-21

* Move Credentials location:
  * Add Google::Cloud::Container::V1::Credentials
  * Remove Google::Cloud::Container::Credentials
* Update dependencies.
* Update documentation.

### 0.1.0 / 2017-12-26

* Initial release
