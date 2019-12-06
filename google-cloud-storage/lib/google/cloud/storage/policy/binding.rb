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


require "google/cloud/storage/policy/condition"

module Google
  module Cloud
    module Storage
      class Policy
        class Binding
          attr_reader :role, :members, :condition

          def initialize role:, members:, condition: nil
            @role = String role

            @members = Array members
            raise ArgumentError, "members is empty, must be provided" if @members.empty?

            condition = Condition.new(**condition) if condition.is_a? Hash
            if condition
              raise ArgumentError, "expected Condition, not #{condition.inspect}" unless condition.is_a? Condition
            end
            @condition = condition
          end

          def role= new_role
            @role = String new_role
          end

          def members= new_members
            new_members = Array new_members
            raise ArgumentError, "members is empty, must be provided" if new_members.empty?
            @members = new_members
          end

          # TODO: overload method signature, showing a Condition and named arguments
          def condition= new_condition
            new_condition = Condition.new(**new_condition) if new_condition.is_a? Hash
            if new_condition && !new_condition.is_a?(Condition)
              raise ArgumentError, "expected Condition, not #{new_condition.inspect}"
            end
            @condition = new_condition
          end

          ##
          # @private
          def <=> other
            return nil unless other.is_a? Binding

            ret = role <=> other.role
            return ret unless ret.zero?
            ret = members <=> other.members
            return ret unless ret.zero?
            condition&.to_gapi <=> other.condition&.to_gapi
          end

          ##
          # @private
          def eql? other
            role.eql?(other.role) &&
              members.eql?(other.members) &&
              condition&.to_gapi.eql?(other.condition&.to_gapi)
          end

          ##
          # @private
          def hash
            [
              @role,
              @members,
              @condition&.to_gapi
            ].hash
          end

          ##
          # @private
          def to_gapi
            Google::Apis::StorageV1::Policy::Binding.new({
              role: @role,
              members: @members,
              condition: @condition&.to_gapi
            }.delete_if { |_, v| v.nil? })
          end
        end
      end
    end
  end
end
