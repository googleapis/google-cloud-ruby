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
        ##
        # # Binding
        #
        # Value object associating members and an optional condition with a role.
        #
        # @see https://cloud.google.com/iam/docs/overview Cloud IAM Overview
        #
        # @attr [String] role Role that is assigned to members. For example,
        #   `roles/viewer`, `roles/editor`, or `roles/owner`. Required.
        # @attr [Array<String>] members Specifies the identities requesting
        #   access for a Cloud Platform resource. members can have the
        #   following values. Required.
        #
        #   * `allUsers`: A special identifier that represents anyone who is on
        #     the internet; with or without a Google account.
        #   * `allAuthenticatedUsers`: A special identifier that represents
        #      anyone who is authenticated with a Google account or a service
        #      account.
        #   * `user:{emailid}`: An email address that represents a specific
        #     Google account. For example, `alice@example.com`.
        #   * `serviceAccount:{emailid}`: An email address that represents a
        #     service account. For example, `my-other-app@appspot.gserviceaccount.com`.
        #   * `group:{emailid}`: An email address that represents a Google group.
        #     For example, `admins@example.com`.
        #   * `domain:{domain}`: The G Suite domain (primary) that represents
        #     all the users of that domain. For example, `google.com` or
        #     `example.com`. Required.
        #
        # @attr [Google::Cloud::Storage::Policy::Condition] condition The
        #   condition that is associated with this binding. NOTE: An unsatisfied
        #   condition will not allow user access via current binding. Different
        #   bindings, including their conditions, are examined independently.
        #   Optional.
        #
        # @example Updating a Policy from version 1 to version 3:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-todo-app"
        #
        #   bucket.policy requested_policy_version: 3 do |p|
        #     p.version # 1
        #     p.version = 3 # Must be explicitly set to opt-in to support for conditions.
        #     p.bindings.insert({
        #                         role: "roles/storage.admin",
        #                         members: ["user:owner@example.com"],
        #                         condition: {
        #                           title: "test-condition",
        #                           description: "description of condition",
        #                           expression: "expr1"
        #                         }
        #                       })
        #   end
        #
        class Binding
          attr_reader :role, :members, :condition

          ##
          # Creates a Binding object.
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
