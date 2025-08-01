# frozen_string_literal: true

# Copyright 2025 Google LLC
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
    module OrgPolicy
      module V2
        # A constraint describes a way to restrict resource's configuration. For
        # example, you could enforce a constraint that controls which Google Cloud
        # services can be activated across an organization, or whether a Compute Engine
        # instance can have serial port connections established. Constraints can be
        # configured by the organization policy administrator to fit the needs of the
        # organization by setting a policy that includes constraints at different
        # locations in the organization's resource hierarchy. Policies are inherited
        # down the resource hierarchy from higher levels, but can also be overridden.
        # For details about the inheritance rules, see
        # {::Google::Cloud::OrgPolicy::V2::Policy `Policy`}.
        #
        # Constraints have a default behavior determined by the `constraint_default`
        # field, which is the enforcement behavior that is used in the absence of a
        # policy being defined or inherited for the resource in question.
        # @!attribute [rw] name
        #   @return [::String]
        #     Immutable. The resource name of the constraint. Must be in one of
        #     the following forms:
        #
        #     * `projects/{project_number}/constraints/{constraint_name}`
        #     * `folders/{folder_id}/constraints/{constraint_name}`
        #     * `organizations/{organization_id}/constraints/{constraint_name}`
        #
        #     For example, "/projects/123/constraints/compute.disableSerialPortAccess".
        # @!attribute [rw] display_name
        #   @return [::String]
        #     The human readable name.
        #
        #     Mutable.
        # @!attribute [rw] description
        #   @return [::String]
        #     Detailed description of what this constraint controls as well as how and
        #     where it is enforced.
        #
        #     Mutable.
        # @!attribute [rw] constraint_default
        #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::ConstraintDefault]
        #     The evaluation behavior of this constraint in the absence of a policy.
        # @!attribute [rw] list_constraint
        #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::ListConstraint]
        #     Defines this constraint as being a list constraint.
        #
        #     Note: The following fields are mutually exclusive: `list_constraint`, `boolean_constraint`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] boolean_constraint
        #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::BooleanConstraint]
        #     Defines this constraint as being a boolean constraint.
        #
        #     Note: The following fields are mutually exclusive: `boolean_constraint`, `list_constraint`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] supports_dry_run
        #   @return [::Boolean]
        #     Shows if dry run is supported for this constraint or not.
        # @!attribute [rw] equivalent_constraint
        #   @return [::String]
        #     Managed constraint and canned constraint sometimes can have
        #     equivalents. This field is used to store the equivalent constraint name.
        # @!attribute [rw] supports_simulation
        #   @return [::Boolean]
        #     Shows if simulation is supported for this constraint or not.
        class Constraint
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # A constraint type that allows or disallows a list of string values, which
          # are configured in the
          # {::Google::Cloud::OrgPolicy::V2::PolicySpec::PolicyRule `PolicyRule`}.
          # @!attribute [rw] supports_in
          #   @return [::Boolean]
          #     Indicates whether values grouped into categories can be used in
          #     `Policy.allowed_values` and `Policy.denied_values`. For example,
          #     `"in:Python"` would match any value in the 'Python' group.
          # @!attribute [rw] supports_under
          #   @return [::Boolean]
          #     Indicates whether subtrees of the Resource Manager resource hierarchy
          #     can be used in `Policy.allowed_values` and `Policy.denied_values`. For
          #     example, `"under:folders/123"` would match any resource under the
          #     'folders/123' folder.
          class ListConstraint
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Custom constraint definition. Defines this as a managed constraint.
          # @!attribute [rw] resource_types
          #   @return [::Array<::String>]
          #     The resource instance type on which this policy applies. Format will be
          #     of the form : `<service name>/<type>` Example:
          #
          #      * `compute.googleapis.com/Instance`.
          # @!attribute [rw] method_types
          #   @return [::Array<::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::MethodType>]
          #     All the operations being applied for this constraint.
          # @!attribute [rw] condition
          #   @return [::String]
          #     Org policy condition/expression. For example:
          #     `resource.instanceName.matches("[production|test]_.*_(\d)+")` or,
          #     `resource.management.auto_upgrade == true`
          #
          #     The max length of the condition is 1000 characters.
          # @!attribute [rw] action_type
          #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::ActionType]
          #     Allow or deny type.
          # @!attribute [rw] parameters
          #   @return [::Google::Protobuf::Map{::String => ::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::Parameter}]
          #     Stores the structure of
          #     {::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::Parameter `Parameters`}
          #     used by the constraint condition. The key of `map` represents the name of
          #     the parameter.
          class CustomConstraintDefinition
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Defines a parameter structure.
            # @!attribute [rw] type
            #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::Parameter::Type]
            #     Type of the parameter.
            # @!attribute [rw] default_value
            #   @return [::Google::Protobuf::Value]
            #     Sets the value of the parameter in an assignment if no value is given.
            # @!attribute [rw] valid_values_expr
            #   @return [::String]
            #     Provides a CEL expression to specify the acceptable parameter values
            #     during assignment.
            #     For example, parameterName in ("parameterValue1", "parameterValue2")
            # @!attribute [rw] metadata
            #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::Parameter::Metadata]
            #     Defines subproperties primarily used by the UI to display user-friendly
            #     information.
            # @!attribute [rw] item
            #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::Parameter::Type]
            #     Determines the parameter's value structure.
            #     For example, `LIST<STRING>` can be specified by defining `type: LIST`,
            #     and `item: STRING`.
            class Parameter
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # Defines Metadata structure.
              # @!attribute [rw] description
              #   @return [::String]
              #     Detailed description of what this `parameter` is and use of it.
              #     Mutable.
              class Metadata
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods
              end

              # All valid types of parameter.
              module Type
                # This is only used for distinguishing unset values and should never be
                # used. Results in an error.
                TYPE_UNSPECIFIED = 0

                # List parameter type.
                LIST = 1

                # String parameter type.
                STRING = 2

                # Boolean parameter type.
                BOOLEAN = 3
              end
            end

            # @!attribute [rw] key
            #   @return [::String]
            # @!attribute [rw] value
            #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition::Parameter]
            class ParametersEntry
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # The operation for which this constraint will be applied. To apply this
            # constraint only when creating new resources, the `method_types` should be
            # `CREATE` only. To apply this constraint when creating or deleting
            # resources, the `method_types` should be `CREATE` and `DELETE`.
            #
            # `UPDATE`-only custom constraints are not supported. Use `CREATE` or
            # `CREATE, UPDATE`.
            module MethodType
              # This is only used for distinguishing unset values and should never be
              # used. Results in an error.
              METHOD_TYPE_UNSPECIFIED = 0

              # Constraint applied when creating the resource.
              CREATE = 1

              # Constraint applied when updating the resource.
              UPDATE = 2

              # Constraint applied when deleting the resource.
              # Not currently supported.
              DELETE = 3

              # Constraint applied when removing an IAM grant.
              REMOVE_GRANT = 4

              # Constraint applied when enforcing forced tagging.
              GOVERN_TAGS = 5
            end

            # Allow or deny type.
            module ActionType
              # This is only used for distinguishing unset values and should never be
              # used. Results in an error.
              ACTION_TYPE_UNSPECIFIED = 0

              # Allowed action type.
              ALLOW = 1

              # Deny action type.
              DENY = 2
            end
          end

          # A constraint type is enforced or not enforced, which is configured in the
          # {::Google::Cloud::OrgPolicy::V2::PolicySpec::PolicyRule `PolicyRule`}.
          #
          # If `customConstraintDefinition` is defined, this constraint is a managed
          # constraint.
          # @!attribute [rw] custom_constraint_definition
          #   @return [::Google::Cloud::OrgPolicy::V2::Constraint::CustomConstraintDefinition]
          #     Custom constraint definition. Defines this as a managed constraint.
          class BooleanConstraint
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Specifies the default behavior in the absence of any policy for the
          # constraint. This must not be `CONSTRAINT_DEFAULT_UNSPECIFIED`.
          #
          # Immutable after creation.
          module ConstraintDefault
            # This is only used for distinguishing unset values and should never be
            # used. Results in an error.
            CONSTRAINT_DEFAULT_UNSPECIFIED = 0

            # Indicate that all values are allowed for list constraints.
            # Indicate that enforcement is off for boolean constraints.
            ALLOW = 1

            # Indicate that all values are denied for list constraints.
            # Indicate that enforcement is on for boolean constraints.
            DENY = 2
          end
        end

        # A custom constraint defined by customers which can *only* be applied to the
        # given resource types and organization.
        #
        # By creating a custom constraint, customers can apply policies of this
        # custom constraint. *Creating a custom constraint itself does NOT apply any
        # policy enforcement*.
        # @!attribute [rw] name
        #   @return [::String]
        #     Immutable. Name of the constraint. This is unique within the organization.
        #     Format of the name should be
        #
        #     * `organizations/{organization_id}/customConstraints/{custom_constraint_id}`
        #
        #     Example: `organizations/123/customConstraints/custom.createOnlyE2TypeVms`
        #
        #     The max length is 70 characters and the minimum length is 1. Note that the
        #     prefix `organizations/{organization_id}/customConstraints/` is not counted.
        # @!attribute [rw] resource_types
        #   @return [::Array<::String>]
        #     Immutable. The resource instance type on which this policy applies. Format
        #     will be of the form : `<service name>/<type>` Example:
        #
        #      * `compute.googleapis.com/Instance`.
        # @!attribute [rw] method_types
        #   @return [::Array<::Google::Cloud::OrgPolicy::V2::CustomConstraint::MethodType>]
        #     All the operations being applied for this constraint.
        # @!attribute [rw] condition
        #   @return [::String]
        #     A Common Expression Language (CEL) condition which is used in the
        #     evaluation of the constraint. For example:
        #     `resource.instanceName.matches("[production|test]_.*_(\d)+")` or,
        #     `resource.management.auto_upgrade == true`
        #
        #     The max length of the condition is 1000 characters.
        # @!attribute [rw] action_type
        #   @return [::Google::Cloud::OrgPolicy::V2::CustomConstraint::ActionType]
        #     Allow or deny type.
        # @!attribute [rw] display_name
        #   @return [::String]
        #     One line display name for the UI.
        #     The max length of the display_name is 200 characters.
        # @!attribute [rw] description
        #   @return [::String]
        #     Detailed information about this custom policy constraint.
        #     The max length of the description is 2000 characters.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The last time this custom constraint was updated. This
        #     represents the last time that the `CreateCustomConstraint` or
        #     `UpdateCustomConstraint` methods were called.
        class CustomConstraint
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # The operation for which this constraint will be applied. To apply this
          # constraint only when creating new resources, the `method_types` should be
          # `CREATE` only. To apply this constraint when creating or deleting
          # resources, the `method_types` should be `CREATE` and `DELETE`.
          #
          # `UPDATE` only custom constraints are not supported. Use `CREATE` or
          # `CREATE, UPDATE`.
          module MethodType
            # This is only used for distinguishing unset values and should never be
            # used. Results in an error.
            METHOD_TYPE_UNSPECIFIED = 0

            # Constraint applied when creating the resource.
            CREATE = 1

            # Constraint applied when updating the resource.
            UPDATE = 2

            # Constraint applied when deleting the resource.
            # Not currently supported.
            DELETE = 3

            # Constraint applied when removing an IAM grant.
            REMOVE_GRANT = 4

            # Constraint applied when enforcing forced tagging.
            GOVERN_TAGS = 5
          end

          # Allow or deny type.
          module ActionType
            # This is only used for distinguishing unset values and should never be
            # used. Results in an error.
            ACTION_TYPE_UNSPECIFIED = 0

            # Allowed action type.
            ALLOW = 1

            # Deny action type.
            DENY = 2
          end
        end
      end
    end
  end
end
