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


require "google/cloud/storage/policy/binding"

module Google
  module Cloud
    module Storage
      class Policy
        ##
        # # Bindings
        #
        # Enumerable object for managing Cloud IAM bindings associated with
        # a bucket.
        #
        # @see https://cloud.google.com/iam/docs/overview Cloud IAM Overview
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
        class Bindings
          include Enumerable

          ##
          # @private Creates a Bindings object.
          def initialize
            @bindings = []
          end

          def insert *bindings
            bindings = coerce_bindings(*bindings)
            @bindings += bindings
          end

          def remove *bindings
            bindings = coerce_bindings(*bindings)
            @bindings -= bindings
          end

          def each
            return enum_for :each unless block_given?

            @bindings.each { |binding| yield binding }
          end

          def to_gapi
            @bindings.map(&:to_gapi)
          end

          protected

          def coerce_bindings *bindings
            bindings.map do |binding|
              binding = Binding.new(**binding) if binding.is_a? Hash
              raise ArgumentError, "expected Binding, not #{binding.inspect}" unless binding.is_a? Binding
              binding
            end
          end
        end
      end
    end
  end
end
