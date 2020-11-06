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
      # A Policy is a collection of bindings. A {Policy::Binding} binds one or more members to a single role. Member
      # strings can describe user accounts, service accounts, Google groups, and domains. A role string represents a
      # named list of permissions; each role can be an IAM predefined role or a user-created custom role.
      #
      # @see https://cloud.google.com/iam/docs/managing-policies Managing Policies
      # @see https://cloud.google.com/bigquery/docs/table-access-controls-intro Controlling access to tables
      #
      # @attr [String] etag Used to check if the policy has changed since the last request. When you make a request with
      #   an `etag` value, Cloud IAM compares the `etag` value in the request with the existing `etag` value associated
      #   with the policy. It writes the policy only if the `etag` values match.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #   policy = table.policy
      #
      #   policy.frozen? #=> true
      #   binding = policy.binding_for "roles/owner"
      #
      #   binding.role #=> "roles/owner"
      #   binding.members #=> ["user:owner@example.com"]
      #   binding.frozen? #=> true
      #   binding.members.frozen? #=> true
      #
      # @example Update mutable bindings in the policy with {Table#update_policy}.
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   table.update_policy do |p|
      #     p.set_binding "roles/viewer", "user:viewer@example.com"
      #     p.binding_for("roles/editor").members << "user:new-editor@example.com"
      #     p.binding_for("roles/editor").members.delete "user:old-editor@example.com"
      #     p.remove_binding "roles/owner"
      #   end # 2 API calls
      #
      class Policy
        attr_reader :etag

        # @private
        def initialize etag, bindings
          @etag = etag.freeze
          @bindings = bindings
        end

        ##
        # Convenience method returning a binding value object that contains the array of members bound to a role
        # in the policy. Returns `nil` if no binding is present for the role in the policy. See
        # [Understanding Roles](https://cloud.google.com/iam/docs/understanding-roles) for a list of primitive and
        # curated roles. See [BigQuery Table ACL
        # permissions](https://cloud.google.com/bigquery/docs/table-access-controls-intro#permissions) for a list of
        # values and patterns for members.
        #
        # @param [String] role A role that is bound to members in the policy. For example, `roles/viewer`,
        #   `roles/editor`, or `roles/owner`. Required.
        #
        # @return [Binding, nil] The binding object, which may be mutable or frozen depending on the context; or `nil`
        #   if no binding exists for the given role.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #   policy = table.policy
        #
        #   policy.frozen? #=> true
        #   binding = policy.binding_for "roles/owner"
        #
        #   binding.role #=> "roles/owner"
        #   binding.members #=> ["user:owner@example.com"]
        #   binding.frozen? #=> true
        #   binding.members.frozen? #=> true
        #
        # @example Update mutable bindings in the policy with {Table#update_policy}.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.update_policy do |p|
        #     p.binding_for("roles/editor").members << "user:new-editor@example.com"
        #     p.binding_for("roles/editor").members.delete "user:old-editor@example.com"
        #   end # 2 API calls
        #
        def binding_for role
          @bindings[role]
        end

        ##
        # The bindings in the policy, which may be mutable or frozen depending on the context. See
        # [Understanding Roles](https://cloud.google.com/iam/docs/understanding-roles) for a list of primitive and
        # curated roles. See [BigQuery Table ACL
        # permissions](https://cloud.google.com/bigquery/docs/table-access-controls-intro#permissions) for a list of
        # values and patterns for members.
        #
        # @return [Array<Binding>] The array of binding objects, which may be mutable or frozen depending on the
        #   context.
        #
        # @example Iterate over frozen bindings.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #   policy = table.policy
        #
        #   policy.frozen? #=> true
        #   policy.bindings.each do |binding|
        #     puts binding.role
        #     puts binding.members
        #   end
        #
        # @example Update mutable bindings with {Table#update_policy}.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.update_policy do |p|
        #     p.bindings.each do |binding|
        #       binding.members.clear
        #     end
        #   end # 2 API calls
        #
        def bindings
          frozen? ? @bindings.values.freeze : @bindings.values
        end

        ##
        # Convenience method adding or replacing a binding in the policy. See [Understanding
        # Roles](https://cloud.google.com/iam/docs/understanding-roles) for a list of primitive and curated roles. See
        # [BigQuery Table ACL
        # permissions](https://cloud.google.com/bigquery/docs/table-access-controls-intro#permissions) for a list of
        # values and patterns for members.
        #
        # @param [String] role The role that is bound to members in the binding. For example, `roles/viewer`,
        #   `roles/editor`, or `roles/owner`. Required.
        # @param [String, Array<String>] members Specifies the identities requesting access for a Cloud Platform
        #   resource. `members` can have the following values. Required.
        #
        #   * `allUsers`: A special identifier that represents anyone who is on the internet; with or without a Google
        #     account.
        #   * `allAuthenticatedUsers`: A special identifier that represents anyone who is authenticated with a Google
        #     account or a service account.
        #   * `user:<emailid>`: An email address that represents a specific Google account. For example,
        #     `alice@example.com`.
        #   * `serviceAccount:<emailid>`: An email address that represents a service account. For example,
        #     `my-other-app@appspot.gserviceaccount.com`.
        #   * `group:<emailid>`: An email address that represents a Google group. For example, `admins@example.com`.
        #   * `deleted:user:<emailid>?uid=<uniqueid>`: An email address (plus unique identifier) representing a user
        #     that has been recently deleted. For example, `alice@example.com?uid=123456789012345678901`. If the user
        #     is recovered, this value reverts to `user:<emailid>` and the recovered user retains the role in the
        #     binding.
        #   * `deleted: serviceAccount:<emailid>?uid=<uniqueid>`: An email address (plus unique identifier) representing
        #     a service account that has been recently deleted. For example,
        #     `my-other-app@appspot.gserviceaccount.com?uid=123456789012345678901`. If the service account is undeleted,
        #     this value reverts to `serviceAccount:<emailid>` and the undeleted service account retains the role in
        #     the binding.
        #   * `deleted:group:<emailid>?uid=<uniqueid>`: An email address (plus unique identifier) representing a Google
        #     group that has been recently deleted. For example, `admins@example.com?uid=123456789012345678901`. If the
        #     group is recovered, this value reverts to `group:<emailid>` and the recovered group retains the role in
        #     the binding.
        #   * `domain:<domain>`: The G Suite domain (primary) that represents all the users of that domain. For example,
        #     `google.com` or `example.com`.
        #
        # @return [Binding, nil] The binding object that was added to the policy. This object is mutable and may be used
        #   to add or remove members within the context of a block passed to {Table.update_policy}.
        #
        # @example Update a mutable policy with {Table#update_policy}.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.update_policy do |p|
        #     p.set_binding "roles/viewer", "user:viewer@example.com"
        #   end # 2 API calls
        #
        def set_binding role, members
          new_binding = Binding.new role, members
          @bindings[role] = new_binding
          new_binding
        end

        ##
        # Convenience method deleting a binding in the policy. Returns `nil` if no binding is present for the role. See
        # [Understanding Roles](https://cloud.google.com/iam/docs/understanding-roles) for a list of primitive and
        # curated roles. See [BigQuery Table ACL
        # permissions](https://cloud.google.com/bigquery/docs/table-access-controls-intro#permissions) for a list of
        # values and patterns for members.
        #
        # @param [String] role A role that is bound to members in the policy. For example, `roles/viewer`,
        #   `roles/editor`, or `roles/owner`. Required.
        #
        # @return [Binding, nil] The frozen binding object, or `nil` if no binding exists for the given role.
        #
        # @example Update a mutable policy with {Table#update_policy}.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.update_policy do |p|
        #     p.remove_binding "roles/owner"
        #   end # 2 API calls
        #
        def remove_binding role
          @bindings.delete(role).freeze
        end

        ##
        # @private Convert the Policy to a Google::Apis::BigqueryV2::Policy.
        def to_gapi
          Google::Apis::BigqueryV2::Policy.new(
            bindings: bindings_to_gapi,
            etag:     etag,
            version:  1
          )
        end

        ##
        # @private Deep freeze the policy including its bindings.
        def freeze
          super
          @bindings.values.each(&:freeze)
          @bindings.freeze
          self
        end

        ##
        # @private New Policy from a Google::Apis::BigqueryV2::Policy object.
        def self.from_gapi gapi
          bindings_hash = Array(gapi.bindings).each_with_object({}) do |binding, memo|
            memo[binding.role] = Binding.new binding.role, binding.members.to_a
          end
          new gapi.etag, bindings_hash
        end

        ##
        # # Policy::Binding
        #
        # Represents a Cloud IAM Binding for BigQuery resources within the context of a {Policy}.
        #
        # A binding binds one or more members to a single role. Member strings can describe user accounts, service
        # accounts, Google groups, and domains. A role is a named list of permissions; each role can be an IAM
        # predefined role or a user-created custom role.
        #
        # @see https://cloud.google.com/bigquery/docs/table-access-controls-intro Controlling access to tables
        #
        # @attr [String] role The role that is assigned to `members`. For example, `roles/viewer`, `roles/editor`, or
        #   `roles/owner`.
        # @attr [Array<String>] members Specifies the identities requesting access for a Cloud Platform resource.
        #   `members` can have the following values. Required.
        #
        #   * `allUsers`: A special identifier that represents anyone who is on the internet; with or without a Google
        #     account.
        #   * `allAuthenticatedUsers`: A special identifier that represents anyone who is authenticated with a Google
        #     account or a service account.
        #   * `user:<emailid>`: An email address that represents a specific Google account. For example,
        #     `alice@example.com`.
        #   * `serviceAccount:<emailid>`: An email address that represents a service account. For example,
        #     `my-other-app@appspot.gserviceaccount.com`.
        #   * `group:<emailid>`: An email address that represents a Google group. For example, `admins@example.com`.
        #   * `deleted:user:<emailid>?uid=<uniqueid>`: An email address (plus unique identifier) representing a user
        #     that has been recently deleted. For example, `alice@example.com?uid=123456789012345678901`. If the user
        #     is recovered, this value reverts to `user:<emailid>` and the recovered user retains the role in the
        #     binding.
        #   * `deleted: serviceAccount:<emailid>?uid=<uniqueid>`: An email address (plus unique identifier) representing
        #     a service account that has been recently deleted. For example,
        #     `my-other-app@appspot.gserviceaccount.com?uid=123456789012345678901`. If the service account is undeleted,
        #     this value reverts to `serviceAccount:<emailid>` and the undeleted service account retains the role in
        #     the binding.
        #   * `deleted:group:<emailid>?uid=<uniqueid>`: An email address (plus unique identifier) representing a Google
        #     group that has been recently deleted. For example, `admins@example.com?uid=123456789012345678901`. If the
        #     group is recovered, this value reverts to `group:<emailid>` and the recovered group retains the role in
        #     the binding.
        #   * `domain:<domain>`: The G Suite domain (primary) that represents all the users of that domain. For example,
        #     `google.com` or `example.com`.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   policy = table.policy
        #   binding = policy.binding_for "roles/owner"
        #
        #   binding.role #=> "roles/owner"
        #   binding.members #=> ["user:owner@example.com"]
        #
        #   binding.frozen? #=> true
        #   binding.members.frozen? #=> true
        #
        # @example Update mutable bindings with {Table#update_policy}.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.update_policy do |p|
        #     p.binding_for("roles/editor").members << "user:new-editor@example.com"
        #     p.binding_for("roles/editor").members.delete "user:old-editor@example.com"
        #   end # 2 API calls
        #
        class Binding
          attr_reader :role
          attr_accessor :members

          # @private
          def initialize role, members
            members = Array members
            raise ArgumentError, "members cannot be empty" if members.empty?
            @role = role
            @members = members
          end

          ##
          # @private Convert the Binding to a Google::Apis::BigqueryV2::Binding.
          def to_gapi
            Google::Apis::BigqueryV2::Binding.new role: role, members: members
          end

          ##
          # @private Deep freeze the policy including its members.
          def freeze
            super
            role.freeze
            members.each(&:freeze)
            members.freeze
            self
          end

          ##
          # @private New Binding from a Google::Apis::BigqueryV2::Binding object.
          def self.from_gapi gapi
            new gapi.etag, gapi.members.to_a
          end
        end

        protected

        def bindings_to_gapi
          @bindings.values.compact.uniq.map do |b|
            next if b.members.empty?
            b.to_gapi
          end
        end
      end
    end
  end
end
