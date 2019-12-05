# Copyright 2019 Google LLC
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
    module Storage
      class Policy
        class Condition
          attr_reader :title, :description, :expression
          def initialize title:, description:, expression:
            @title = String title
            @description = String description
            @expression = String expression
          end

          def title= new_title
            @title = String new_title
          end

          def description= new_description
            @description = String new_description
          end

          def expression= new_expression
            @expression = String new_expression
          end

          def to_gapi
            {
              title: @title,
              description: @description,
              expression: @expression
            }.delete_if { |_, v| v.nil? }
          end
        end
      end
    end
  end
end
