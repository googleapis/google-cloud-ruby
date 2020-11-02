# Copyright 2020 Google LLC
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


require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # Policy
      #
      # Represents a Cloud IAM Policy for BigQuery resources.
      #
      # A common pattern for updating a resource's metadata, such as its policy,
      # is to read the current data from the service, update the data locally,
      # and then write the modified data back to the resource. This pattern may
      # result in a conflict if two or more processes attempt the sequence simultaneously.
      # IAM solves this problem with the {Google::Cloud::Bigquery::Policy#etag}
      # property, which is used to verify whether the policy has changed since
      # the last request. When you make a request with an `etag` value, Cloud
      # IAM compares the `etag` value in the request with the existing `etag`
      # value associated with the policy. It writes the policy only if the
      # `etag` values match.
      #
      # @see https://cloud.google.com/bigquery/docs/table-access-controls-intro Controlling access to tables
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
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   policy = table.policy
      #   policy.role "roles/owner" #=> ["user:owner@example.com"]
      #   policy.frozen? #=> true
      #
      # @example Update the policy by passing a block.
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   table.policy do |p|
      #     p.remove "roles/owner", "user:owner@example.com"
      #     p.add "roles/owner", "user:newowner@example.com"
      #     p.roles["roles/viewer"] = ["allUsers"]
      #   end # 2 API calls
      #
      class Policy
        attr_reader :etag, :roles

        # @private
        def initialize etag, roles = nil
          @etag = etag.freeze
          @roles = roles
        end

        ##
        # Convenience method for adding a member to a binding on this policy.
        # See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # list of primitive and curated roles. See [BigQuery Table ACL
        # permissions](https://cloud.google.com/bigquery/docs/table-access-controls-intro#permissions)
        # for a list of values and patterns for members.
        #
        # @param [String] role_name A Cloud IAM role, such as
        #   `"roles/bigquery.admin"`.
        # @param [String] member A Cloud IAM identity, such as
        #   `"user:owner@example.com"`.
        #
        # @example Update the policy by passing a block.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.policy do |p|
        #     p.remove "roles/owner", "user:owner@example.com"
        #     p.add "roles/owner", "user:newowner@example.com"
        #     p.roles["roles/viewer"] = ["allUsers"]
        #   end # 2 API calls
        #
        def add role_name, member
          role(role_name) << member
        end

        ##
        # Convenience method for removing a member from a binding on this
        # policy. See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # list of primitive and curated roles. See [BigQuery Table ACL
        # permissions](https://cloud.google.com/bigquery/docs/table-access-controls-intro#permissions)
        # for a list of values and patterns for members.
        #
        # @param [String] role_name A Cloud IAM role, such as
        #   `"roles/Bigquery.admin"`.
        # @param [String] member A Cloud IAM identity, such as
        #   `"user:owner@example.com"`.
        #
        # @example Update the policy by passing a block.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.policy do |p|
        #     p.remove "roles/owner", "user:owner@example.com"
        #     p.add "roles/owner", "user:newowner@example.com"
        #     p.roles["roles/viewer"] = ["allUsers"]
        #   end # 2 API calls
        #
        def remove role_name, member
          role(role_name).delete member
        end

        ##
        # Convenience method returning the array of members bound to a role in
        # this policy. Returns an empty array if no value is present for the role in
        # {#roles}. See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a
        # list of primitive and curated roles. See [BigQuery Table ACL
        # permissions](https://cloud.google.com/bigquery/docs/table-access-controls-intro#permissions)
        # for a list of values and patterns for members.
        #
        # @return [Array<String>] The members strings, or an empty array.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   policy = table.policy
        #   policy.role "roles/owner" #=> ["user:owner@example.com"]
        #   policy.frozen? #=> true
        #
        def role role_name
          roles[role_name] ||= []
        end

        ##
        # @private Convert the Policy to a Google::Apis::BigqueryV2::Policy.
        def to_gapi
          Google::Apis::BigqueryV2::Policy.new(
            etag:     etag,
            bindings: roles_to_gapi
          )
        end

        ##
        # @private Freeze the policy including its roles hash.
        def freeze
          super
          roles.freeze
          self
        end

        ##
        # @private New Policy from a Google::Apis::BigqueryV2::Policy object.
        def self.from_gapi gapi
          roles = Array(gapi.bindings).each_with_object({}) do |binding, memo|
            memo[binding.role] = binding.members.to_a
          end
          new gapi.etag, roles
        end

        protected

        def roles_to_gapi
          roles.keys.map do |role_name|
            next if roles[role_name].empty?
            Google::Apis::BigqueryV2::Binding.new(
              role:    role_name,
              members: roles[role_name].uniq
            )
          end
        end
      end
    end
  end
end
