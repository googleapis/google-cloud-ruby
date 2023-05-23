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
    module Bigtable
      ##
      # # Policy
      #
      # Represents a Cloud IAM Policy for Bigtable resources.
      #
      # A common pattern for updating a resource's metadata, such as its policy,
      # is to read the current data from the service, update the data locally,
      # and then write the modified data back to the resource. This pattern may
      # result in a conflict if two or more processes attempt the sequence simultaneously.
      # IAM solves this problem with the {Google::Cloud::Bigtable::Policy#etag}
      # property, which is used to verify whether the policy has changed since
      # the last request. When you make a request with an `etag` value, Cloud
      # IAM compares the `etag` value in the request with the existing `etag`
      # value associated with the policy. It writes the policy only if the
      # `etag` values match.
      #
      # @see https://cloud.google.com/bigtable/docs/access-control Permissions and roles
      #
      # @attr [String] etag Used to check if the policy has changed since
      #   the last request. The policy will be written only if the `etag` values
      #   match.
      # @attr [Hash{String => Array<String>}] roles The bindings that associate
      #   roles with an array of members. See [Understanding
      #   Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
      #   listing of primitive and curated roles.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   instance = bigtable.instance "my-instance"
      #
      #   policy = instance.policy
      #   policy.remove "roles/owner", "user:owner@example.com"
      #   policy.add "roles/owner", "user:newowner@example.com"
      #   policy.roles["roles/viewer"] = ["allUsers"]
      #
      class Policy
        attr_reader :etag
        attr_reader :roles

        # Creates a Policy instance.
        # @param etag [String]
        # @param roles [Array<String>]
        def initialize etag, roles = nil
          @etag = etag
          @roles = roles
        end

        ##
        # Convenience method for adding a member to a binding on this policy.
        # See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # list of primitive and curated roles. See
        # [Binding](https://cloud.google.com/bigtable/docs/access-control)
        # for a list of values and patterns for members.
        #
        # @param [String] role_name A Cloud IAM role, such as
        #   `"roles/bigtable.admin"`.
        # @param [String] member A Cloud IAM identity, such as
        #   `"user:owner@example.com"`.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #
        #   policy = instance.policy
        #   policy.add "roles/owner", "user:newowner@example.com"
        #
        def add role_name, member
          role(role_name) << member
        end

        ##
        # Convenience method for removing a member from a binding on this
        # policy. See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # list of primitive and curated roles.See
        # [Binding](https://cloud.google.com/bigtable/docs/access-control)
        # for a list of values and patterns for members.
        #
        # @param [String] role_name A Cloud IAM role, such as
        #   `"roles/Bigtable.admin"`.
        # @param [String] member A Cloud IAM identity, such as
        #   `"user:owner@example.com"`.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #
        #   policy = instance.policy
        #   policy.remove "roles/owner", "user:newowner@example.com"
        #
        def remove role_name, member
          role(role_name).delete member
        end

        ##
        # Convenience method returning the array of members bound to a role in
        # this policy. Returns an empty array if no value is present for the role in
        # {#roles}. See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # list of primitive and curated roles. See
        # [Binding](https://cloud.google.com/bigtable/docs/access-control)
        # for a list of values and patterns for members.
        #
        # @return [Array<String>] The members strings, or an empty array.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #
        #   policy = instance.policy
        #   policy.role("roles/viewer") << "user:viewer@example.com"
        #
        def role role_name
          roles[role_name] ||= []
        end

        # @private
        # Convert the Policy to a Google::Iam::V1::Policy object.
        def to_grpc
          bindings = roles.keys.map do |role_name|
            next if roles[role_name].empty?
            Google::Iam::V1::Binding.new(
              role:    role_name,
              members: roles[role_name]
            )
          end
          Google::Iam::V1::Policy.new etag: etag, bindings: bindings
        end

        # @private
        # New Policy from a Google::Iam::V1::Policy object.
        def self.from_grpc grpc
          roles = grpc.bindings.each_with_object({}) do |binding, memo|
            memo[binding.role] = binding.members.to_a
          end
          new grpc.etag, roles
        end
      end
    end
  end
end
