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
  module Apps
    module Script
      module Type
        # The widget subset used by an add-on.
        # @!attribute [rw] used_widgets
        #   @return [::Array<::Google::Apps::Script::Type::AddOnWidgetSet::WidgetType>]
        #     The list of widgets used in an add-on.
        class AddOnWidgetSet
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # The Widget type. DEFAULT is the basic widget set.
          module WidgetType
            # The default widget set.
            WIDGET_TYPE_UNSPECIFIED = 0

            # The date picker.
            DATE_PICKER = 1

            # Styled buttons include filled buttons and disabled buttons.
            STYLED_BUTTONS = 2

            # Persistent forms allow persisting form values during actions.
            PERSISTENT_FORMS = 3

            # Fixed footer in card.
            FIXED_FOOTER = 4

            # Update the subject and recipients of a draft.
            UPDATE_SUBJECT_AND_RECIPIENTS = 5

            # The grid widget.
            GRID_WIDGET = 6

            # A Gmail add-on action that applies to the addon compose UI.
            ADDON_COMPOSE_UI_ACTION = 7
          end
        end
      end
    end
  end
end
