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
  module Spanner
    module Admin
      module Instance
        module V1
          # A possible configuration for a Cloud Spanner instance. Configurations
          # define the geographic placement of nodes and their replication.
          # @!attribute [rw] name
          #   @return [String]
          #     A unique identifier for the instance configuration.  Values
          #     are of the form
          #     +projects/<project>/instanceConfigs/[a-z][-a-z0-9]*+
          # @!attribute [rw] display_name
          #   @return [String]
          #     The name of this instance configuration as it appears in UIs.
          class InstanceConfig; end

          # An isolated set of Cloud Spanner resources on which databases can be hosted.
          # @!attribute [rw] name
          #   @return [String]
          #     Required. A unique identifier for the instance, which cannot be changed
          #     after the instance is created. Values are of the form
          #     +projects/<project>/instances/[a-z][-a-z0-9]*[a-z0-9]+. The final
          #     segment of the name must be between 6 and 30 characters in length.
          # @!attribute [rw] config
          #   @return [String]
          #     Required. The name of the instance's configuration. Values are of the form
          #     +projects/<project>/instanceConfigs/<configuration>+. See
          #     also {Google::Spanner::Admin::Instance::V1::InstanceConfig InstanceConfig} and
          #     {Google::Spanner::Admin::Instance::V1::InstanceAdmin::ListInstanceConfigs ListInstanceConfigs}.
          # @!attribute [rw] display_name
          #   @return [String]
          #     Required. The descriptive name for this instance as it appears in UIs.
          #     Must be unique per project and between 4 and 30 characters in length.
          # @!attribute [rw] node_count
          #   @return [Integer]
          #     Required. The number of nodes allocated to this instance. This may be zero
          #     in API responses for instances that are not yet in state +READY+.
          #
          #     See [the documentation](https://cloud.google.com/spanner/docs/instances#node_count)
          #     for more information about nodes.
          # @!attribute [rw] state
          #   @return [Google::Spanner::Admin::Instance::V1::Instance::State]
          #     Output only. The current instance state. For
          #     {Google::Spanner::Admin::Instance::V1::InstanceAdmin::CreateInstance CreateInstance}, the state must be
          #     either omitted or set to +CREATING+. For
          #     {Google::Spanner::Admin::Instance::V1::InstanceAdmin::UpdateInstance UpdateInstance}, the state must be
          #     either omitted or set to +READY+.
          # @!attribute [rw] labels
          #   @return [Hash{String => String}]
          #     Cloud Labels are a flexible and lightweight mechanism for organizing cloud
          #     resources into groups that reflect a customer's organizational needs and
          #     deployment strategies. Cloud Labels can be used to filter collections of
          #     resources. They can be used to control how resource metrics are aggregated.
          #     And they can be used as arguments to policy management rules (e.g. route,
          #     firewall, load balancing, etc.).
          #
          #     * Label keys must be between 1 and 63 characters long and must conform to
          #       the following regular expression: +[a-z](https://cloud.google.com[-a-z0-9]*[a-z0-9])?+.
          #     * Label values must be between 0 and 63 characters long and must conform
          #       to the regular expression +([a-z](https://cloud.google.com[-a-z0-9]*[a-z0-9])?)?+.
          #     * No more than 64 labels can be associated with a given resource.
          #
          #     See https://goo.gl/xmQnxf for more information on and examples of labels.
          #
          #     If you plan to use labels in your own code, please note that additional
          #     characters may be allowed in the future. And so you are advised to use an
          #     internal label representation, such as JSON, which doesn't rely upon
          #     specific characters being disallowed.  For example, representing labels
          #     as the string:  name + "_" + value  would prove problematic if we were to
          #     allow "_" in a future release.
          class Instance
            # Indicates the current state of the instance.
            module State
              # Not specified.
              STATE_UNSPECIFIED = 0

              # The instance is still being created. Resources may not be
              # available yet, and operations such as database creation may not
              # work.
              CREATING = 1

              # The instance is fully created and ready to do work such as
              # creating databases.
              READY = 2
            end
          end

          # The request for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::ListInstanceConfigs ListInstanceConfigs}.
          # @!attribute [rw] parent
          #   @return [String]
          #     Required. The name of the project for which a list of supported instance
          #     configurations is requested. Values are of the form
          #     +projects/<project>+.
          # @!attribute [rw] page_size
          #   @return [Integer]
          #     Number of instance configurations to be returned in the response. If 0 or
          #     less, defaults to the server's maximum allowed page size.
          # @!attribute [rw] page_token
          #   @return [String]
          #     If non-empty, +page_token+ should contain a
          #     {Google::Spanner::Admin::Instance::V1::ListInstanceConfigsResponse#next_page_token next_page_token}
          #     from a previous {Google::Spanner::Admin::Instance::V1::ListInstanceConfigsResponse ListInstanceConfigsResponse}.
          class ListInstanceConfigsRequest; end

          # The response for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::ListInstanceConfigs ListInstanceConfigs}.
          # @!attribute [rw] instance_configs
          #   @return [Array<Google::Spanner::Admin::Instance::V1::InstanceConfig>]
          #     The list of requested instance configurations.
          # @!attribute [rw] next_page_token
          #   @return [String]
          #     +next_page_token+ can be sent in a subsequent
          #     {Google::Spanner::Admin::Instance::V1::InstanceAdmin::ListInstanceConfigs ListInstanceConfigs} call to
          #     fetch more of the matching instance configurations.
          class ListInstanceConfigsResponse; end

          # The request for
          # {Google::Spanner::Admin::Instance::V1::InstanceAdmin::GetInstanceConfig GetInstanceConfigRequest}.
          # @!attribute [rw] name
          #   @return [String]
          #     Required. The name of the requested instance configuration. Values are of
          #     the form +projects/<project>/instanceConfigs/<config>+.
          class GetInstanceConfigRequest; end

          # The request for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::GetInstance GetInstance}.
          # @!attribute [rw] name
          #   @return [String]
          #     Required. The name of the requested instance. Values are of the form
          #     +projects/<project>/instances/<instance>+.
          class GetInstanceRequest; end

          # The request for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::CreateInstance CreateInstance}.
          # @!attribute [rw] parent
          #   @return [String]
          #     Required. The name of the project in which to create the instance. Values
          #     are of the form +projects/<project>+.
          # @!attribute [rw] instance_id
          #   @return [String]
          #     Required. The ID of the instance to create.  Valid identifiers are of the
          #     form +[a-z][-a-z0-9]*[a-z0-9]+ and must be between 6 and 30 characters in
          #     length.
          # @!attribute [rw] instance
          #   @return [Google::Spanner::Admin::Instance::V1::Instance]
          #     Required. The instance to create.  The name may be omitted, but if
          #     specified must be +<parent>/instances/<instance_id>+.
          class CreateInstanceRequest; end

          # The request for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::ListInstances ListInstances}.
          # @!attribute [rw] parent
          #   @return [String]
          #     Required. The name of the project for which a list of instances is
          #     requested. Values are of the form +projects/<project>+.
          # @!attribute [rw] page_size
          #   @return [Integer]
          #     Number of instances to be returned in the response. If 0 or less, defaults
          #     to the server's maximum allowed page size.
          # @!attribute [rw] page_token
          #   @return [String]
          #     If non-empty, +page_token+ should contain a
          #     {Google::Spanner::Admin::Instance::V1::ListInstancesResponse#next_page_token next_page_token} from a
          #     previous {Google::Spanner::Admin::Instance::V1::ListInstancesResponse ListInstancesResponse}.
          # @!attribute [rw] filter
          #   @return [String]
          #     An expression for filtering the results of the request. Filter rules are
          #     case insensitive. The fields eligible for filtering are:
          #
          #     * +name+
          #       * +display_name+
          #       * +labels.key+ where key is the name of a label
          #
          #       Some examples of using filters are:
          #
          #       * +name:*+ --> The instance has a name.
          #       * +name:Howl+ --> The instance's name contains the string "howl".
          #       * +name:HOWL+ --> Equivalent to above.
          #       * +NAME:howl+ --> Equivalent to above.
          #       * +labels.env:*+ --> The instance has the label "env".
          #       * +labels.env:dev+ --> The instance has the label "env" and the value of
          #         the label contains the string "dev".
          #       * +name:howl labels.env:dev+ --> The instance's name contains "howl" and
          #         it has the label "env" with its value
          #         containing "dev".
          class ListInstancesRequest; end

          # The response for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::ListInstances ListInstances}.
          # @!attribute [rw] instances
          #   @return [Array<Google::Spanner::Admin::Instance::V1::Instance>]
          #     The list of requested instances.
          # @!attribute [rw] next_page_token
          #   @return [String]
          #     +next_page_token+ can be sent in a subsequent
          #     {Google::Spanner::Admin::Instance::V1::InstanceAdmin::ListInstances ListInstances} call to fetch more
          #     of the matching instances.
          class ListInstancesResponse; end

          # The request for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::UpdateInstance UpdateInstance}.
          # @!attribute [rw] instance
          #   @return [Google::Spanner::Admin::Instance::V1::Instance]
          #     Required. The instance to update, which must always include the instance
          #     name.  Otherwise, only fields mentioned in [][google.spanner.admin.instance.v1.UpdateInstanceRequest.field_mask] need be included.
          # @!attribute [rw] field_mask
          #   @return [Google::Protobuf::FieldMask]
          #     Required. A mask specifying which fields in [][google.spanner.admin.instance.v1.UpdateInstanceRequest.instance] should be updated.
          #     The field mask must always be specified; this prevents any future fields in
          #     [][google.spanner.admin.instance.v1.Instance] from being erased accidentally by clients that do not know
          #     about them.
          class UpdateInstanceRequest; end

          # The request for {Google::Spanner::Admin::Instance::V1::InstanceAdmin::DeleteInstance DeleteInstance}.
          # @!attribute [rw] name
          #   @return [String]
          #     Required. The name of the instance to be deleted. Values are of the form
          #     +projects/<project>/instances/<instance>+
          class DeleteInstanceRequest; end

          # Metadata type for the operation returned by
          # {Google::Spanner::Admin::Instance::V1::InstanceAdmin::CreateInstance CreateInstance}.
          # @!attribute [rw] instance
          #   @return [Google::Spanner::Admin::Instance::V1::Instance]
          #     The instance being created.
          # @!attribute [rw] start_time
          #   @return [Google::Protobuf::Timestamp]
          #     The time at which the
          #     {Google::Spanner::Admin::Instance::V1::InstanceAdmin::CreateInstance CreateInstance} request was
          #     received.
          # @!attribute [rw] cancel_time
          #   @return [Google::Protobuf::Timestamp]
          #     The time at which this operation was cancelled. If set, this operation is
          #     in the process of undoing itself (which is guaranteed to succeed) and
          #     cannot be cancelled again.
          # @!attribute [rw] end_time
          #   @return [Google::Protobuf::Timestamp]
          #     The time at which this operation failed or was completed successfully.
          class CreateInstanceMetadata; end

          # Metadata type for the operation returned by
          # {Google::Spanner::Admin::Instance::V1::InstanceAdmin::UpdateInstance UpdateInstance}.
          # @!attribute [rw] instance
          #   @return [Google::Spanner::Admin::Instance::V1::Instance]
          #     The desired end state of the update.
          # @!attribute [rw] start_time
          #   @return [Google::Protobuf::Timestamp]
          #     The time at which {Google::Spanner::Admin::Instance::V1::InstanceAdmin::UpdateInstance UpdateInstance}
          #     request was received.
          # @!attribute [rw] cancel_time
          #   @return [Google::Protobuf::Timestamp]
          #     The time at which this operation was cancelled. If set, this operation is
          #     in the process of undoing itself (which is guaranteed to succeed) and
          #     cannot be cancelled again.
          # @!attribute [rw] end_time
          #   @return [Google::Protobuf::Timestamp]
          #     The time at which this operation failed or was completed successfully.
          class UpdateInstanceMetadata; end
        end
      end
    end
  end
end