# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/errors"
require "google/apis/storage_v1"

module Google
  module Cloud
    module Storage
      ##
      # # Policy
      #
      # Represents a Cloud IAM Policy for the Cloud Storage service.
      #
      # A common pattern for updating a resource's metadata, such as its Policy,
      # is to read the current data from the service, update the data locally,
      # and then send the modified data for writing. This pattern may result in
      # a conflict if two or more processes attempt the sequence simultaneously.
      # IAM solves this problem with the
      # {Google::Cloud::Storage::Policy#etag} property, which is used to
      # verify whether the policy has changed since the last request. When you
      # make a request to with an `etag` value, Cloud IAM compares the `etag`
      # value in the request with the existing `etag` value associated with the
      # policy. It writes the policy only if the `etag` values match.
      #
      # When you update a policy, first read the policy (and its current `etag`)
      # from the service, then modify the policy locally, and then write the
      # modified policy to the service. See
      # {Google::Cloud::Storage::Bucket#policy} and
      # {Google::Cloud::Storage::Bucket#policy=}.
      #
      # @see https://cloud.google.com/iam/docs/managing-policies Managing
      #   policies
      # @see https://cloud.google.com/storage/docs/json_api/v1/buckets/setIamPolicy
      #   Buckets: setIamPolicy
      #
      # @attr [String] etag Used to verify whether the policy has changed since
      #   the last request. The policy will be written only if the `etag` values
      #   match.
      # @attr [Hash{String => Array<String>}] roles The bindings that associate
      #   roles with an array of members. See [Understanding
      #   Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
      #   listing of primitive and curated roles. See [Buckets:
      #   setIamPolicy](https://cloud.google.com/storage/docs/json_api/v1/buckets/setIamPolicy)
      #   for a listing of values and patterns for members.
      #
      # @example
      #   require "google/cloud/storage"
      #
      #   storage = Google::Cloud::Storage.new
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.policy do |p|
      #     p.remove "roles/storage.admin", "user:owner@example.com"
      #     p.add "roles/storage.admin", "user:newowner@example.com"
      #     p.roles["roles/storage.objectViewer"] = ["allUsers"]
      #   end
      #
      class Policy
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Creates a Policy object.
        def initialize
          @service = nil
          @gapi = Google::Apis::StorageV1::Policy.new
        end

        ##
        # The name of the bucket.
        def resource_id
          @gapi.resource_id
        end

        ##
        # HTTP 1.1 Entity tag for the policy.
        def etag
          @gapi.etag
        end

        ##
        # Convenience method for adding a member to a binding on this policy.
        # See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # listing of primitive and curated roles. See [Buckets:
        # setIamPolicy](https://cloud.google.com/storage/docs/json_api/v1/buckets/setIamPolicy)
        # for a listing of values and patterns for members.
        #
        # @param [String] role_name A Cloud IAM role, such as
        #   `"roles/storage.admin"`.
        # @param [String] member A Cloud IAM identity, such as
        #   `"user:owner@example.com"`.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   bucket.policy do |p|
        #     p.add "roles/storage.admin", "user:newowner@example.com"
        #   end
        #
        def add role_name, member
          role(role_name) << member
        end

        ##
        # Convenience method for removing a member from a binding on this
        # policy. See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # listing of primitive and curated roles. See [Buckets:
        # setIamPolicy](https://cloud.google.com/storage/docs/json_api/v1/buckets/setIamPolicy)
        # for a listing of values and patterns for members.
        #
        # @param [String] role_name A Cloud IAM role, such as
        #   `"roles/storage.admin"`.
        # @param [String] member A Cloud IAM identity, such as
        #   `"user:owner@example.com"`.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   bucket.policy do |p|
        #     p.remove "roles/storage.admin", "user:owner@example.com"
        #   end
        #
        def remove role_name, member
          role(role_name).delete member
        end

        def roles
          @roles ||= @gapi.bindings.each_with_object({}) do |binding, memo|
            memo[binding.role] = binding.members.to_a
          end
        end

        ##
        # Convenience method returning the array of members bound to a role in
        # this policy, or an empty array if no value is present for the role in
        # {#roles}. See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # listing of primitive and curated roles. See [Buckets:
        # setIamPolicy](https://cloud.google.com/storage/docs/json_api/v1/buckets/setIamPolicy)
        # for a listing of values and patterns for members.
        #
        # @return [Array<String>] The members strings, or an empty array.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   bucket.policy do |p|
        #     p.role("roles/storage.admin") << "user:owner@example.com"
        #   end
        #
        def role role_name
          roles[role_name] ||= []
        end

        ##
        # Returns a deep copy of the policy. The service object referenced by
        # the policy is not duplicated.
        #
        # @return [Policy]
        #
        def deep_dup
          dup.tap do |p|
            gapi_dup = @gapi.dup
            bindings_dup =  @gapi.bindings.map do |binding|
              binding_dup = binding.dup
              binding_dup.members = binding.members.dup
              binding_dup
            end
            gapi_dup.bindings = bindings_dup
            p.gapi = gapi_dup
          end
        end

        ##
        # Reloads the policy with current data from the Cloud IAM service.
        #
        # @example Retrieve the latest policy from the service:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   policy = bucket.policy force: true # API call
        #   policy_2 = policy.reload! # API call
        #
        def reload!
          ensure_service!
          bucket_name = resource_id.split("/").last
          # TODO: replace line above with regex supporting generation
          # TODO: conditional for get_object_policy
          @gapi = service.get_bucket_policy bucket_name
        end
        alias_method :refresh!, :reload!

        ##
        # @private Convert the Policy to a
        # Google::Apis::StorageV1::Policy.
        def to_gapi
          @gapi.bindings = roles.keys.map do |role_name|
            next if roles[role_name].empty?
            Google::Apis::StorageV1::Policy::Binding.new(
              role: role_name,
              members: roles[role_name]
            )
          end
          @gapi
        end

        ##
        # @private New Policy from a
        # Google::Apis::StorageV1::Policy object.
        def self.from_gapi gapi, conn
          new.tap do |f|
            f.gapi = gapi
            f.service = conn
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end
      end
    end
  end
end
