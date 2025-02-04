# frozen_string_literal: true

# Copyright 2021 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module Dataflow
      module V1beta3
        # Response to the request to launch a job from Flex Template.
        # @!attribute [rw] job
        #   @return [::Google::Cloud::Dataflow::V1beta3::Job]
        #     The job that was launched, if the request was not a dry run and
        #     the job was successfully launched.
        class LaunchFlexTemplateResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Container Spec.
        # @!attribute [rw] image
        #   @return [::String]
        #     Name of the docker container image. E.g., gcr.io/project/some-image
        # @!attribute [rw] metadata
        #   @return [::Google::Cloud::Dataflow::V1beta3::TemplateMetadata]
        #     Metadata describing a template including description and validation rules.
        # @!attribute [rw] sdk_info
        #   @return [::Google::Cloud::Dataflow::V1beta3::SDKInfo]
        #     Required. SDK info of the Flex Template.
        # @!attribute [rw] default_environment
        #   @return [::Google::Cloud::Dataflow::V1beta3::FlexTemplateRuntimeEnvironment]
        #     Default runtime environment for the job.
        class ContainerSpec
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Launch FlexTemplate Parameter.
        # @!attribute [rw] job_name
        #   @return [::String]
        #     Required. The job name to use for the created job. For update job request,
        #     job name should be same as the existing running job.
        # @!attribute [rw] container_spec
        #   @return [::Google::Cloud::Dataflow::V1beta3::ContainerSpec]
        #     Spec about the container image to launch.
        #
        #     Note: The following fields are mutually exclusive: `container_spec`, `container_spec_gcs_path`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] container_spec_gcs_path
        #   @return [::String]
        #     Cloud Storage path to a file with json serialized ContainerSpec as
        #     content.
        #
        #     Note: The following fields are mutually exclusive: `container_spec_gcs_path`, `container_spec`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] parameters
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     The parameters for FlexTemplate.
        #     Ex. \\{"num_workers":"5"}
        # @!attribute [rw] launch_options
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Launch options for this flex template job. This is a common set of options
        #     across languages and templates. This should not be used to pass job
        #     parameters.
        # @!attribute [rw] environment
        #   @return [::Google::Cloud::Dataflow::V1beta3::FlexTemplateRuntimeEnvironment]
        #     The runtime environment for the FlexTemplate job
        # @!attribute [rw] update
        #   @return [::Boolean]
        #     Set this to true if you are sending a request to update a running
        #     streaming job. When set, the job name should be the same as the
        #     running job.
        # @!attribute [rw] transform_name_mappings
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Use this to pass transform_name_mappings for streaming update jobs.
        #     Ex:\\{"oldTransformName":"newTransformName",...}'
        class LaunchFlexTemplateParameter
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class ParametersEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class LaunchOptionsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class TransformNameMappingsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # The environment values to be set at runtime for flex template.
        # @!attribute [rw] num_workers
        #   @return [::Integer]
        #     The initial number of Google Compute Engine instances for the job.
        # @!attribute [rw] max_workers
        #   @return [::Integer]
        #     The maximum number of Google Compute Engine instances to be made
        #     available to your pipeline during execution, from 1 to 1000.
        # @!attribute [rw] zone
        #   @return [::String]
        #     The Compute Engine [availability
        #     zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones)
        #     for launching worker instances to run your pipeline.
        #     In the future, worker_zone will take precedence.
        # @!attribute [rw] service_account_email
        #   @return [::String]
        #     The email address of the service account to run the job as.
        # @!attribute [rw] temp_location
        #   @return [::String]
        #     The Cloud Storage path to use for temporary files.
        #     Must be a valid Cloud Storage URL, beginning with `gs://`.
        # @!attribute [rw] machine_type
        #   @return [::String]
        #     The machine type to use for the job. Defaults to the value from the
        #     template if not specified.
        # @!attribute [rw] additional_experiments
        #   @return [::Array<::String>]
        #     Additional experiment flags for the job.
        # @!attribute [rw] network
        #   @return [::String]
        #     Network to which VMs will be assigned.  If empty or unspecified,
        #     the service will use the network "default".
        # @!attribute [rw] subnetwork
        #   @return [::String]
        #     Subnetwork to which VMs will be assigned, if desired. You can specify a
        #     subnetwork using either a complete URL or an abbreviated path. Expected to
        #     be of the form
        #     "https://www.googleapis.com/compute/v1/projects/HOST_PROJECT_ID/regions/REGION/subnetworks/SUBNETWORK"
        #     or "regions/REGION/subnetworks/SUBNETWORK". If the subnetwork is located in
        #     a Shared VPC network, you must use the complete URL.
        # @!attribute [rw] additional_user_labels
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Additional user labels to be specified for the job.
        #     Keys and values must follow the restrictions specified in the [labeling
        #     restrictions](https://cloud.google.com/compute/docs/labeling-resources#restrictions)
        #     page.
        #     An object containing a list of "key": value pairs.
        #     Example: { "name": "wrench", "mass": "1kg", "count": "3" }.
        # @!attribute [rw] kms_key_name
        #   @return [::String]
        #     Name for the Cloud KMS key for the job.
        #     Key format is:
        #     projects/<project>/locations/<location>/keyRings/<keyring>/cryptoKeys/<key>
        # @!attribute [rw] ip_configuration
        #   @return [::Google::Cloud::Dataflow::V1beta3::WorkerIPAddressConfiguration]
        #     Configuration for VM IPs.
        # @!attribute [rw] worker_region
        #   @return [::String]
        #     The Compute Engine region
        #     (https://cloud.google.com/compute/docs/regions-zones/regions-zones) in
        #     which worker processing should occur, e.g. "us-west1". Mutually exclusive
        #     with worker_zone. If neither worker_region nor worker_zone is specified,
        #     default to the control plane's region.
        # @!attribute [rw] worker_zone
        #   @return [::String]
        #     The Compute Engine zone
        #     (https://cloud.google.com/compute/docs/regions-zones/regions-zones) in
        #     which worker processing should occur, e.g. "us-west1-a". Mutually exclusive
        #     with worker_region. If neither worker_region nor worker_zone is specified,
        #     a zone in the control plane's region is chosen based on available capacity.
        #     If both `worker_zone` and `zone` are set, `worker_zone` takes precedence.
        # @!attribute [rw] enable_streaming_engine
        #   @return [::Boolean]
        #     Whether to enable Streaming Engine for the job.
        # @!attribute [rw] flexrs_goal
        #   @return [::Google::Cloud::Dataflow::V1beta3::FlexResourceSchedulingGoal]
        #     Set FlexRS goal for the job.
        #     https://cloud.google.com/dataflow/docs/guides/flexrs
        # @!attribute [rw] staging_location
        #   @return [::String]
        #     The Cloud Storage path for staging local files.
        #     Must be a valid Cloud Storage URL, beginning with `gs://`.
        # @!attribute [rw] sdk_container_image
        #   @return [::String]
        #     Docker registry location of container image to use for the 'worker harness.
        #     Default is the container for the version of the SDK. Note this field is
        #     only valid for portable pipelines.
        # @!attribute [rw] disk_size_gb
        #   @return [::Integer]
        #     Worker disk size, in gigabytes.
        # @!attribute [rw] autoscaling_algorithm
        #   @return [::Google::Cloud::Dataflow::V1beta3::AutoscalingAlgorithm]
        #     The algorithm to use for autoscaling
        # @!attribute [rw] dump_heap_on_oom
        #   @return [::Boolean]
        #     If true, save a heap dump before killing a thread or process which is GC
        #     thrashing or out of memory. The location of the heap file will either be
        #     echoed back to the user, or the user will be given the opportunity to
        #     download the heap file.
        # @!attribute [rw] save_heap_dumps_to_gcs_path
        #   @return [::String]
        #     Cloud Storage bucket (directory) to upload heap dumps to the given
        #     location. Enabling this implies that heap dumps should be generated on OOM
        #     (dump_heap_on_oom is set to true).
        # @!attribute [rw] launcher_machine_type
        #   @return [::String]
        #     The machine type to use for launching the job. The default is
        #     n1-standard-1.
        class FlexTemplateRuntimeEnvironment
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class AdditionalUserLabelsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # A request to launch a Cloud Dataflow job from a FlexTemplate.
        # @!attribute [rw] project_id
        #   @return [::String]
        #     Required. The ID of the Cloud Platform project that the job belongs to.
        # @!attribute [rw] launch_parameter
        #   @return [::Google::Cloud::Dataflow::V1beta3::LaunchFlexTemplateParameter]
        #     Required. Parameter to launch a job form Flex Template.
        # @!attribute [rw] location
        #   @return [::String]
        #     Required. The [regional endpoint]
        #     (https://cloud.google.com/dataflow/docs/concepts/regional-endpoints) to
        #     which to direct the request. E.g., us-central1, us-west1.
        # @!attribute [rw] validate_only
        #   @return [::Boolean]
        #     If true, the request is validated but not actually executed.
        #     Defaults to false.
        class LaunchFlexTemplateRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The environment values to set at runtime.
        # @!attribute [rw] num_workers
        #   @return [::Integer]
        #     The initial number of Google Compute Engine instnaces for the job.
        # @!attribute [rw] max_workers
        #   @return [::Integer]
        #     The maximum number of Google Compute Engine instances to be made
        #     available to your pipeline during execution, from 1 to 1000.
        # @!attribute [rw] zone
        #   @return [::String]
        #     The Compute Engine [availability
        #     zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones)
        #     for launching worker instances to run your pipeline.
        #     In the future, worker_zone will take precedence.
        # @!attribute [rw] service_account_email
        #   @return [::String]
        #     The email address of the service account to run the job as.
        # @!attribute [rw] temp_location
        #   @return [::String]
        #     The Cloud Storage path to use for temporary files.
        #     Must be a valid Cloud Storage URL, beginning with `gs://`.
        # @!attribute [rw] bypass_temp_dir_validation
        #   @return [::Boolean]
        #     Whether to bypass the safety checks for the job's temporary directory.
        #     Use with caution.
        # @!attribute [rw] machine_type
        #   @return [::String]
        #     The machine type to use for the job. Defaults to the value from the
        #     template if not specified.
        # @!attribute [rw] additional_experiments
        #   @return [::Array<::String>]
        #     Additional experiment flags for the job, specified with the
        #     `--experiments` option.
        # @!attribute [rw] network
        #   @return [::String]
        #     Network to which VMs will be assigned.  If empty or unspecified,
        #     the service will use the network "default".
        # @!attribute [rw] subnetwork
        #   @return [::String]
        #     Subnetwork to which VMs will be assigned, if desired. You can specify a
        #     subnetwork using either a complete URL or an abbreviated path. Expected to
        #     be of the form
        #     "https://www.googleapis.com/compute/v1/projects/HOST_PROJECT_ID/regions/REGION/subnetworks/SUBNETWORK"
        #     or "regions/REGION/subnetworks/SUBNETWORK". If the subnetwork is located in
        #     a Shared VPC network, you must use the complete URL.
        # @!attribute [rw] additional_user_labels
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Additional user labels to be specified for the job.
        #     Keys and values should follow the restrictions specified in the [labeling
        #     restrictions](https://cloud.google.com/compute/docs/labeling-resources#restrictions)
        #     page.
        #     An object containing a list of "key": value pairs.
        #     Example: { "name": "wrench", "mass": "1kg", "count": "3" }.
        # @!attribute [rw] kms_key_name
        #   @return [::String]
        #     Name for the Cloud KMS key for the job.
        #     Key format is:
        #     projects/<project>/locations/<location>/keyRings/<keyring>/cryptoKeys/<key>
        # @!attribute [rw] ip_configuration
        #   @return [::Google::Cloud::Dataflow::V1beta3::WorkerIPAddressConfiguration]
        #     Configuration for VM IPs.
        # @!attribute [rw] worker_region
        #   @return [::String]
        #     The Compute Engine region
        #     (https://cloud.google.com/compute/docs/regions-zones/regions-zones) in
        #     which worker processing should occur, e.g. "us-west1". Mutually exclusive
        #     with worker_zone. If neither worker_region nor worker_zone is specified,
        #     default to the control plane's region.
        # @!attribute [rw] worker_zone
        #   @return [::String]
        #     The Compute Engine zone
        #     (https://cloud.google.com/compute/docs/regions-zones/regions-zones) in
        #     which worker processing should occur, e.g. "us-west1-a". Mutually exclusive
        #     with worker_region. If neither worker_region nor worker_zone is specified,
        #     a zone in the control plane's region is chosen based on available capacity.
        #     If both `worker_zone` and `zone` are set, `worker_zone` takes precedence.
        # @!attribute [rw] enable_streaming_engine
        #   @return [::Boolean]
        #     Whether to enable Streaming Engine for the job.
        class RuntimeEnvironment
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class AdditionalUserLabelsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # Metadata for a specific parameter.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the parameter.
        # @!attribute [rw] label
        #   @return [::String]
        #     Required. The label to display for the parameter.
        # @!attribute [rw] help_text
        #   @return [::String]
        #     Required. The help text to display for the parameter.
        # @!attribute [rw] is_optional
        #   @return [::Boolean]
        #     Optional. Whether the parameter is optional. Defaults to false.
        # @!attribute [rw] regexes
        #   @return [::Array<::String>]
        #     Optional. Regexes that the parameter must match.
        # @!attribute [rw] param_type
        #   @return [::Google::Cloud::Dataflow::V1beta3::ParameterType]
        #     Optional. The type of the parameter.
        #     Used for selecting input picker.
        # @!attribute [rw] custom_metadata
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Optional. Additional metadata for describing this parameter.
        class ParameterMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class CustomMetadataEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # Metadata describing a template.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the template.
        # @!attribute [rw] description
        #   @return [::String]
        #     Optional. A description of the template.
        # @!attribute [rw] parameters
        #   @return [::Array<::Google::Cloud::Dataflow::V1beta3::ParameterMetadata>]
        #     The parameters for the template.
        class TemplateMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # SDK Information.
        # @!attribute [rw] language
        #   @return [::Google::Cloud::Dataflow::V1beta3::SDKInfo::Language]
        #     Required. The SDK Language.
        # @!attribute [rw] version
        #   @return [::String]
        #     Optional. The SDK version.
        class SDKInfo
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # SDK Language.
          module Language
            # UNKNOWN Language.
            UNKNOWN = 0

            # Java.
            JAVA = 1

            # Python.
            PYTHON = 2
          end
        end

        # RuntimeMetadata describing a runtime environment.
        # @!attribute [rw] sdk_info
        #   @return [::Google::Cloud::Dataflow::V1beta3::SDKInfo]
        #     SDK Info for the template.
        # @!attribute [rw] parameters
        #   @return [::Array<::Google::Cloud::Dataflow::V1beta3::ParameterMetadata>]
        #     The parameters for the template.
        class RuntimeMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # A request to create a Cloud Dataflow job from a template.
        # @!attribute [rw] project_id
        #   @return [::String]
        #     Required. The ID of the Cloud Platform project that the job belongs to.
        # @!attribute [rw] job_name
        #   @return [::String]
        #     Required. The job name to use for the created job.
        # @!attribute [rw] gcs_path
        #   @return [::String]
        #     Required. A Cloud Storage path to the template from which to
        #     create the job.
        #     Must be a valid Cloud Storage URL, beginning with `gs://`.
        # @!attribute [rw] parameters
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     The runtime parameters to pass to the job.
        # @!attribute [rw] environment
        #   @return [::Google::Cloud::Dataflow::V1beta3::RuntimeEnvironment]
        #     The runtime environment for the job.
        # @!attribute [rw] location
        #   @return [::String]
        #     The [regional endpoint]
        #     (https://cloud.google.com/dataflow/docs/concepts/regional-endpoints) to
        #     which to direct the request.
        class CreateJobFromTemplateRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class ParametersEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # A request to retrieve a Cloud Dataflow job template.
        # @!attribute [rw] project_id
        #   @return [::String]
        #     Required. The ID of the Cloud Platform project that the job belongs to.
        # @!attribute [rw] gcs_path
        #   @return [::String]
        #     Required. A Cloud Storage path to the template from which to
        #     create the job.
        #     Must be valid Cloud Storage URL, beginning with 'gs://'.
        # @!attribute [rw] view
        #   @return [::Google::Cloud::Dataflow::V1beta3::GetTemplateRequest::TemplateView]
        #     The view to retrieve. Defaults to METADATA_ONLY.
        # @!attribute [rw] location
        #   @return [::String]
        #     The [regional endpoint]
        #     (https://cloud.google.com/dataflow/docs/concepts/regional-endpoints) to
        #     which to direct the request.
        class GetTemplateRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # The various views of a template that may be retrieved.
          module TemplateView
            # Template view that retrieves only the metadata associated with the
            # template.
            METADATA_ONLY = 0
          end
        end

        # The response to a GetTemplate request.
        # @!attribute [rw] status
        #   @return [::Google::Rpc::Status]
        #     The status of the get template request. Any problems with the
        #     request will be indicated in the error_details.
        # @!attribute [rw] metadata
        #   @return [::Google::Cloud::Dataflow::V1beta3::TemplateMetadata]
        #     The template metadata describing the template name, available
        #     parameters, etc.
        # @!attribute [rw] template_type
        #   @return [::Google::Cloud::Dataflow::V1beta3::GetTemplateResponse::TemplateType]
        #     Template Type.
        # @!attribute [rw] runtime_metadata
        #   @return [::Google::Cloud::Dataflow::V1beta3::RuntimeMetadata]
        #     Describes the runtime metadata with SDKInfo and available parameters.
        class GetTemplateResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Template Type.
          module TemplateType
            # Unknown Template Type.
            UNKNOWN = 0

            # Legacy Template.
            LEGACY = 1

            # Flex Template.
            FLEX = 2
          end
        end

        # Parameters to provide to the template being launched.
        # @!attribute [rw] job_name
        #   @return [::String]
        #     Required. The job name to use for the created job.
        # @!attribute [rw] parameters
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     The runtime parameters to pass to the job.
        # @!attribute [rw] environment
        #   @return [::Google::Cloud::Dataflow::V1beta3::RuntimeEnvironment]
        #     The runtime environment for the job.
        # @!attribute [rw] update
        #   @return [::Boolean]
        #     If set, replace the existing pipeline with the name specified by jobName
        #     with this pipeline, preserving state.
        # @!attribute [rw] transform_name_mapping
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Only applicable when updating a pipeline. Map of transform name prefixes of
        #     the job to be replaced to the corresponding name prefixes of the new job.
        class LaunchTemplateParameters
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class ParametersEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class TransformNameMappingEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # A request to launch a template.
        # @!attribute [rw] project_id
        #   @return [::String]
        #     Required. The ID of the Cloud Platform project that the job belongs to.
        # @!attribute [rw] validate_only
        #   @return [::Boolean]
        #     If true, the request is validated but not actually executed.
        #     Defaults to false.
        # @!attribute [rw] gcs_path
        #   @return [::String]
        #     A Cloud Storage path to the template from which to create
        #     the job.
        #     Must be valid Cloud Storage URL, beginning with 'gs://'.
        #
        #     Note: The following fields are mutually exclusive: `gcs_path`, `dynamic_template`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] dynamic_template
        #   @return [::Google::Cloud::Dataflow::V1beta3::DynamicTemplateLaunchParams]
        #     Params for launching a dynamic template.
        #
        #     Note: The following fields are mutually exclusive: `dynamic_template`, `gcs_path`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] launch_parameters
        #   @return [::Google::Cloud::Dataflow::V1beta3::LaunchTemplateParameters]
        #     The parameters of the template to launch. This should be part of the
        #     body of the POST request.
        # @!attribute [rw] location
        #   @return [::String]
        #     The [regional endpoint]
        #     (https://cloud.google.com/dataflow/docs/concepts/regional-endpoints) to
        #     which to direct the request.
        class LaunchTemplateRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Response to the request to launch a template.
        # @!attribute [rw] job
        #   @return [::Google::Cloud::Dataflow::V1beta3::Job]
        #     The job that was launched, if the request was not a dry run and
        #     the job was successfully launched.
        class LaunchTemplateResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Used in the error_details field of a google.rpc.Status message, this
        # indicates problems with the template parameter.
        # @!attribute [rw] parameter_violations
        #   @return [::Array<::Google::Cloud::Dataflow::V1beta3::InvalidTemplateParameters::ParameterViolation>]
        #     Describes all parameter violations in a template request.
        class InvalidTemplateParameters
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # A specific template-parameter violation.
          # @!attribute [rw] parameter
          #   @return [::String]
          #     The parameter that failed to validate.
          # @!attribute [rw] description
          #   @return [::String]
          #     A description of why the parameter failed to validate.
          class ParameterViolation
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # Params which should be passed when launching a dynamic template.
        # @!attribute [rw] gcs_path
        #   @return [::String]
        #     Path to dynamic template spec file on Cloud Storage.
        #     The file must be a Json serialized DynamicTemplateFieSpec object.
        # @!attribute [rw] staging_location
        #   @return [::String]
        #     Cloud Storage path for staging dependencies.
        #     Must be a valid Cloud Storage URL, beginning with `gs://`.
        class DynamicTemplateLaunchParams
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # ParameterType specifies what kind of input we need for this parameter.
        module ParameterType
          # Default input type.
          DEFAULT = 0

          # The parameter specifies generic text input.
          TEXT = 1

          # The parameter specifies a Cloud Storage Bucket to read from.
          GCS_READ_BUCKET = 2

          # The parameter specifies a Cloud Storage Bucket to write to.
          GCS_WRITE_BUCKET = 3

          # The parameter specifies a Cloud Storage file path to read from.
          GCS_READ_FILE = 4

          # The parameter specifies a Cloud Storage file path to write to.
          GCS_WRITE_FILE = 5

          # The parameter specifies a Cloud Storage folder path to read from.
          GCS_READ_FOLDER = 6

          # The parameter specifies a Cloud Storage folder to write to.
          GCS_WRITE_FOLDER = 7

          # The parameter specifies a Pub/Sub Topic.
          PUBSUB_TOPIC = 8

          # The parameter specifies a Pub/Sub Subscription.
          PUBSUB_SUBSCRIPTION = 9
        end
      end
    end
  end
end
