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
  module Cloud
    module Dataproc
      module V1
        # A Cloud Dataproc workflow template resource.
        # @!attribute [rw] id
        #   @return [String]
        #     Required. The template id.
        #
        #     The id must contain only letters (a-z, A-Z), numbers (0-9),
        #     underscores (_), and hyphens (-). Cannot begin or end with underscore
        #     or hyphen. Must consist of between 3 and 50 characters.
        # @!attribute [rw] name
        #   @return [String]
        #     Output only. The "resource name" of the template, as described
        #     in https://cloud.google.com/apis/design/resource_names of the form
        #     `projects/{project_id}/regions/{region}/workflowTemplates/{template_id}`
        # @!attribute [rw] version
        #   @return [Integer]
        #     Optional. Used to perform a consistent read-modify-write.
        #
        #     This field should be left blank for a `CreateWorkflowTemplate` request. It
        #     is required for an `UpdateWorkflowTemplate` request, and must match the
        #     current server version. A typical update template flow would fetch the
        #     current template with a `GetWorkflowTemplate` request, which will return
        #     the current template with the `version` field filled in with the
        #     current server version. The user updates other fields in the template,
        #     then returns it as part of the `UpdateWorkflowTemplate` request.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time template was created.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time template was last updated.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     Optional. The labels to associate with this template. These labels
        #     will be propagated to all jobs and clusters created by the workflow
        #     instance.
        #
        #     Label **keys** must contain 1 to 63 characters, and must conform to
        #     [RFC 1035](https://www.ietf.org/rfc/rfc1035.txt).
        #
        #     Label **values** may be empty, but, if present, must contain 1 to 63
        #     characters, and must conform to
        #     [RFC 1035](https://www.ietf.org/rfc/rfc1035.txt).
        #
        #     No more than 32 labels can be associated with a template.
        # @!attribute [rw] placement
        #   @return [Google::Cloud::Dataproc::V1::WorkflowTemplatePlacement]
        #     Required. WorkflowTemplate scheduling information.
        # @!attribute [rw] jobs
        #   @return [Array<Google::Cloud::Dataproc::V1::OrderedJob>]
        #     Required. The Directed Acyclic Graph of Jobs to submit.
        # @!attribute [rw] parameters
        #   @return [Array<Google::Cloud::Dataproc::V1::TemplateParameter>]
        #     Optional. Template parameters whose values are substituted into the
        #     template. Values for parameters must be provided when the template is
        #     instantiated.
        class WorkflowTemplate; end

        # Specifies workflow execution target.
        #
        # Either `managed_cluster` or `cluster_selector` is required.
        # @!attribute [rw] managed_cluster
        #   @return [Google::Cloud::Dataproc::V1::ManagedCluster]
        #     Optional. A cluster that is managed by the workflow.
        # @!attribute [rw] cluster_selector
        #   @return [Google::Cloud::Dataproc::V1::ClusterSelector]
        #     Optional. A selector that chooses target cluster for jobs based
        #     on metadata.
        #
        #     The selector is evaluated at the time each job is submitted.
        class WorkflowTemplatePlacement; end

        # Cluster that is managed by the workflow.
        # @!attribute [rw] cluster_name
        #   @return [String]
        #     Required. The cluster name prefix. A unique cluster name will be formed by
        #     appending a random suffix.
        #
        #     The name must contain only lower-case letters (a-z), numbers (0-9),
        #     and hyphens (-). Must begin with a letter. Cannot begin or end with
        #     hyphen. Must consist of between 2 and 35 characters.
        # @!attribute [rw] config
        #   @return [Google::Cloud::Dataproc::V1::ClusterConfig]
        #     Required. The cluster configuration.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     Optional. The labels to associate with this cluster.
        #
        #     Label keys must be between 1 and 63 characters long, and must conform to
        #     the following PCRE regular expression:
        #     [\p\\{Ll}\p\\{Lo}][\p\\{Ll}\p\\{Lo}\p\\{N}_-]\\{0,62}
        #
        #     Label values must be between 1 and 63 characters long, and must conform to
        #     the following PCRE regular expression: [\p\\{Ll}\p\\{Lo}\p\\{N}_-]\\{0,63}
        #
        #     No more than 32 labels can be associated with a given cluster.
        class ManagedCluster; end

        # A selector that chooses target cluster for jobs based on metadata.
        # @!attribute [rw] zone
        #   @return [String]
        #     Optional. The zone where workflow process executes. This parameter does not
        #     affect the selection of the cluster.
        #
        #     If unspecified, the zone of the first cluster matching the selector
        #     is used.
        # @!attribute [rw] cluster_labels
        #   @return [Hash{String => String}]
        #     Required. The cluster labels. Cluster must have all labels
        #     to match.
        class ClusterSelector; end

        # A job executed by the workflow.
        # @!attribute [rw] step_id
        #   @return [String]
        #     Required. The step id. The id must be unique among all jobs
        #     within the template.
        #
        #     The step id is used as prefix for job id, as job
        #     `goog-dataproc-workflow-step-id` label, and in
        #     {Google::Cloud::Dataproc::V1::OrderedJob#prerequisite_step_ids prerequisiteStepIds} field from other
        #     steps.
        #
        #     The id must contain only letters (a-z, A-Z), numbers (0-9),
        #     underscores (_), and hyphens (-). Cannot begin or end with underscore
        #     or hyphen. Must consist of between 3 and 50 characters.
        # @!attribute [rw] hadoop_job
        #   @return [Google::Cloud::Dataproc::V1::HadoopJob]
        #     Job is a Hadoop job.
        # @!attribute [rw] spark_job
        #   @return [Google::Cloud::Dataproc::V1::SparkJob]
        #     Job is a Spark job.
        # @!attribute [rw] pyspark_job
        #   @return [Google::Cloud::Dataproc::V1::PySparkJob]
        #     Job is a Pyspark job.
        # @!attribute [rw] hive_job
        #   @return [Google::Cloud::Dataproc::V1::HiveJob]
        #     Job is a Hive job.
        # @!attribute [rw] pig_job
        #   @return [Google::Cloud::Dataproc::V1::PigJob]
        #     Job is a Pig job.
        # @!attribute [rw] spark_sql_job
        #   @return [Google::Cloud::Dataproc::V1::SparkSqlJob]
        #     Job is a SparkSql job.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     Optional. The labels to associate with this job.
        #
        #     Label keys must be between 1 and 63 characters long, and must conform to
        #     the following regular expression:
        #     [\p\\{Ll}\p\\{Lo}][\p\\{Ll}\p\\{Lo}\p\\{N}_-]\\{0,62}
        #
        #     Label values must be between 1 and 63 characters long, and must conform to
        #     the following regular expression: [\p\\{Ll}\p\\{Lo}\p\\{N}_-]\\{0,63}
        #
        #     No more than 32 labels can be associated with a given job.
        # @!attribute [rw] scheduling
        #   @return [Google::Cloud::Dataproc::V1::JobScheduling]
        #     Optional. Job scheduling configuration.
        # @!attribute [rw] prerequisite_step_ids
        #   @return [Array<String>]
        #     Optional. The optional list of prerequisite job step_ids.
        #     If not specified, the job will start at the beginning of workflow.
        class OrderedJob; end

        # A configurable parameter that replaces one or more fields in the template.
        # Parameterizable fields:
        # * Labels
        # * File uris
        # * Job properties
        # * Job arguments
        # * Script variables
        # * Main class (in HadoopJob and SparkJob)
        # * Zone (in ClusterSelector)
        # @!attribute [rw] name
        #   @return [String]
        #     Required.  Parameter name.
        #     The parameter name is used as the key, and paired with the
        #     parameter value, which are passed to the template when the template
        #     is instantiated.
        #     The name must contain only capital letters (A-Z), numbers (0-9), and
        #     underscores (_), and must not start with a number. The maximum length is
        #     40 characters.
        # @!attribute [rw] fields
        #   @return [Array<String>]
        #     Required. Paths to all fields that the parameter replaces.
        #     A field is allowed to appear in at most one parameter's list of field
        #     paths.
        #
        #     A field path is similar in syntax to a {Google::Protobuf::FieldMask}.
        #     For example, a field path that references the zone field of a workflow
        #     template's cluster selector would be specified as
        #     `placement.clusterSelector.zone`.
        #
        #     Also, field paths can reference fields using the following syntax:
        #
        #     * Values in maps can be referenced by key:
        #       * labels['key']
        #         * placement.clusterSelector.clusterLabels['key']
        #         * placement.managedCluster.labels['key']
        #         * placement.clusterSelector.clusterLabels['key']
        #         * jobs['step-id'].labels['key']
        #
        #         * Jobs in the jobs list can be referenced by step-id:
        #         * jobs['step-id'].hadoopJob.mainJarFileUri
        #         * jobs['step-id'].hiveJob.queryFileUri
        #         * jobs['step-id'].pySparkJob.mainPythonFileUri
        #         * jobs['step-id'].hadoopJob.jarFileUris[0]
        #         * jobs['step-id'].hadoopJob.archiveUris[0]
        #         * jobs['step-id'].hadoopJob.fileUris[0]
        #         * jobs['step-id'].pySparkJob.pythonFileUris[0]
        #
        #         * Items in repeated fields can be referenced by a zero-based index:
        #         * jobs['step-id'].sparkJob.args[0]
        #
        #         * Other examples:
        #         * jobs['step-id'].hadoopJob.properties['key']
        #         * jobs['step-id'].hadoopJob.args[0]
        #         * jobs['step-id'].hiveJob.scriptVariables['key']
        #         * jobs['step-id'].hadoopJob.mainJarFileUri
        #         * placement.clusterSelector.zone
        #
        #         It may not be possible to parameterize maps and repeated fields in their
        #         entirety since only individual map values and individual items in repeated
        #         fields can be referenced. For example, the following field paths are
        #         invalid:
        #
        #       * placement.clusterSelector.clusterLabels
        #     * jobs['step-id'].sparkJob.args
        # @!attribute [rw] description
        #   @return [String]
        #     Optional. Brief description of the parameter.
        #     Must not exceed 1024 characters.
        # @!attribute [rw] validation
        #   @return [Google::Cloud::Dataproc::V1::ParameterValidation]
        #     Optional. Validation rules to be applied to this parameter's value.
        class TemplateParameter; end

        # Configuration for parameter validation.
        # @!attribute [rw] regex
        #   @return [Google::Cloud::Dataproc::V1::RegexValidation]
        #     Validation based on regular expressions.
        # @!attribute [rw] values
        #   @return [Google::Cloud::Dataproc::V1::ValueValidation]
        #     Validation based on a list of allowed values.
        class ParameterValidation; end

        # Validation based on regular expressions.
        # @!attribute [rw] regexes
        #   @return [Array<String>]
        #     Required. RE2 regular expressions used to validate the parameter's value.
        #     The value must match the regex in its entirety (substring
        #     matches are not sufficient).
        class RegexValidation; end

        # Validation based on a list of allowed values.
        # @!attribute [rw] values
        #   @return [Array<String>]
        #     Required. List of allowed values for the parameter.
        class ValueValidation; end

        # A Cloud Dataproc workflow template resource.
        # @!attribute [rw] template
        #   @return [String]
        #     Output only. The "resource name" of the template.
        # @!attribute [rw] version
        #   @return [Integer]
        #     Output only. The version of template at the time of
        #     workflow instantiation.
        # @!attribute [rw] create_cluster
        #   @return [Google::Cloud::Dataproc::V1::ClusterOperation]
        #     Output only. The create cluster operation metadata.
        # @!attribute [rw] graph
        #   @return [Google::Cloud::Dataproc::V1::WorkflowGraph]
        #     Output only. The workflow graph.
        # @!attribute [rw] delete_cluster
        #   @return [Google::Cloud::Dataproc::V1::ClusterOperation]
        #     Output only. The delete cluster operation metadata.
        # @!attribute [rw] state
        #   @return [Google::Cloud::Dataproc::V1::WorkflowMetadata::State]
        #     Output only. The workflow state.
        # @!attribute [rw] cluster_name
        #   @return [String]
        #     Output only. The name of the target cluster.
        # @!attribute [rw] parameters
        #   @return [Hash{String => String}]
        #     Map from parameter names to values that were used for those parameters.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. Workflow start time.
        # @!attribute [rw] end_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. Workflow end time.
        # @!attribute [rw] cluster_uuid
        #   @return [String]
        #     Output only. The UUID of target cluster.
        class WorkflowMetadata
          # The operation state.
          module State
            # Unused.
            UNKNOWN = 0

            # The operation has been created.
            PENDING = 1

            # The operation is running.
            RUNNING = 2

            # The operation is done; either cancelled or completed.
            DONE = 3
          end
        end

        # The cluster operation triggered by a workflow.
        # @!attribute [rw] operation_id
        #   @return [String]
        #     Output only. The id of the cluster operation.
        # @!attribute [rw] error
        #   @return [String]
        #     Output only. Error, if operation failed.
        # @!attribute [rw] done
        #   @return [true, false]
        #     Output only. Indicates the operation is done.
        class ClusterOperation; end

        # The workflow graph.
        # @!attribute [rw] nodes
        #   @return [Array<Google::Cloud::Dataproc::V1::WorkflowNode>]
        #     Output only. The workflow nodes.
        class WorkflowGraph; end

        # The workflow node.
        # @!attribute [rw] step_id
        #   @return [String]
        #     Output only. The name of the node.
        # @!attribute [rw] prerequisite_step_ids
        #   @return [Array<String>]
        #     Output only. Node's prerequisite nodes.
        # @!attribute [rw] job_id
        #   @return [String]
        #     Output only. The job id; populated after the node enters RUNNING state.
        # @!attribute [rw] state
        #   @return [Google::Cloud::Dataproc::V1::WorkflowNode::NodeState]
        #     Output only. The node state.
        # @!attribute [rw] error
        #   @return [String]
        #     Output only. The error detail.
        class WorkflowNode
          # The workflow node state.
          module NodeState
            # State is unspecified.
            NODE_STATE_UNSPECIFIED = 0

            # The node is awaiting prerequisite node to finish.
            BLOCKED = 1

            # The node is runnable but not running.
            RUNNABLE = 2

            # The node is running.
            RUNNING = 3

            # The node completed successfully.
            COMPLETED = 4

            # The node failed. A node can be marked FAILED because
            # its ancestor or peer failed.
            FAILED = 5
          end
        end

        # A request to create a workflow template.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The "resource name" of the region, as described
        #     in https://cloud.google.com/apis/design/resource_names of the form
        #     `projects/{project_id}/regions/{region}`
        # @!attribute [rw] template
        #   @return [Google::Cloud::Dataproc::V1::WorkflowTemplate]
        #     Required. The Dataproc workflow template to create.
        class CreateWorkflowTemplateRequest; end

        # A request to fetch a workflow template.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The "resource name" of the workflow template, as described
        #     in https://cloud.google.com/apis/design/resource_names of the form
        #     `projects/{project_id}/regions/{region}/workflowTemplates/{template_id}`
        # @!attribute [rw] version
        #   @return [Integer]
        #     Optional. The version of workflow template to retrieve. Only previously
        #     instatiated versions can be retrieved.
        #
        #     If unspecified, retrieves the current version.
        class GetWorkflowTemplateRequest; end

        # A request to instantiate a workflow template.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The "resource name" of the workflow template, as described
        #     in https://cloud.google.com/apis/design/resource_names of the form
        #     `projects/{project_id}/regions/{region}/workflowTemplates/{template_id}`
        # @!attribute [rw] version
        #   @return [Integer]
        #     Optional. The version of workflow template to instantiate. If specified,
        #     the workflow will be instantiated only if the current version of
        #     the workflow template has the supplied version.
        #
        #     This option cannot be used to instantiate a previous version of
        #     workflow template.
        # @!attribute [rw] request_id
        #   @return [String]
        #     Optional. A tag that prevents multiple concurrent workflow
        #     instances with the same tag from running. This mitigates risk of
        #     concurrent instances started due to retries.
        #
        #     It is recommended to always set this value to a
        #     [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier).
        #
        #     The tag must contain only letters (a-z, A-Z), numbers (0-9),
        #     underscores (_), and hyphens (-). The maximum length is 40 characters.
        # @!attribute [rw] parameters
        #   @return [Hash{String => String}]
        #     Optional. Map from parameter names to values that should be used for those
        #     parameters. Values may not exceed 100 characters.
        class InstantiateWorkflowTemplateRequest; end

        # A request to instantiate an inline workflow template.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The "resource name" of the workflow template region, as described
        #     in https://cloud.google.com/apis/design/resource_names of the form
        #     `projects/{project_id}/regions/{region}`
        # @!attribute [rw] template
        #   @return [Google::Cloud::Dataproc::V1::WorkflowTemplate]
        #     Required. The workflow template to instantiate.
        # @!attribute [rw] request_id
        #   @return [String]
        #     Optional. A tag that prevents multiple concurrent workflow
        #     instances with the same tag from running. This mitigates risk of
        #     concurrent instances started due to retries.
        #
        #     It is recommended to always set this value to a
        #     [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier).
        #
        #     The tag must contain only letters (a-z, A-Z), numbers (0-9),
        #     underscores (_), and hyphens (-). The maximum length is 40 characters.
        class InstantiateInlineWorkflowTemplateRequest; end

        # A request to update a workflow template.
        # @!attribute [rw] template
        #   @return [Google::Cloud::Dataproc::V1::WorkflowTemplate]
        #     Required. The updated workflow template.
        #
        #     The `template.version` field must match the current version.
        class UpdateWorkflowTemplateRequest; end

        # A request to list workflow templates in a project.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The "resource name" of the region, as described
        #     in https://cloud.google.com/apis/design/resource_names of the form
        #     `projects/{project_id}/regions/{region}`
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. The maximum number of results to return in each response.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. The page token, returned by a previous call, to request the
        #     next page of results.
        class ListWorkflowTemplatesRequest; end

        # A response to a request to list workflow templates in a project.
        # @!attribute [rw] templates
        #   @return [Array<Google::Cloud::Dataproc::V1::WorkflowTemplate>]
        #     Output only. WorkflowTemplates list.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Output only. This token is included in the response if there are more
        #     results to fetch. To fetch additional results, provide this value as the
        #     page_token in a subsequent <code>ListWorkflowTemplatesRequest</code>.
        class ListWorkflowTemplatesResponse; end

        # A request to delete a workflow template.
        #
        # Currently started workflows will remain running.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The "resource name" of the workflow template, as described
        #     in https://cloud.google.com/apis/design/resource_names of the form
        #     `projects/{project_id}/regions/{region}/workflowTemplates/{template_id}`
        # @!attribute [rw] version
        #   @return [Integer]
        #     Optional. The version of workflow template to delete. If specified,
        #     will only delete the template if the current server version matches
        #     specified version.
        class DeleteWorkflowTemplateRequest; end
      end
    end
  end
end