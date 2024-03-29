# frozen_string_literal: true

# Copyright 2023 Google LLC
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
    module SecurityCenter
      module V1
        # Represents an instance of a Security Health Analytics custom module,
        # including its full module name, display name, enablement state, and last
        # updated time. You can create a custom module at the organization, folder, or
        # project level. Custom modules that you create at the organization or folder
        # level are inherited by the child folders and projects.
        # @!attribute [rw] name
        #   @return [::String]
        #     Immutable. The resource name of the custom module.
        #     Its format is
        #     "organizations/\\{organization}/securityHealthAnalyticsSettings/customModules/\\{customModule}",
        #     or
        #     "folders/\\{folder}/securityHealthAnalyticsSettings/customModules/\\{customModule}",
        #     or
        #     "projects/\\{project}/securityHealthAnalyticsSettings/customModules/\\{customModule}"
        #
        #     The id \\{customModule} is server-generated and is not user settable.
        #     It will be a numeric id containing 1-20 digits.
        # @!attribute [rw] display_name
        #   @return [::String]
        #     The display name of the Security Health Analytics custom module. This
        #     display name becomes the finding category for all findings that are
        #     returned by this custom module. The display name must be between 1 and
        #     128 characters, start with a lowercase letter, and contain alphanumeric
        #     characters or underscores only.
        # @!attribute [rw] enablement_state
        #   @return [::Google::Cloud::SecurityCenter::V1::SecurityHealthAnalyticsCustomModule::EnablementState]
        #     The enablement state of the custom module.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The time at which the custom module was last updated.
        # @!attribute [r] last_editor
        #   @return [::String]
        #     Output only. The editor that last updated the custom module.
        # @!attribute [r] ancestor_module
        #   @return [::String]
        #     Output only. If empty, indicates that the custom module was created in the
        #     organization, folder, or project in which you are viewing the custom
        #     module. Otherwise, `ancestor_module` specifies the organization or folder
        #     from which the custom module is inherited.
        # @!attribute [rw] custom_config
        #   @return [::Google::Cloud::SecurityCenter::V1::CustomConfig]
        #     The user specified custom configuration for the module.
        class SecurityHealthAnalyticsCustomModule
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Possible enablement states of a custom module.
          module EnablementState
            # Unspecified enablement state.
            ENABLEMENT_STATE_UNSPECIFIED = 0

            # The module is enabled at the given CRM resource.
            ENABLED = 1

            # The module is disabled at the given CRM resource.
            DISABLED = 2

            # State is inherited from an ancestor module. The module will either
            # be effectively ENABLED or DISABLED based on its closest non-inherited
            # ancestor module in the CRM hierarchy.
            INHERITED = 3
          end
        end
      end
    end
  end
end
