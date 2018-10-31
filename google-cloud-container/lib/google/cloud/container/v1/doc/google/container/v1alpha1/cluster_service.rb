# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Container
    module V1alpha1
      # Parameters that describe the nodes in a cluster.
      # @!attribute [rw] machine_type
      #   @return [String]
      #     The name of a Google Compute Engine [machine
      #     type](/compute/docs/machine-types) (e.g.
      #     `n1-standard-1`).
      #
      #     If unspecified, the default machine type is
      #     `n1-standard-1`.
      # @!attribute [rw] disk_size_gb
      #   @return [Integer]
      #     Size of the disk attached to each node, specified in GB.
      #     The smallest allowed disk size is 10GB.
      #
      #     If unspecified, the default disk size is 100GB.
      # @!attribute [rw] oauth_scopes
      #   @return [Array<String>]
      #     The set of Google API scopes to be made available on all of the
      #     node VMs under the "default" service account.
      #
      #     The following scopes are recommended, but not required, and by default are
      #     not included:
      #
      #     * `https://www.googleapis.com/auth/compute` is required for mounting
      #       persistent storage on your nodes.
      #     * `https://www.googleapis.com/auth/devstorage.read_only` is required for
      #       communicating with **gcr.io**
      #       (the [Google Container Registry](https://cloud.google.com/container-registry/)).
      #
      #     If unspecified, no scopes are added, unless Cloud Logging or Cloud
      #     Monitoring are enabled, in which case their required scopes will be added.
      # @!attribute [rw] service_account
      #   @return [String]
      #     The Google Cloud Platform Service Account to be used by the node VMs. If
      #     no Service Account is specified, the "default" service account is used.
      # @!attribute [rw] metadata
      #   @return [Hash{String => String}]
      #     The metadata key/value pairs assigned to instances in the cluster.
      #
      #     Keys must conform to the regexp [a-zA-Z0-9-_]+ and be less than 128 bytes
      #     in length. These are reflected as part of a URL in the metadata server.
      #     Additionally, to avoid ambiguity, keys must not conflict with any other
      #     metadata keys for the project or be one of the reserved keys:
      #      "cluster-location"
      #      "cluster-name"
      #      "cluster-uid"
      #      "configure-sh"
      #      "enable-os-login"
      #      "gci-update-strategy"
      #      "gci-ensure-gke-docker"
      #      "instance-template"
      #      "kube-env"
      #      "startup-script"
      #      "user-data"
      #
      #     Values are free-form strings, and only have meaning as interpreted by
      #     the image running in the instance. The only restriction placed on them is
      #     that each value's size must be less than or equal to 32 KB.
      #
      #     The total size of all keys and values must be less than 512 KB.
      # @!attribute [rw] image_type
      #   @return [String]
      #     The image type to use for this node. Note that for a given image type,
      #     the latest version of it will be used.
      # @!attribute [rw] labels
      #   @return [Hash{String => String}]
      #     The map of Kubernetes labels (key/value pairs) to be applied to each node.
      #     These will added in addition to any default label(s) that
      #     Kubernetes may apply to the node.
      #     In case of conflict in label keys, the applied set may differ depending on
      #     the Kubernetes version -- it's best to assume the behavior is undefined
      #     and conflicts should be avoided.
      #     For more information, including usage and the valid values, see:
      #     https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
      # @!attribute [rw] local_ssd_count
      #   @return [Integer]
      #     The number of local SSD disks to be attached to the node.
      #
      #     The limit for this value is dependant upon the maximum number of
      #     disks available on a machine per zone. See:
      #     https://cloud.google.com/compute/docs/disks/local-ssd#local_ssd_limits
      #     for more information.
      # @!attribute [rw] tags
      #   @return [Array<String>]
      #     The list of instance tags applied to all nodes. Tags are used to identify
      #     valid sources or targets for network firewalls and are specified by
      #     the client during cluster or node pool creation. Each tag within the list
      #     must comply with RFC1035.
      # @!attribute [rw] preemptible
      #   @return [true, false]
      #     Whether the nodes are created as preemptible VM instances. See:
      #     https://cloud.google.com/compute/docs/instances/preemptible for more
      #     inforamtion about preemptible VM instances.
      # @!attribute [rw] accelerators
      #   @return [Array<Google::Container::V1alpha1::AcceleratorConfig>]
      #     A list of hardware accelerators to be attached to each node.
      #     See https://cloud.google.com/compute/docs/gpus for more information about
      #     support for GPUs.
      # @!attribute [rw] disk_type
      #   @return [String]
      #     Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd')
      #
      #     If unspecified, the default disk type is 'pd-standard'
      # @!attribute [rw] min_cpu_platform
      #   @return [String]
      #     Minimum CPU platform to be used by this instance. The instance may be
      #     scheduled on the specified or newer CPU platform. Applicable values are the
      #     friendly names of CPU platforms, such as
      #     <code>minCpuPlatform: &quot;Intel Haswell&quot;</code> or
      #     <code>minCpuPlatform: &quot;Intel Sandy Bridge&quot;</code>. For more
      #     information, read [how to specify min CPU
      #     platform](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform)
      # @!attribute [rw] taints
      #   @return [Array<Google::Container::V1alpha1::NodeTaint>]
      #     List of kubernetes taints to be applied to each node.
      #
      #     For more information, including usage and the valid values, see:
      #     https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
      class NodeConfig; end

      # Kubernetes taint is comprised of three fields: key, value, and effect. Effect
      # can only be one of three types:  NoSchedule, PreferNoSchedule or NoExecute.
      #
      # For more information, including usage and the valid values, see:
      # https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
      # @!attribute [rw] key
      #   @return [String]
      #     Key for taint.
      # @!attribute [rw] value
      #   @return [String]
      #     Value for taint.
      # @!attribute [rw] effect
      #   @return [Google::Container::V1alpha1::NodeTaint::Effect]
      #     Effect for taint.
      class NodeTaint
        # Possible values for Effect in taint.
        module Effect
          # Not set
          EFFECT_UNSPECIFIED = 0

          # NoSchedule
          NO_SCHEDULE = 1

          # PreferNoSchedule
          PREFER_NO_SCHEDULE = 2

          # NoExecute
          NO_EXECUTE = 3
        end
      end

      # The authentication information for accessing the master endpoint.
      # Authentication can be done using HTTP basic auth or using client
      # certificates.
      # @!attribute [rw] username
      #   @return [String]
      #     The username to use for HTTP basic authentication to the master endpoint.
      #     For clusters v1.6.0 and later, you can disable basic authentication by
      #     providing an empty username.
      # @!attribute [rw] password
      #   @return [String]
      #     The password to use for HTTP basic authentication to the master endpoint.
      #     Because the master endpoint is open to the Internet, you should create a
      #     strong password.  If a password is provided for cluster creation, username
      #     must be non-empty.
      # @!attribute [rw] client_certificate_config
      #   @return [Google::Container::V1alpha1::ClientCertificateConfig]
      #     Configuration for client certificate authentication on the cluster. For
      #     clusters before v1.12, if no configuration is specified, a client
      #     certificate is issued.
      # @!attribute [rw] cluster_ca_certificate
      #   @return [String]
      #     [Output only] Base64-encoded public certificate that is the root of
      #     trust for the cluster.
      # @!attribute [rw] client_certificate
      #   @return [String]
      #     [Output only] Base64-encoded public certificate used by clients to
      #     authenticate to the cluster endpoint.
      # @!attribute [rw] client_key
      #   @return [String]
      #     [Output only] Base64-encoded private key used by clients to authenticate
      #     to the cluster endpoint.
      class MasterAuth; end

      # Configuration for client certificates on the cluster.
      # @!attribute [rw] issue_client_certificate
      #   @return [true, false]
      #     Issue a client certificate.
      class ClientCertificateConfig; end

      # Configuration for the addons that can be automatically spun up in the
      # cluster, enabling additional functionality.
      # @!attribute [rw] http_load_balancing
      #   @return [Google::Container::V1alpha1::HttpLoadBalancing]
      #     Configuration for the HTTP (L7) load balancing controller addon, which
      #     makes it easy to set up HTTP load balancers for services in a cluster.
      # @!attribute [rw] horizontal_pod_autoscaling
      #   @return [Google::Container::V1alpha1::HorizontalPodAutoscaling]
      #     Configuration for the horizontal pod autoscaling feature, which
      #     increases or decreases the number of replica pods a replication controller
      #     has based on the resource usage of the existing pods.
      # @!attribute [rw] kubernetes_dashboard
      #   @return [Google::Container::V1alpha1::KubernetesDashboard]
      #     Configuration for the Kubernetes Dashboard.
      # @!attribute [rw] network_policy_config
      #   @return [Google::Container::V1alpha1::NetworkPolicyConfig]
      #     Configuration for NetworkPolicy. This only tracks whether the addon
      #     is enabled or not on the Master, it does not track whether network policy
      #     is enabled for the nodes.
      class AddonsConfig; end

      # Configuration options for the HTTP (L7) load balancing controller addon,
      # which makes it easy to set up HTTP load balancers for services in a cluster.
      # @!attribute [rw] disabled
      #   @return [true, false]
      #     Whether the HTTP Load Balancing controller is enabled in the cluster.
      #     When enabled, it runs a small pod in the cluster that manages the load
      #     balancers.
      class HttpLoadBalancing; end

      # Configuration options for the horizontal pod autoscaling feature, which
      # increases or decreases the number of replica pods a replication controller
      # has based on the resource usage of the existing pods.
      # @!attribute [rw] disabled
      #   @return [true, false]
      #     Whether the Horizontal Pod Autoscaling feature is enabled in the cluster.
      #     When enabled, it ensures that a Heapster pod is running in the cluster,
      #     which is also used by the Cloud Monitoring service.
      class HorizontalPodAutoscaling; end

      # Configuration for the Kubernetes Dashboard.
      # @!attribute [rw] disabled
      #   @return [true, false]
      #     Whether the Kubernetes Dashboard is enabled for this cluster.
      class KubernetesDashboard; end

      # Configuration for NetworkPolicy. This only tracks whether the addon
      # is enabled or not on the Master, it does not track whether network policy
      # is enabled for the nodes.
      # @!attribute [rw] disabled
      #   @return [true, false]
      #     Whether NetworkPolicy is enabled for this cluster.
      class NetworkPolicyConfig; end

      # Configuration options for private clusters.
      # @!attribute [rw] enable_private_nodes
      #   @return [true, false]
      #     Whether nodes have only private IP addresses, and communicate with the
      #     master via private networking.
      # @!attribute [rw] enable_private_endpoint
      #   @return [true, false]
      #     Whether the master's internal IP address is used as the cluster endpoint.
      # @!attribute [rw] master_ipv4_cidr_block
      #   @return [String]
      #     The IP prefix in CIDR notation to use for the hosted master network. This
      #     prefix will be used for assigning private IP addresses to the master or
      #     set of masters, as well as the ILB VIP.
      # @!attribute [rw] private_endpoint
      #   @return [String]
      #     Output only. The internal IP address of this cluster's endpoint.
      # @!attribute [rw] public_endpoint
      #   @return [String]
      #     Output only. The external IP address of this cluster's endpoint.
      class PrivateClusterConfig; end

      # Configuration options for the master authorized networks feature. Enabled
      # master authorized networks will disallow all external traffic to access
      # Kubernetes master through HTTPS except traffic from the given CIDR blocks,
      # Google Compute Engine Public IPs and Google Prod IPs.
      # @!attribute [rw] enabled
      #   @return [true, false]
      #     Whether or not master authorized networks is enabled.
      # @!attribute [rw] cidr_blocks
      #   @return [Array<Google::Container::V1alpha1::MasterAuthorizedNetworksConfig::CidrBlock>]
      #     cidr_blocks define up to 10 external networks that could access
      #     Kubernetes master through HTTPS.
      class MasterAuthorizedNetworksConfig
        # CidrBlock contains an optional name and one CIDR block.
        # @!attribute [rw] display_name
        #   @return [String]
        #     display_name is an optional field for users to identify CIDR blocks.
        # @!attribute [rw] cidr_block
        #   @return [String]
        #     cidr_block must be specified in CIDR notation.
        class CidrBlock; end
      end

      # Configuration options for the NetworkPolicy feature.
      # https://kubernetes.io/docs/concepts/services-networking/networkpolicies/
      # @!attribute [rw] provider
      #   @return [Google::Container::V1alpha1::NetworkPolicy::Provider]
      #     The selected network policy provider.
      # @!attribute [rw] enabled
      #   @return [true, false]
      #     Whether network policy is enabled on the cluster.
      class NetworkPolicy
        # Allowed Network Policy providers.
        module Provider
          # Not set
          PROVIDER_UNSPECIFIED = 0

          # Tigera (Calico Felix).
          CALICO = 1
        end
      end

      # Configuration for controlling how IPs are allocated in the cluster.
      # @!attribute [rw] use_ip_aliases
      #   @return [true, false]
      #     Whether alias IPs will be used for pod IPs in the cluster.
      # @!attribute [rw] create_subnetwork
      #   @return [true, false]
      #     Whether a new subnetwork will be created automatically for the cluster.
      #
      #     This field is only applicable when `use_ip_aliases` is true.
      # @!attribute [rw] subnetwork_name
      #   @return [String]
      #     A custom subnetwork name to be used if `create_subnetwork` is true.  If
      #     this field is empty, then an automatic name will be chosen for the new
      #     subnetwork.
      # @!attribute [rw] cluster_ipv4_cidr
      #   @return [String]
      #     This field is deprecated, use cluster_ipv4_cidr_block.
      # @!attribute [rw] node_ipv4_cidr
      #   @return [String]
      #     This field is deprecated, use node_ipv4_cidr_block.
      # @!attribute [rw] services_ipv4_cidr
      #   @return [String]
      #     This field is deprecated, use services_ipv4_cidr_block.
      # @!attribute [rw] cluster_secondary_range_name
      #   @return [String]
      #     The name of the secondary range to be used for the cluster CIDR
      #     block.  The secondary range will be used for pod IP
      #     addresses. This must be an existing secondary range associated
      #     with the cluster subnetwork.
      #
      #     This field is only applicable if use_ip_aliases is true and
      #     create_subnetwork is false.
      # @!attribute [rw] services_secondary_range_name
      #   @return [String]
      #     The name of the secondary range to be used as for the services
      #     CIDR block.  The secondary range will be used for service
      #     ClusterIPs. This must be an existing secondary range associated
      #     with the cluster subnetwork.
      #
      #     This field is only applicable with use_ip_aliases is true and
      #     create_subnetwork is false.
      # @!attribute [rw] cluster_ipv4_cidr_block
      #   @return [String]
      #     The IP address range for the cluster pod IPs. If this field is set, then
      #     `cluster.cluster_ipv4_cidr` must be left blank.
      #
      #     This field is only applicable when `use_ip_aliases` is true.
      #
      #     Set to blank to have a range chosen with the default size.
      #
      #     Set to /netmask (e.g. `/14`) to have a range chosen with a specific
      #     netmask.
      #
      #     Set to a
      #     [CIDR](http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
      #     notation (e.g. `10.96.0.0/14`) from the RFC-1918 private networks (e.g.
      #     `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) to pick a specific range
      #     to use.
      # @!attribute [rw] node_ipv4_cidr_block
      #   @return [String]
      #     The IP address range of the instance IPs in this cluster.
      #
      #     This is applicable only if `create_subnetwork` is true.
      #
      #     Set to blank to have a range chosen with the default size.
      #
      #     Set to /netmask (e.g. `/14`) to have a range chosen with a specific
      #     netmask.
      #
      #     Set to a
      #     [CIDR](http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
      #     notation (e.g. `10.96.0.0/14`) from the RFC-1918 private networks (e.g.
      #     `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) to pick a specific range
      #     to use.
      # @!attribute [rw] services_ipv4_cidr_block
      #   @return [String]
      #     The IP address range of the services IPs in this cluster. If blank, a range
      #     will be automatically chosen with the default size.
      #
      #     This field is only applicable when `use_ip_aliases` is true.
      #
      #     Set to blank to have a range chosen with the default size.
      #
      #     Set to /netmask (e.g. `/14`) to have a range chosen with a specific
      #     netmask.
      #
      #     Set to a
      #     [CIDR](http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
      #     notation (e.g. `10.96.0.0/14`) from the RFC-1918 private networks (e.g.
      #     `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) to pick a specific range
      #     to use.
      # @!attribute [rw] allow_route_overlap
      #   @return [true, false]
      #     If true, allow allocation of cluster CIDR ranges that overlap with certain
      #     kinds of network routes. By default we do not allow cluster CIDR ranges to
      #     intersect with any user declared routes. With allow_route_overlap == true,
      #     we allow overlapping with CIDR ranges that are larger than the cluster CIDR
      #     range.
      #
      #     If this field is set to true, then cluster and services CIDRs must be
      #     fully-specified (e.g. `10.96.0.0/14`, but not `/14`), which means:
      #     1) When `use_ip_aliases` is true, `cluster_ipv4_cidr_block` and
      #        `services_ipv4_cidr_block` must be fully-specified.
      #     2) When `use_ip_aliases` is false, `cluster.cluster_ipv4_cidr` muse be
      #        fully-specified.
      class IPAllocationPolicy; end

      # Configuration for Binary Authorization.
      # @!attribute [rw] enabled
      #   @return [true, false]
      #     Enable Binary Authorization for this cluster. If enabled, all container
      #     images will be validated by Google Binauthz.
      class BinaryAuthorization; end

      # Configuration for the PodSecurityPolicy feature.
      # @!attribute [rw] enabled
      #   @return [true, false]
      #     Enable the PodSecurityPolicy controller for this cluster. If enabled, pods
      #     must be valid under a PodSecurityPolicy to be created.
      class PodSecurityPolicyConfig; end

      # Configuration for the use of GCP IAM Service Accounts in applications in
      # this cluster.
      # @!attribute [rw] enabled
      #   @return [true, false]
      #     Enable the use of GCP IAM Service Accounts in applications in this cluster.
      class ManagedPodIdentityConfig; end

      # StatusCondition describes why a cluster or a node pool has a certain status
      # (e.g., ERROR or DEGRADED).
      # @!attribute [rw] code
      #   @return [Google::Container::V1alpha1::StatusCondition::Code]
      #     Machine-friendly representation of the condition
      # @!attribute [rw] message
      #   @return [String]
      #     Human-friendly representation of the condition
      class StatusCondition
        # Code for each condition
        module Code
          # UNKNOWN indicates a generic condition.
          UNKNOWN = 0

          # GCE_STOCKOUT indicates a GCE stockout.
          GCE_STOCKOUT = 1

          # GKE_SERVICE_ACCOUNT_DELETED indicates that the user deleted their robot
          # service account.
          # More codes TBA
          GKE_SERVICE_ACCOUNT_DELETED = 2
        end
      end

      # A Google Kubernetes Engine cluster.
      # @!attribute [rw] name
      #   @return [String]
      #     The name of this cluster. The name must be unique within this project
      #     and zone, and can be up to 40 characters with the following restrictions:
      #
      #     * Lowercase letters, numbers, and hyphens only.
      #     * Must start with a letter.
      #     * Must end with a number or a letter.
      # @!attribute [rw] description
      #   @return [String]
      #     An optional description of this cluster.
      # @!attribute [rw] initial_node_count
      #   @return [Integer]
      #     The number of nodes to create in this cluster. You must ensure that your
      #     Compute Engine <a href="/compute/docs/resource-quotas">resource quota</a>
      #     is sufficient for this number of instances. You must also have available
      #     firewall and routes quota.
      #     For requests, this field should only be used in lieu of a
      #     "node_pool" object, since this configuration (along with the
      #     "node_config") will be used to create a "NodePool" object with an
      #     auto-generated name. Do not use this and a node_pool at the same time.
      # @!attribute [rw] node_config
      #   @return [Google::Container::V1alpha1::NodeConfig]
      #     Parameters used in creating the cluster's nodes.
      #     See `nodeConfig` for the description of its properties.
      #     For requests, this field should only be used in lieu of a
      #     "node_pool" object, since this configuration (along with the
      #     "initial_node_count") will be used to create a "NodePool" object with an
      #     auto-generated name. Do not use this and a node_pool at the same time.
      #     For responses, this field will be populated with the node configuration of
      #     the first node pool.
      #
      #     If unspecified, the defaults are used.
      # @!attribute [rw] master_auth
      #   @return [Google::Container::V1alpha1::MasterAuth]
      #     The authentication information for accessing the master endpoint.
      # @!attribute [rw] logging_service
      #   @return [String]
      #     The logging service the cluster should use to write logs.
      #     Currently available options:
      #
      #     * `logging.googleapis.com` - the Google Cloud Logging service.
      #     * `none` - no logs will be exported from the cluster.
      #     * if left as an empty string,`logging.googleapis.com` will be used.
      # @!attribute [rw] monitoring_service
      #   @return [String]
      #     The monitoring service the cluster should use to write metrics.
      #     Currently available options:
      #
      #     * `monitoring.googleapis.com` - the Google Cloud Monitoring service.
      #     * `none` - no metrics will be exported from the cluster.
      #     * if left as an empty string, `monitoring.googleapis.com` will be used.
      # @!attribute [rw] network
      #   @return [String]
      #     The name of the Google Compute Engine
      #     [network](https://cloud.google.com/compute/docs/networks-and-firewalls#networks) to which the
      #     cluster is connected. If left unspecified, the `default` network
      #     will be used.
      # @!attribute [rw] cluster_ipv4_cidr
      #   @return [String]
      #     The IP address range of the container pods in this cluster, in
      #     [CIDR](http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
      #     notation (e.g. `10.96.0.0/14`). Leave blank to have
      #     one automatically chosen or specify a `/14` block in `10.0.0.0/8`.
      # @!attribute [rw] addons_config
      #   @return [Google::Container::V1alpha1::AddonsConfig]
      #     Configurations for the various addons available to run in the cluster.
      # @!attribute [rw] subnetwork
      #   @return [String]
      #     The name of the Google Compute Engine
      #     [subnetwork](https://cloud.google.com/compute/docs/subnetworks) to which the
      #     cluster is connected. On output this shows the subnetwork ID instead of
      #     the name.
      # @!attribute [rw] node_pools
      #   @return [Array<Google::Container::V1alpha1::NodePool>]
      #     The node pools associated with this cluster.
      #     This field should not be set if "node_config" or "initial_node_count" are
      #     specified.
      # @!attribute [rw] locations
      #   @return [Array<String>]
      #     The list of Google Compute Engine
      #     [locations](https://cloud.google.com/compute/docs/zones#available) in which the cluster's nodes
      #     should be located.
      # @!attribute [rw] enable_kubernetes_alpha
      #   @return [true, false]
      #     Kubernetes alpha features are enabled on this cluster. This includes alpha
      #     API groups (e.g. v1alpha1) and features that may not be production ready in
      #     the kubernetes version of the master and nodes.
      #     The cluster has no SLA for uptime and master/node upgrades are disabled.
      #     Alpha enabled clusters are automatically deleted thirty days after
      #     creation.
      # @!attribute [rw] network_policy
      #   @return [Google::Container::V1alpha1::NetworkPolicy]
      #     Configuration options for the NetworkPolicy feature.
      # @!attribute [rw] ip_allocation_policy
      #   @return [Google::Container::V1alpha1::IPAllocationPolicy]
      #     Configuration for cluster IP allocation.
      # @!attribute [rw] master_authorized_networks_config
      #   @return [Google::Container::V1alpha1::MasterAuthorizedNetworksConfig]
      #     The configuration options for master authorized networks feature.
      # @!attribute [rw] maintenance_policy
      #   @return [Google::Container::V1alpha1::MaintenancePolicy]
      #     Configure the maintenance policy for this cluster.
      # @!attribute [rw] binary_authorization
      #   @return [Google::Container::V1alpha1::BinaryAuthorization]
      #     Configuration for Binary Authorization.
      # @!attribute [rw] pod_security_policy_config
      #   @return [Google::Container::V1alpha1::PodSecurityPolicyConfig]
      #     Configuration for the PodSecurityPolicy feature.
      # @!attribute [rw] autoscaling
      #   @return [Google::Container::V1alpha1::ClusterAutoscaling]
      #     Cluster-level autoscaling configuration.
      # @!attribute [rw] managed_pod_identity_config
      #   @return [Google::Container::V1alpha1::ManagedPodIdentityConfig]
      #     Configuration for the use of GCP IAM Service Accounts in applications in
      #     this cluster.
      # @!attribute [rw] node_scheduling_strategy
      #   @return [Google::Container::V1alpha1::Cluster::NodeSchedulingStrategy]
      #     Defines behaviour of k8s scheduler.
      # @!attribute [rw] private_cluster_config
      #   @return [Google::Container::V1alpha1::PrivateClusterConfig]
      #     Configuration for private cluster.
      # @!attribute [rw] self_link
      #   @return [String]
      #     [Output only] Server-defined URL for the resource.
      # @!attribute [rw] zone
      #   @return [String]
      #     [Output only] The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field is deprecated, use location instead.
      # @!attribute [rw] endpoint
      #   @return [String]
      #     [Output only] The IP address of this cluster's master endpoint.
      #     The endpoint can be accessed from the internet at
      #     `https://username:password@endpoint/`.
      #
      #     See the `masterAuth` property of this resource for username and
      #     password information.
      # @!attribute [rw] initial_cluster_version
      #   @return [String]
      #     The initial Kubernetes version for this cluster.  Valid versions are those
      #     found in validMasterVersions returned by getServerConfig.  The version can
      #     be upgraded over time; such upgrades are reflected in
      #     currentMasterVersion and currentNodeVersion.
      #
      #     Users may specify either explicit versions offered by
      #     Kubernetes Engine or version aliases, which have the following behavior:
      #
      #     * "latest": picks the highest valid Kubernetes version
      #     * "1.X": picks the highest valid patch+gke.N patch in the 1.X version
      #     * "1.X.Y": picks the highest valid gke.N patch in the 1.X.Y version
      #     * "1.X.Y-gke.N": picks an explicit Kubernetes version
      #     * "","-": picks the default Kubernetes version
      # @!attribute [rw] current_master_version
      #   @return [String]
      #     [Output only] The current software version of the master endpoint.
      # @!attribute [rw] current_node_version
      #   @return [String]
      #     [Output only] Deprecated, use
      #     [NodePool.version](https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1alpha1/projects.zones.clusters.nodePool)
      #     instead. The current version of the node software components.
      #     If they are currently at multiple versions because they're in the process
      #     of being upgraded, this reflects the minimum version of all nodes.
      # @!attribute [rw] create_time
      #   @return [String]
      #     [Output only] The time the cluster was created, in
      #     [RFC3339](https://www.ietf.org/rfc/rfc3339.txt) text format.
      # @!attribute [rw] status
      #   @return [Google::Container::V1alpha1::Cluster::Status]
      #     [Output only] The current status of this cluster.
      # @!attribute [rw] status_message
      #   @return [String]
      #     [Output only] Additional information about the current status of this
      #     cluster, if available.
      #     Deprecated, use the field conditions instead.
      # @!attribute [rw] node_ipv4_cidr_size
      #   @return [Integer]
      #     [Output only] The size of the address space on each node for hosting
      #     containers. This is provisioned from within the `container_ipv4_cidr`
      #     range.
      # @!attribute [rw] services_ipv4_cidr
      #   @return [String]
      #     [Output only] The IP address range of the Kubernetes services in
      #     this cluster, in
      #     [CIDR](http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
      #     notation (e.g. `1.2.3.4/29`). Service addresses are
      #     typically put in the last `/16` from the container CIDR.
      # @!attribute [rw] instance_group_urls
      #   @return [Array<String>]
      #     Deprecated. Use node_pools.instance_group_urls.
      # @!attribute [rw] current_node_count
      #   @return [Integer]
      #     [Output only] The number of nodes currently in the cluster.
      # @!attribute [rw] expire_time
      #   @return [String]
      #     [Output only] The time the cluster will be automatically
      #     deleted in [RFC3339](https://www.ietf.org/rfc/rfc3339.txt) text format.
      # @!attribute [rw] location
      #   @return [String]
      #     [Output only] The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones#available) or
      #     [region](https://cloud.google.com/compute/docs/regions-zones/regions-zones#available) in which
      #     the cluster resides.
      # @!attribute [rw] conditions
      #   @return [Array<Google::Container::V1alpha1::StatusCondition>]
      #     Which conditions caused the current cluster state.
      class Cluster
        # The current status of the cluster.
        module Status
          # Not set.
          STATUS_UNSPECIFIED = 0

          # The PROVISIONING state indicates the cluster is being created.
          PROVISIONING = 1

          # The RUNNING state indicates the cluster has been created and is fully
          # usable.
          RUNNING = 2

          # The RECONCILING state indicates that some work is actively being done on
          # the cluster, such as upgrading the master or node software. Details can
          # be found in the `statusMessage` field.
          RECONCILING = 3

          # The STOPPING state indicates the cluster is being deleted.
          STOPPING = 4

          # The ERROR state indicates the cluster may be unusable. Details
          # can be found in the `statusMessage` field.
          ERROR = 5

          # The DEGRADED state indicates the cluster requires user action to restore
          # full functionality. Details can be found in the `statusMessage` field.
          DEGRADED = 6
        end

        # Defines possible options for node_scheduling_strategy field.
        module NodeSchedulingStrategy
          # Use default scheduling strategy.
          STRATEGY_UNSPECIFIED = 0

          # Least utilized nodes will be prioritized by k8s scheduler.
          PRIORITIZE_LEAST_UTILIZED = 1

          # Nodes with medium utilization will be prioritized by k8s scheduler.
          # This option improves interoperability of scheduler with cluster
          # autoscaler.
          PRIORITIZE_MEDIUM_UTILIZED = 2
        end
      end

      # ClusterUpdate describes an update to the cluster. Exactly one update can
      # be applied to a cluster with each request, so at most one field can be
      # provided.
      # @!attribute [rw] desired_node_version
      #   @return [String]
      #     The Kubernetes version to change the nodes to (typically an
      #     upgrade).
      #
      #     Users may specify either explicit versions offered by
      #     Kubernetes Engine or version aliases, which have the following behavior:
      #
      #     * "latest": picks the highest valid Kubernetes version
      #     * "1.X": picks the highest valid patch+gke.N patch in the 1.X version
      #     * "1.X.Y": picks the highest valid gke.N patch in the 1.X.Y version
      #     * "1.X.Y-gke.N": picks an explicit Kubernetes version
      #     * "-": picks the Kubernetes master version
      # @!attribute [rw] desired_monitoring_service
      #   @return [String]
      #     The monitoring service the cluster should use to write metrics.
      #     Currently available options:
      #
      #     * "monitoring.googleapis.com/kubernetes" - the Google Cloud Monitoring
      #       service with Kubernetes-native resource model in Stackdriver
      #     * "monitoring.googleapis.com" - the Google Cloud Monitoring service
      #     * "none" - no metrics will be exported from the cluster
      # @!attribute [rw] desired_addons_config
      #   @return [Google::Container::V1alpha1::AddonsConfig]
      #     Configurations for the various addons available to run in the cluster.
      # @!attribute [rw] desired_node_pool_id
      #   @return [String]
      #     The node pool to be upgraded. This field is mandatory if
      #     "desired_node_version", "desired_image_family" or
      #     "desired_node_pool_autoscaling" is specified and there is more than one
      #     node pool on the cluster.
      # @!attribute [rw] desired_image_type
      #   @return [String]
      #     The desired image type for the node pool.
      #     NOTE: Set the "desired_node_pool" field as well.
      # @!attribute [rw] desired_node_pool_autoscaling
      #   @return [Google::Container::V1alpha1::NodePoolAutoscaling]
      #     Autoscaler configuration for the node pool specified in
      #     desired_node_pool_id. If there is only one pool in the
      #     cluster and desired_node_pool_id is not provided then
      #     the change applies to that single node pool.
      # @!attribute [rw] desired_locations
      #   @return [Array<String>]
      #     The desired list of Google Compute Engine
      #     [locations](https://cloud.google.com/compute/docs/zones#available) in which the cluster's nodes
      #     should be located. Changing the locations a cluster is in will result
      #     in nodes being either created or removed from the cluster, depending on
      #     whether locations are being added or removed.
      #
      #     This list must always include the cluster's primary zone.
      # @!attribute [rw] desired_master_authorized_networks_config
      #   @return [Google::Container::V1alpha1::MasterAuthorizedNetworksConfig]
      #     The desired configuration options for master authorized networks feature.
      # @!attribute [rw] desired_pod_security_policy_config
      #   @return [Google::Container::V1alpha1::PodSecurityPolicyConfig]
      #     The desired configuration options for the PodSecurityPolicy feature.
      # @!attribute [rw] desired_cluster_autoscaling
      #   @return [Google::Container::V1alpha1::ClusterAutoscaling]
      #     The desired cluster-level autoscaling configuration.
      # @!attribute [rw] desired_binary_authorization
      #   @return [Google::Container::V1alpha1::BinaryAuthorization]
      #     The desired configuration options for the Binary Authorization feature.
      # @!attribute [rw] desired_logging_service
      #   @return [String]
      #     The logging service the cluster should use to write metrics.
      #     Currently available options:
      #
      #     * "logging.googleapis.com/kubernetes" - the Google Cloud Logging
      #       service with Kubernetes-native resource model in Stackdriver
      #     * "logging.googleapis.com" - the Google Cloud Logging service
      #     * "none" - no logs will be exported from the cluster
      # @!attribute [rw] desired_master_version
      #   @return [String]
      #     The Kubernetes version to change the master to.
      #
      #     Users may specify either explicit versions offered by
      #     Kubernetes Engine or version aliases, which have the following behavior:
      #
      #     * "latest": picks the highest valid Kubernetes version
      #     * "1.X": picks the highest valid patch+gke.N patch in the 1.X version
      #     * "1.X.Y": picks the highest valid gke.N patch in the 1.X.Y version
      #     * "1.X.Y-gke.N": picks an explicit Kubernetes version
      #     * "-": picks the default Kubernetes version
      class ClusterUpdate; end

      # This operation resource represents operations that may have happened or are
      # happening on the cluster. All fields are output only.
      # @!attribute [rw] name
      #   @return [String]
      #     The server-assigned ID for the operation.
      # @!attribute [rw] zone
      #   @return [String]
      #     The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the operation
      #     is taking place.
      #     This field is deprecated, use location instead.
      # @!attribute [rw] operation_type
      #   @return [Google::Container::V1alpha1::Operation::Type]
      #     The operation type.
      # @!attribute [rw] status
      #   @return [Google::Container::V1alpha1::Operation::Status]
      #     The current status of the operation.
      # @!attribute [rw] detail
      #   @return [String]
      #     Detailed operation progress, if available.
      # @!attribute [rw] status_message
      #   @return [String]
      #     If an error has occurred, a textual description of the error.
      #     Deprecated, use the field conditions instead.
      # @!attribute [rw] self_link
      #   @return [String]
      #     Server-defined URL for the resource.
      # @!attribute [rw] target_link
      #   @return [String]
      #     Server-defined URL for the target of the operation.
      # @!attribute [rw] location
      #   @return [String]
      #     [Output only] The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones#available) or
      #     [region](https://cloud.google.com/compute/docs/regions-zones/regions-zones#available) in which
      #     the cluster resides.
      # @!attribute [rw] start_time
      #   @return [String]
      #     [Output only] The time the operation started, in
      #     [RFC3339](https://www.ietf.org/rfc/rfc3339.txt) text format.
      # @!attribute [rw] end_time
      #   @return [String]
      #     [Output only] The time the operation completed, in
      #     [RFC3339](https://www.ietf.org/rfc/rfc3339.txt) text format.
      # @!attribute [rw] progress
      #   @return [Google::Container::V1alpha1::OperationProgress]
      #     [Output only] Progress information for an operation.
      # @!attribute [rw] cluster_conditions
      #   @return [Array<Google::Container::V1alpha1::StatusCondition>]
      #     Which conditions caused the current cluster state.
      # @!attribute [rw] nodepool_conditions
      #   @return [Array<Google::Container::V1alpha1::StatusCondition>]
      #     Which conditions caused the current node pool state.
      class Operation
        # Current status of the operation.
        module Status
          # Not set.
          STATUS_UNSPECIFIED = 0

          # The operation has been created.
          PENDING = 1

          # The operation is currently running.
          RUNNING = 2

          # The operation is done, either cancelled or completed.
          DONE = 3

          # The operation is aborting.
          ABORTING = 4
        end

        # Operation type.
        module Type
          # Not set.
          TYPE_UNSPECIFIED = 0

          # Cluster create.
          CREATE_CLUSTER = 1

          # Cluster delete.
          DELETE_CLUSTER = 2

          # A master upgrade.
          UPGRADE_MASTER = 3

          # A node upgrade.
          UPGRADE_NODES = 4

          # Cluster repair.
          REPAIR_CLUSTER = 5

          # Cluster update.
          UPDATE_CLUSTER = 6

          # Node pool create.
          CREATE_NODE_POOL = 7

          # Node pool delete.
          DELETE_NODE_POOL = 8

          # Set node pool management.
          SET_NODE_POOL_MANAGEMENT = 9

          # Automatic node pool repair.
          AUTO_REPAIR_NODES = 10

          # Automatic node upgrade.
          AUTO_UPGRADE_NODES = 11

          # Set labels.
          SET_LABELS = 12

          # Set/generate master auth materials
          SET_MASTER_AUTH = 13

          # Set node pool size.
          SET_NODE_POOL_SIZE = 14

          # Updates network policy for a cluster.
          SET_NETWORK_POLICY = 15

          # Set the maintenance policy.
          SET_MAINTENANCE_POLICY = 16

          # Update cluster IP allocation policy.
          UPDATE_IP_ALLOCATION_POLICY = 17
        end
      end

      # Information about operation (or operation stage) progress.
      # @!attribute [rw] name
      #   @return [String]
      #     A non-parameterized string describing an operation stage.
      #     Unset for single-stage operations.
      # @!attribute [rw] status
      #   @return [Google::Container::V1alpha1::Operation::Status]
      #     Status of an operation stage.
      #     Unset for single-stage operations.
      # @!attribute [rw] metrics
      #   @return [Array<Google::Container::V1alpha1::OperationProgress::Metric>]
      #     Progress metric bundle, for example:
      #       metrics: [{name: "nodes done",     int_value: 15},
      #                 {name: "nodes total",    int_value: 32}]
      #     or
      #       metrics: [{name: "progress",       double_value: 0.56},
      #                 {name: "progress scale", double_value: 1.0}]
      # @!attribute [rw] stages
      #   @return [Array<Google::Container::V1alpha1::OperationProgress>]
      #     Substages of an operation or a stage.
      class OperationProgress
        # Progress metric is (string, int|float|string) pair.
        # @!attribute [rw] name
        #   @return [String]
        #     Metric name, required.
        #     e.g., "nodes total", "percent done"
        # @!attribute [rw] int_value
        #   @return [Integer]
        #     For metrics with integer value.
        # @!attribute [rw] double_value
        #   @return [Float]
        #     For metrics with floating point value.
        # @!attribute [rw] string_value
        #   @return [String]
        #     For metrics with custom values (ratios, visual progress, etc.).
        class Metric; end
      end

      # CreateClusterRequest creates a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] cluster
      #   @return [Google::Container::V1alpha1::Cluster]
      #     A [cluster
      #     resource](/container-engine/reference/rest/v1alpha1/projects.zones.clusters)
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent (project and location) where the cluster will be created.
      #     Specified in the format 'projects/*/locations/*'.
      class CreateClusterRequest; end

      # GetClusterRequest gets the settings of a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to retrieve.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to retrieve.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class GetClusterRequest; end

      # UpdateClusterRequest updates the settings of a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] update
      #   @return [Google::Container::V1alpha1::ClusterUpdate]
      #     A description of the update.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to update.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class UpdateClusterRequest; end

      # SetNodePoolVersionRequest updates the version of a node pool.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_pool_id
      #   @return [String]
      #     Deprecated. The name of the node pool to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_version
      #   @return [String]
      #     The Kubernetes version to change the nodes to (typically an
      #     upgrade).
      #
      #     Users may specify either explicit versions offered by Kubernetes Engine or
      #     version aliases, which have the following behavior:
      #
      #     * "latest": picks the highest valid Kubernetes version
      #     * "1.X": picks the highest valid patch+gke.N patch in the 1.X version
      #     * "1.X.Y": picks the highest valid gke.N patch in the 1.X.Y version
      #     * "1.X.Y-gke.N": picks an explicit Kubernetes version
      #     * "-": picks the Kubernetes master version
      # @!attribute [rw] image_type
      #   @return [String]
      #     The desired image type for the node pool.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster, node pool) of the node pool to
      #     update. Specified in the format
      #     'projects/*/locations/*/clusters/*/nodePools/*'.
      class UpdateNodePoolRequest; end

      # SetNodePoolAutoscalingRequest sets the autoscaler settings of a node pool.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_pool_id
      #   @return [String]
      #     Deprecated. The name of the node pool to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] autoscaling
      #   @return [Google::Container::V1alpha1::NodePoolAutoscaling]
      #     Autoscaling configuration for the node pool.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster, node pool) of the node pool to set
      #     autoscaler settings. Specified in the format
      #     'projects/*/locations/*/clusters/*/nodePools/*'.
      class SetNodePoolAutoscalingRequest; end

      # SetLoggingServiceRequest sets the logging service of a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] logging_service
      #   @return [String]
      #     The logging service the cluster should use to write metrics.
      #     Currently available options:
      #
      #     * "logging.googleapis.com" - the Google Cloud Logging service
      #     * "none" - no metrics will be exported from the cluster
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to set logging.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetLoggingServiceRequest; end

      # SetMonitoringServiceRequest sets the monitoring service of a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] monitoring_service
      #   @return [String]
      #     The monitoring service the cluster should use to write metrics.
      #     Currently available options:
      #
      #     * "monitoring.googleapis.com" - the Google Cloud Monitoring service
      #     * "none" - no metrics will be exported from the cluster
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to set monitoring.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetMonitoringServiceRequest; end

      # SetAddonsRequest sets the addons associated with the cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] addons_config
      #   @return [Google::Container::V1alpha1::AddonsConfig]
      #     The desired configurations for the various addons available to run in the
      #     cluster.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to set addons.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetAddonsConfigRequest; end

      # SetLocationsRequest sets the locations of the cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] locations
      #   @return [Array<String>]
      #     The desired list of Google Compute Engine
      #     [locations](https://cloud.google.com/compute/docs/zones#available) in which the cluster's nodes
      #     should be located. Changing the locations a cluster is in will result
      #     in nodes being either created or removed from the cluster, depending on
      #     whether locations are being added or removed.
      #
      #     This list must always include the cluster's primary zone.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to set locations.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetLocationsRequest; end

      # UpdateMasterRequest updates the master of the cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] master_version
      #   @return [String]
      #     The Kubernetes version to change the master to.
      #
      #     Users may specify either explicit versions offered by Kubernetes Engine or
      #     version aliases, which have the following behavior:
      #
      #     * "latest": picks the highest valid Kubernetes version
      #     * "1.X": picks the highest valid patch+gke.N patch in the 1.X version
      #     * "1.X.Y": picks the highest valid gke.N patch in the 1.X.Y version
      #     * "1.X.Y-gke.N": picks an explicit Kubernetes version
      #     * "-": picks the default Kubernetes version
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to update.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class UpdateMasterRequest; end

      # SetMasterAuthRequest updates the admin password of a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to upgrade.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] action
      #   @return [Google::Container::V1alpha1::SetMasterAuthRequest::Action]
      #     The exact form of action to be taken on the master auth.
      # @!attribute [rw] update
      #   @return [Google::Container::V1alpha1::MasterAuth]
      #     A description of the update.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to set auth.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetMasterAuthRequest
        # Operation type: what type update to perform.
        module Action
          # Operation is unknown and will error out.
          UNKNOWN = 0

          # Set the password to a user generated value.
          SET_PASSWORD = 1

          # Generate a new password and set it to that.
          GENERATE_PASSWORD = 2

          # Set the username.  If an empty username is provided, basic authentication
          # is disabled for the cluster.  If a non-empty username is provided, basic
          # authentication is enabled, with either a provided password or a generated
          # one.
          SET_USERNAME = 3
        end
      end

      # DeleteClusterRequest deletes a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to delete.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster) of the cluster to delete.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class DeleteClusterRequest; end

      # ListClustersRequest lists clusters.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides, or "-" for all zones.
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent (project and location) where the clusters will be listed.
      #     Specified in the format 'projects/*/locations/*'.
      #     Location "-" matches all zones and all regions.
      class ListClustersRequest; end

      # ListClustersResponse is the result of ListClustersRequest.
      # @!attribute [rw] clusters
      #   @return [Array<Google::Container::V1alpha1::Cluster>]
      #     A list of clusters in the project in the specified zone, or
      #     across all ones.
      # @!attribute [rw] missing_zones
      #   @return [Array<String>]
      #     If any zones are listed here, the list of clusters returned
      #     may be missing those zones.
      class ListClustersResponse; end

      # GetOperationRequest gets a single operation.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] operation_id
      #   @return [String]
      #     Deprecated. The server-assigned `name` of the operation.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, operation id) of the operation to get.
      #     Specified in the format 'projects/*/locations/*/operations/*'.
      class GetOperationRequest; end

      # ListOperationsRequest lists operations.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) to return operations for, or `-` for
      #     all zones. This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent (project and location) where the operations will be listed.
      #     Specified in the format 'projects/*/locations/*'.
      #     Location "-" matches all zones and all regions.
      class ListOperationsRequest; end

      # CancelOperationRequest cancels a single operation.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the operation resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] operation_id
      #   @return [String]
      #     Deprecated. The server-assigned `name` of the operation.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, operation id) of the operation to cancel.
      #     Specified in the format 'projects/*/locations/*/operations/*'.
      class CancelOperationRequest; end

      # ListOperationsResponse is the result of ListOperationsRequest.
      # @!attribute [rw] operations
      #   @return [Array<Google::Container::V1alpha1::Operation>]
      #     A list of operations in the project in the specified zone.
      # @!attribute [rw] missing_zones
      #   @return [Array<String>]
      #     If any zones are listed here, the list of operations returned
      #     may be missing the operations from those zones.
      class ListOperationsResponse; end

      # Gets the current Kubernetes Engine service configuration.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) to return operations for.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project and location) of the server config to get
      #     Specified in the format 'projects/*/locations/*'.
      class GetServerConfigRequest; end

      # Kubernetes Engine service configuration.
      # @!attribute [rw] default_cluster_version
      #   @return [String]
      #     Version of Kubernetes the service deploys by default.
      # @!attribute [rw] valid_node_versions
      #   @return [Array<String>]
      #     List of valid node upgrade target versions.
      # @!attribute [rw] default_image_type
      #   @return [String]
      #     Default image type.
      # @!attribute [rw] valid_image_types
      #   @return [Array<String>]
      #     List of valid image types.
      # @!attribute [rw] valid_master_versions
      #   @return [Array<String>]
      #     List of valid master versions.
      class ServerConfig; end

      # CreateNodePoolRequest creates a node pool for a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster.
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] node_pool
      #   @return [Google::Container::V1alpha1::NodePool]
      #     The node pool to create.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent (project, location, cluster id) where the node pool will be
      #     created. Specified in the format
      #     'projects/*/locations/*/clusters/*'.
      class CreateNodePoolRequest; end

      # DeleteNodePoolRequest deletes a node pool for a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecate. The name of the cluster.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_pool_id
      #   @return [String]
      #     Deprecated. The name of the node pool to delete.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster, node pool id) of the node pool to
      #     delete. Specified in the format
      #     'projects/*/locations/*/clusters/*/nodePools/*'.
      class DeleteNodePoolRequest; end

      # ListNodePoolsRequest lists the node pool(s) for a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster.
      #     This field has been deprecated and replaced by the parent field.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent (project, location, cluster id) where the node pools will be
      #     listed. Specified in the format 'projects/*/locations/*/clusters/*'.
      class ListNodePoolsRequest; end

      # GetNodePoolRequest retrieves a node pool for a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_pool_id
      #   @return [String]
      #     Deprecated. The name of the node pool.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster, node pool id) of the node pool to
      #     get. Specified in the format
      #     'projects/*/locations/*/clusters/*/nodePools/*'.
      class GetNodePoolRequest; end

      # NodePool contains the name and configuration for a cluster's node pool.
      # Node pools are a set of nodes (i.e. VM's), with a common configuration and
      # specification, under the control of the cluster master. They may have a set
      # of Kubernetes labels applied to them, which may be used to reference them
      # during pod scheduling. They may also be resized up or down, to accommodate
      # the workload.
      # @!attribute [rw] name
      #   @return [String]
      #     The name of the node pool.
      # @!attribute [rw] config
      #   @return [Google::Container::V1alpha1::NodeConfig]
      #     The node configuration of the pool.
      # @!attribute [rw] initial_node_count
      #   @return [Integer]
      #     The initial node count for the pool. You must ensure that your
      #     Compute Engine <a href="/compute/docs/resource-quotas">resource quota</a>
      #     is sufficient for this number of instances. You must also have available
      #     firewall and routes quota.
      # @!attribute [rw] autoscaling
      #   @return [Google::Container::V1alpha1::NodePoolAutoscaling]
      #     Autoscaler configuration for this NodePool. Autoscaler is enabled
      #     only if a valid configuration is present.
      # @!attribute [rw] management
      #   @return [Google::Container::V1alpha1::NodeManagement]
      #     NodeManagement configuration for this NodePool.
      # @!attribute [rw] self_link
      #   @return [String]
      #     [Output only] Server-defined URL for the resource.
      # @!attribute [rw] version
      #   @return [String]
      #     The version of the Kubernetes of this node.
      # @!attribute [rw] instance_group_urls
      #   @return [Array<String>]
      #     [Output only] The resource URLs of the [managed instance
      #     groups](/compute/docs/instance-groups/creating-groups-of-managed-instances)
      #     associated with this node pool.
      # @!attribute [rw] status
      #   @return [Google::Container::V1alpha1::NodePool::Status]
      #     [Output only] The status of the nodes in this pool instance.
      # @!attribute [rw] status_message
      #   @return [String]
      #     [Output only] Additional information about the current status of this
      #     node pool instance, if available.
      #     Deprecated, use the field conditions instead.
      # @!attribute [rw] conditions
      #   @return [Array<Google::Container::V1alpha1::StatusCondition>]
      #     Which conditions caused the current node pool state.
      class NodePool
        # The current status of the node pool instance.
        module Status
          # Not set.
          STATUS_UNSPECIFIED = 0

          # The PROVISIONING state indicates the node pool is being created.
          PROVISIONING = 1

          # The RUNNING state indicates the node pool has been created
          # and is fully usable.
          RUNNING = 2

          # The RUNNING_WITH_ERROR state indicates the node pool has been created
          # and is partially usable. Some error state has occurred and some
          # functionality may be impaired. Customer may need to reissue a request
          # or trigger a new update.
          RUNNING_WITH_ERROR = 3

          # The RECONCILING state indicates that some work is actively being done on
          # the node pool, such as upgrading node software. Details can
          # be found in the `statusMessage` field.
          RECONCILING = 4

          # The STOPPING state indicates the node pool is being deleted.
          STOPPING = 5

          # The ERROR state indicates the node pool may be unusable. Details
          # can be found in the `statusMessage` field.
          ERROR = 6
        end
      end

      # NodeManagement defines the set of node management services turned on for the
      # node pool.
      # @!attribute [rw] auto_upgrade
      #   @return [true, false]
      #     Whether the nodes will be automatically upgraded.
      # @!attribute [rw] auto_repair
      #   @return [true, false]
      #     Whether the nodes will be automatically repaired.
      # @!attribute [rw] upgrade_options
      #   @return [Google::Container::V1alpha1::AutoUpgradeOptions]
      #     Specifies the Auto Upgrade knobs for the node pool.
      class NodeManagement; end

      # AutoUpgradeOptions defines the set of options for the user to control how
      # the Auto Upgrades will proceed.
      # @!attribute [rw] auto_upgrade_start_time
      #   @return [String]
      #     [Output only] This field is set when upgrades are about to commence
      #     with the approximate start time for the upgrades, in
      #     [RFC3339](https://www.ietf.org/rfc/rfc3339.txt) text format.
      # @!attribute [rw] description
      #   @return [String]
      #     [Output only] This field is set when upgrades are about to commence
      #     with the description of the upgrade.
      class AutoUpgradeOptions; end

      # MaintenancePolicy defines the maintenance policy to be used for the cluster.
      # @!attribute [rw] window
      #   @return [Google::Container::V1alpha1::MaintenanceWindow]
      #     Specifies the maintenance window in which maintenance may be performed.
      class MaintenancePolicy; end

      # MaintenanceWindow defines the maintenance window to be used for the cluster.
      # @!attribute [rw] daily_maintenance_window
      #   @return [Google::Container::V1alpha1::DailyMaintenanceWindow]
      #     DailyMaintenanceWindow specifies a daily maintenance operation window.
      class MaintenanceWindow; end

      # Time window specified for daily maintenance operations.
      # @!attribute [rw] start_time
      #   @return [String]
      #     Time within the maintenance window to start the maintenance operations.
      #     It must be in format "HH:MM”, where HH : [00-23] and MM : [00-59] GMT.
      # @!attribute [rw] duration
      #   @return [String]
      #     [Output only] Duration of the time window, automatically chosen to be
      #     smallest possible in the given scenario.
      class DailyMaintenanceWindow; end

      # SetNodePoolManagementRequest sets the node management properties of a node
      # pool.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to update.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_pool_id
      #   @return [String]
      #     Deprecated. The name of the node pool to update.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] management
      #   @return [Google::Container::V1alpha1::NodeManagement]
      #     NodeManagement configuration for the node pool.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster, node pool id) of the node pool to set
      #     management properties. Specified in the format
      #     'projects/*/locations/*/clusters/*/nodePools/*'.
      class SetNodePoolManagementRequest; end

      # SetNodePoolSizeRequest sets the size a node
      # pool.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to update.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_pool_id
      #   @return [String]
      #     Deprecated. The name of the node pool to update.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_count
      #   @return [Integer]
      #     The desired node count for the pool.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster, node pool id) of the node pool to set
      #     size.
      #     Specified in the format 'projects/*/locations/*/clusters/*/nodePools/*'.
      class SetNodePoolSizeRequest; end

      # RollbackNodePoolUpgradeRequest rollbacks the previously Aborted or Failed
      # NodePool upgrade. This will be an no-op if the last upgrade successfully
      # completed.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to rollback.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] node_pool_id
      #   @return [String]
      #     Deprecated. The name of the node pool to rollback.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster, node pool id) of the node poll to
      #     rollback upgrade.
      #     Specified in the format 'projects/*/locations/*/clusters/*/nodePools/*'.
      class RollbackNodePoolUpgradeRequest; end

      # ListNodePoolsResponse is the result of ListNodePoolsRequest.
      # @!attribute [rw] node_pools
      #   @return [Array<Google::Container::V1alpha1::NodePool>]
      #     A list of node pools for a cluster.
      class ListNodePoolsResponse; end

      # ClusterAutoscaling contains global, per-cluster information
      # required by Cluster Autoscaler to automatically adjust
      # the size of the cluster and create/delete
      # node pools based on the current needs.
      # @!attribute [rw] enable_node_autoprovisioning
      #   @return [true, false]
      #     Enables automatic node pool creation and deletion.
      # @!attribute [rw] resource_limits
      #   @return [Array<Google::Container::V1alpha1::ResourceLimit>]
      #     Contains global constraints regarding minimum and maximum
      #     amount of resources in the cluster.
      class ClusterAutoscaling; end

      # Contains information about amount of some resource in the cluster.
      # For memory, value should be in GB.
      # @!attribute [rw] resource_type
      #   @return [String]
      #     Resource name "cpu", "memory" or gpu-specific string.
      # @!attribute [rw] minimum
      #   @return [Integer]
      #     Minimum amount of the resource in the cluster.
      # @!attribute [rw] maximum
      #   @return [Integer]
      #     Maximum amount of the resource in the cluster.
      class ResourceLimit; end

      # NodePoolAutoscaling contains information required by cluster autoscaler to
      # adjust the size of the node pool to the current cluster usage.
      # @!attribute [rw] enabled
      #   @return [true, false]
      #     Is autoscaling enabled for this node pool.
      # @!attribute [rw] min_node_count
      #   @return [Integer]
      #     Minimum number of nodes in the NodePool. Must be >= 1 and <=
      #     max_node_count.
      # @!attribute [rw] max_node_count
      #   @return [Integer]
      #     Maximum number of nodes in the NodePool. Must be >= min_node_count. There
      #     has to enough quota to scale up the cluster.
      # @!attribute [rw] autoprovisioned
      #   @return [true, false]
      #     Can this node pool be deleted automatically.
      class NodePoolAutoscaling; end

      # SetLabelsRequest sets the Google Cloud Platform labels on a Google Container
      # Engine cluster, which will in turn set them for Google Compute Engine
      # resources used by that cluster
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] resource_labels
      #   @return [Hash{String => String}]
      #     The labels to set for that cluster.
      # @!attribute [rw] label_fingerprint
      #   @return [String]
      #     The fingerprint of the previous set of labels for this resource,
      #     used to detect conflicts. The fingerprint is initially generated by
      #     Kubernetes Engine and changes after every request to modify or update
      #     labels. You must always provide an up-to-date fingerprint hash when
      #     updating or changing labels. Make a <code>get()</code> request to the
      #     resource to get the latest fingerprint.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster id) of the cluster to set labels.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetLabelsRequest; end

      # SetLegacyAbacRequest enables or disables the ABAC authorization mechanism for
      # a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster to update.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] enabled
      #   @return [true, false]
      #     Whether ABAC authorization will be enabled in the cluster.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster id) of the cluster to set legacy abac.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetLegacyAbacRequest; end

      # StartIPRotationRequest creates a new IP for the cluster and then performs
      # a node upgrade on each node pool to point to the new IP.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster id) of the cluster to start IP
      #     rotation. Specified in the format 'projects/*/locations/*/clusters/*'.
      # @!attribute [rw] rotate_credentials
      #   @return [true, false]
      #     Whether to rotate credentials during IP rotation.
      class StartIPRotationRequest; end

      # CompleteIPRotationRequest moves the cluster master back into single-IP mode.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster id) of the cluster to complete IP
      #     rotation. Specified in the format 'projects/*/locations/*/clusters/*'.
      class CompleteIPRotationRequest; end

      # AcceleratorConfig represents a Hardware Accelerator request.
      # @!attribute [rw] accelerator_count
      #   @return [Integer]
      #     The number of the accelerator cards exposed to an instance.
      # @!attribute [rw] accelerator_type
      #   @return [String]
      #     The accelerator type resource name. List of supported accelerators
      #     [here](https://cloud.google.com/compute/docs/gpus/#Introduction)
      class AcceleratorConfig; end

      # SetNetworkPolicyRequest enables/disables network policy for a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     Deprecated. The Google Developers Console [project ID or project
      #     number](https://developers.google.com/console/help/new/#projectnumber).
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] zone
      #   @return [String]
      #     Deprecated. The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     Deprecated. The name of the cluster.
      #     This field has been deprecated and replaced by the name field.
      # @!attribute [rw] network_policy
      #   @return [Google::Container::V1alpha1::NetworkPolicy]
      #     Configuration options for the NetworkPolicy feature.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster id) of the cluster to set networking
      #     policy.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetNetworkPolicyRequest; end

      # SetMaintenancePolicyRequest sets the maintenance policy for a cluster.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The Google Developers Console [project ID or project
      #     number](https://support.google.com/cloud/answer/6158840).
      # @!attribute [rw] zone
      #   @return [String]
      #     The name of the Google Compute Engine
      #     [zone](https://cloud.google.com/compute/docs/zones#available) in which the cluster
      #     resides.
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     The name of the cluster to update.
      # @!attribute [rw] maintenance_policy
      #   @return [Google::Container::V1alpha1::MaintenancePolicy]
      #     The maintenance policy to be set for the cluster. An empty field
      #     clears the existing maintenance policy.
      # @!attribute [rw] name
      #   @return [String]
      #     The name (project, location, cluster id) of the cluster to set maintenance
      #     policy.
      #     Specified in the format 'projects/*/locations/*/clusters/*'.
      class SetMaintenancePolicyRequest; end

      # ListUsableSubnetworksRequest requests the list of usable subnetworks.
      # @!attribute [rw] parent
      #   @return [String]
      #     The parent project where subnetworks are usable.
      #     Specified in the format 'projects/*'.
      # @!attribute [rw] filter
      #   @return [String]
      #     Filtering currently only supports equality on the networkProjectId and must
      #     be in the form: "networkProjectId=[PROJECTID]", where `networkProjectId`
      #     is the project which owns the listed subnetworks. This defaults to the
      #     parent project ID.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     The max number of results per page that should be returned. If the number
      #     of available results is larger than `page_size`, a `next_page_token` is
      #     returned which can be used to get the next page of results in subsequent
      #     requests. Acceptable values are 0 to 500, inclusive. (Default: 500)
      # @!attribute [rw] page_token
      #   @return [String]
      #     Specifies a page token to use. Set this to the next_page_token returned by
      #     previous list requests to get the next page of results.
      class ListUsableSubnetworksRequest; end

      # ListUsableSubnetworksResponse is the response of
      # ListUsableSubnetworksRequest.
      # @!attribute [rw] subnetworks
      #   @return [Array<Google::Container::V1alpha1::UsableSubnetwork>]
      #     A list of usable subnetworks in the specified network project.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     This token allows you to get the next page of results for list requests.
      #     If the number of results is larger than `page_size`, use the
      #     `next_page_token` as a value for the query parameter `page_token` in the
      #     next request. The value will become empty when there are no more pages.
      class ListUsableSubnetworksResponse; end

      # Secondary IP range of a usable subnetwork.
      # @!attribute [rw] range_name
      #   @return [String]
      #     The name associated with this subnetwork secondary range, used when adding
      #     an alias IP range to a VM instance.
      # @!attribute [rw] ip_cidr_range
      #   @return [String]
      #     The range of IP addresses belonging to this subnetwork secondary range.
      # @!attribute [rw] status
      #   @return [Google::Container::V1alpha1::UsableSubnetworkSecondaryRange::Status]
      #     This field is to determine the status of the secondary range programmably.
      class UsableSubnetworkSecondaryRange
        # Status shows the current usage of a secondary IP range.
        module Status
          # UNKNOWN is the zero value of the Status enum. It's not a valid status.
          UNKNOWN = 0

          # UNUSED denotes that this range is unclaimed by any cluster.
          UNUSED = 1

          # IN_USE_SERVICE denotes that this range is claimed by a cluster for
          # services. It cannot be used for other clusters.
          IN_USE_SERVICE = 2

          # IN_USE_SHAREABLE_POD denotes this range was created by the network admin
          # and is currently claimed by a cluster for pods. It can only be used by
          # other clusters as a pod range.
          IN_USE_SHAREABLE_POD = 3

          # IN_USE_MANAGED_POD denotes this range was created by GKE and is claimed
          # for pods. It cannot be used for other clusters.
          IN_USE_MANAGED_POD = 4
        end
      end

      # UsableSubnetwork resource returns the subnetwork name, its associated network
      # and the primary CIDR range.
      # @!attribute [rw] subnetwork
      #   @return [String]
      #     Subnetwork Name.
      # @!attribute [rw] network
      #   @return [String]
      #     Network Name.
      # @!attribute [rw] ip_cidr_range
      #   @return [String]
      #     The range of internal addresses that are owned by this subnetwork.
      # @!attribute [rw] secondary_ip_ranges
      #   @return [Array<Google::Container::V1alpha1::UsableSubnetworkSecondaryRange>]
      #     Secondary IP ranges.
      # @!attribute [rw] status_message
      #   @return [String]
      #     A human readable status message representing the reasons for cases where
      #     the caller cannot use the secondary ranges under the subnet. For example if
      #     the secondary_ip_ranges is empty due to a permission issue, an insufficient
      #     permission message will be given by status_message.
      class UsableSubnetwork; end
    end
  end
end