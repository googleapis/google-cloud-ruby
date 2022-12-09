# Copyright 2015 Google LLC
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
    module Bigquery
      class Dataset
        ##
        # # Dataset Access Control
        #
        # Represents the access control rules for a {Dataset}.
        #
        # @see https://cloud.google.com/bigquery/docs/access-control BigQuery
        #   Access Control
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.access do |access|
        #     access.add_owner_group "owners@example.com"
        #     access.add_writer_user "writer@example.com"
        #     access.remove_writer_user "readers@example.com"
        #     access.add_reader_special :all_users
        #   end
        #
        class Access
          # @private
          ROLES = {
            "reader" => "READER",
            "writer" => "WRITER",
            "owner"  => "OWNER"
          }.freeze

          # @private
          SCOPES = {
            "domain"         => :domain,
            "group"          => :group_by_email,
            "group_by_email" => :group_by_email,
            "groupByEmail"   => :group_by_email,
            "iam_member"     => :iam_member,
            "iamMember"      => :iam_member,
            "routine"        => :routine,
            "special"        => :special_group,
            "special_group"  => :special_group,
            "specialGroup"   => :special_group,
            "user"           => :user_by_email,
            "user_by_email"  => :user_by_email,
            "userByEmail"    => :user_by_email,
            "view"           => :view,
            "dataset"        => :dataset
          }.freeze
          attr_reader :rules

          # @private
          GROUPS = {
            "owners"                  => "projectOwners",
            "project_owners"          => "projectOwners",
            "projectOwners"           => "projectOwners",
            "readers"                 => "projectReaders",
            "project_readers"         => "projectReaders",
            "projectReaders"          => "projectReaders",
            "writers"                 => "projectWriters",
            "project_writers"         => "projectWriters",
            "projectWriters"          => "projectWriters",
            "all"                     => "allAuthenticatedUsers",
            "all_authenticated_users" => "allAuthenticatedUsers",
            "allAuthenticatedUsers"   => "allAuthenticatedUsers",
            "all_users"               => "allUsers",
            "allUsers"                => "allUsers"
          }.freeze

          ##
          # @private
          # Initialized a new Access object.
          # Must provide a valid Google::Apis::BigqueryV2::Dataset object.
          # Access will mutate the gapi object.
          def initialize
            @rules = [] # easiest to do this in the constructor
            @original_rules_hashes = @rules.map(&:to_h)
          end

          # @private
          def changed?
            @original_rules_hashes != @rules.map(&:to_h)
          end

          # @private
          def empty?
            @rules.empty?
          end

          # @private
          def freeze
            @rules = @rules.map(&:dup).map(&:freeze)
            @rules.freeze
            super
          end

          ##
          # @private View the access rules as an array of hashes.
          def to_a
            @rules.map(&:to_h)
          end

          ##
          # Add reader access to a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_reader_user "entity@example.com"
          #   end
          #
          def add_reader_user email
            add_access_role_scope_value :reader, :user, email
          end

          ##
          # Add reader access to a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_reader_group "entity@example.com"
          #   end
          #
          def add_reader_group email
            add_access_role_scope_value :reader, :group, email
          end

          ##
          # Add reader access to some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_reader_iam_member "entity@example.com"
          #   end
          #
          def add_reader_iam_member identity
            add_access_role_scope_value :reader, :iam_member, identity
          end

          ##
          # Add reader access to a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_reader_domain "example.com"
          #   end
          #
          def add_reader_domain domain
            add_access_role_scope_value :reader, :domain, domain
          end

          ##
          # Add reader access to a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_reader_special :all_users
          #   end
          #
          def add_reader_special group
            add_access_role_scope_value :reader, :special, group
          end

          ##
          # Add access to a routine from a different dataset. Queries executed
          # against that routine will have read access to views/tables/routines
          # in this dataset. Only UDF is supported for now. The role field is
          # not required when this field is set. If that routine is updated by
          # any user, access to the routine needs to be granted again via an
          # update operation.
          #
          # @param [Google::Cloud::Bigquery::Routine] routine A routine object.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   routine = other_dataset.routine "my_routine"
          #
          #   dataset.access do |access|
          #     access.add_reader_routine routine
          #   end
          #
          def add_reader_routine routine
            add_access_routine routine
          end

          ##
          # Add reader access to a view.
          #
          # @param [Google::Cloud::Bigquery::Table, String] view A table object,
          #   or a string identifier as specified by the [Standard SQL Query
          #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
          #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
          #   Reference](https://cloud.google.com/bigquery/query-reference#from)
          #   (`project-name:dataset_id.table_id`).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   view = other_dataset.table "my_view", skip_lookup: true
          #
          #   dataset.access do |access|
          #     access.add_reader_view view
          #   end
          #
          def add_reader_view view
            add_access_view view
          end

          ##
          # Add reader access to a dataset.
          #
          # @param [Google::Cloud::Bigquery::DatasetAccessEntry, Hash<String,String> ] dataset A DatasetAccessEntry
          #   or a Hash object. Required
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   params = {
          #     dataset_id: other_dataset.dataset_id,
          #     project_id: other_dataset.project_id,
          #     target_types: ["VIEWS"]
          #   }
          #
          #   dataset.access do |access|
          #     access.add_reader_dataset params
          #   end
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   dataset.access do |access|
          #     access.add_reader_dataset other_dataset.access_entry(target_types: ["VIEWS"])
          #   end
          #
          def add_reader_dataset dataset
            add_access_dataset dataset
          end

          ##
          # Add writer access to a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_writer_user "entity@example.com"
          #   end
          #
          def add_writer_user email
            add_access_role_scope_value :writer, :user, email
          end

          ##
          # Add writer access to a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_writer_group "entity@example.com"
          #   end
          #
          def add_writer_group email
            add_access_role_scope_value :writer, :group, email
          end

          ##
          # Add writer access to some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_writer_iam_member "entity@example.com"
          #   end
          #
          def add_writer_iam_member identity
            add_access_role_scope_value :writer, :iam_member, identity
          end

          ##
          # Add writer access to a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_writer_domain "example.com"
          #   end
          #
          def add_writer_domain domain
            add_access_role_scope_value :writer, :domain, domain
          end

          ##
          # Add writer access to a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_writer_special :all_users
          #   end
          #
          def add_writer_special group
            add_access_role_scope_value :writer, :special, group
          end

          ##
          # Add owner access to a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_owner_user "entity@example.com"
          #   end
          #
          def add_owner_user email
            add_access_role_scope_value :owner, :user, email
          end

          ##
          # Add owner access to a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_owner_group "entity@example.com"
          #   end
          #
          def add_owner_group email
            add_access_role_scope_value :owner, :group, email
          end

          ##
          # Add owner access to some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_owner_iam_member "entity@example.com"
          #   end
          #
          def add_owner_iam_member identity
            add_access_role_scope_value :owner, :iam_member, identity
          end

          ##
          # Add owner access to a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_owner_domain "example.com"
          #   end
          #
          def add_owner_domain domain
            add_access_role_scope_value :owner, :domain, domain
          end

          ##
          # Add owner access to a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_owner_special :all_users
          #   end
          #
          def add_owner_special group
            add_access_role_scope_value :owner, :special, group
          end

          ##
          # Remove reader access from a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_reader_user "entity@example.com"
          #   end
          #
          def remove_reader_user email
            remove_access_role_scope_value :reader, :user, email
          end

          ##
          # Remove reader access from a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_reader_group "entity@example.com"
          #   end
          #
          def remove_reader_group email
            remove_access_role_scope_value :reader, :group, email
          end

          ##
          # Remove reader access from some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_reader_iam_member "entity@example.com"
          #   end
          #
          def remove_reader_iam_member identity
            remove_access_role_scope_value :reader, :iam_member, identity
          end

          ##
          # Remove reader access from a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_reader_domain "example.com"
          #   end
          #
          def remove_reader_domain domain
            remove_access_role_scope_value :reader, :domain, domain
          end

          ##
          # Remove reader access from a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_reader_special :all_users
          #   end
          #
          def remove_reader_special group
            remove_access_role_scope_value :reader, :special, group
          end

          ##
          # Remove reader access from a routine from a different dataset.
          #
          # @param [Google::Cloud::Bigquery::Routine] routine A routine object.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   routine = other_dataset.routine "my_routine", skip_lookup: true
          #
          #   dataset.access do |access|
          #     access.remove_reader_routine routine
          #   end
          #
          def remove_reader_routine routine
            remove_access_routine routine
          end

          ##
          # Remove reader access from a view.
          #
          # @param [Google::Cloud::Bigquery::Table, String] view A table object,
          #   or a string identifier as specified by the [Standard SQL Query
          #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
          #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
          #   Reference](https://cloud.google.com/bigquery/query-reference#from)
          #   (`project-name:dataset_id.table_id`).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   view = other_dataset.table "my_view", skip_lookup: true
          #
          #   dataset.access do |access|
          #     access.remove_reader_view view
          #   end
          #
          def remove_reader_view view
            remove_access_view view
          end

          ##
          # Removes reader access of a dataset.
          #
          # @param [Google::Cloud::Bigquery::DatasetAccessEntry, Hash<String,String> ] dataset A DatasetAccessEntry
          #   or a Hash object. Required
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   params = {
          #     dataset_id: other_dataset.dataset_id,
          #     project_id: other_dataset.project_id,
          #     target_types: ["VIEWS"]
          #   }
          #
          #   dataset.access do |access|
          #     access.remove_reader_dataset params
          #   end
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   dataset.access do |access|
          #     access.remove_reader_dataset other_dataset.access_entry(target_types: ["VIEWS"])
          #   end
          #
          def remove_reader_dataset dataset
            remove_access_dataset dataset
          end

          ##
          # Remove writer access from a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_writer_user "entity@example.com"
          #   end
          #
          def remove_writer_user email
            remove_access_role_scope_value :writer, :user, email
          end

          ##
          # Remove writer access from a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_writer_group "entity@example.com"
          #   end
          #
          def remove_writer_group email
            remove_access_role_scope_value :writer, :group, email
          end

          ##
          # Remove writer access from some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_writer_iam_member "entity@example.com"
          #   end
          #
          def remove_writer_iam_member identity
            remove_access_role_scope_value :writer, :iam_member, identity
          end

          ##
          # Remove writer access from a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_writer_domain "example.com"
          #   end
          #
          def remove_writer_domain domain
            remove_access_role_scope_value :writer, :domain, domain
          end

          ##
          # Remove writer access from a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_writer_special :all_users
          #   end
          #
          def remove_writer_special group
            remove_access_role_scope_value :writer, :special, group
          end

          ##
          # Remove owner access from a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_owner_user "entity@example.com"
          #   end
          #
          def remove_owner_user email
            remove_access_role_scope_value :owner, :user, email
          end

          ##
          # Remove owner access from a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_owner_group "entity@example.com"
          #   end
          #
          def remove_owner_group email
            remove_access_role_scope_value :owner, :group, email
          end

          ##
          # Remove owner access from some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_owner_iam_member "entity@example.com"
          #   end
          #
          def remove_owner_iam_member identity
            remove_access_role_scope_value :owner, :iam_member, identity
          end

          ##
          # Remove owner access from a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_owner_domain "example.com"
          #   end
          #
          def remove_owner_domain domain
            remove_access_role_scope_value :owner, :domain, domain
          end

          ##
          # Remove owner access from a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_owner_special :all_users
          #   end
          #
          def remove_owner_special group
            remove_access_role_scope_value :owner, :special, group
          end

          ##
          # Checks reader access for a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.reader_user? "entity@example.com" #=> false
          #
          def reader_user? email
            lookup_access_role_scope_value :reader, :user, email
          end

          ##
          # Checks reader access for a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.reader_group? "entity@example.com" #=> false
          #
          def reader_group? email
            lookup_access_role_scope_value :reader, :group, email
          end

          ##
          # Checks reader access for some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.reader_iam_member? "entity@example.com" #=> false
          #
          def reader_iam_member? identity
            lookup_access_role_scope_value :reader, :iam_member, identity
          end

          ##
          # Checks reader access for a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.reader_domain? "example.com" #=> false
          #
          def reader_domain? domain
            lookup_access_role_scope_value :reader, :domain, domain
          end

          ##
          # Checks reader access for a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.reader_special? :all_users #=> false
          #
          def reader_special? group
            lookup_access_role_scope_value :reader, :special, group
          end

          ##
          # Checks access for a routine from a different dataset. Queries executed
          # against that routine will have read access to views/tables/routines
          # in this dataset. Only UDF is supported for now. The role field is
          # not required when this field is set. If that routine is updated by
          # any user, access to the routine needs to be granted again via an
          # update operation.
          #
          # @param [Google::Cloud::Bigquery::Routine] routine A routine object.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   routine = other_dataset.routine "my_routine", skip_lookup: true
          #
          #   access = dataset.access
          #   access.reader_routine? routine #=> false
          #
          def reader_routine? routine
            lookup_access_routine routine
          end

          ##
          # Checks reader access for a view.
          #
          # @param [Google::Cloud::Bigquery::Table, String] view A table object,
          #   or a string identifier as specified by the [Standard SQL Query
          #   Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#from-clause)
          #   (`project-name.dataset_id.table_id`) or the [Legacy SQL Query
          #   Reference](https://cloud.google.com/bigquery/query-reference#from)
          #   (`project-name:dataset_id.table_id`).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   view = other_dataset.table "my_view", skip_lookup: true
          #
          #   access = dataset.access
          #   access.reader_view? view #=> false
          #
          def reader_view? view
            lookup_access_view view
          end

          ##
          # Checks reader access for a dataset.
          #
          # @param [Google::Cloud::Bigquery::DatasetAccessEntry, Hash<String,String> ] dataset A DatasetAccessEntry
          #   or a Hash object. Required
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   params = {
          #     dataset_id: other_dataset.dataset_id,
          #     project_id: other_dataset.project_id,
          #     target_types: ["VIEWS"]
          #   }
          #
          #   dataset.access.reader_dataset? params
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset", skip_lookup: true
          #
          #   dataset.access.reader_dataset? other_dataset.access_entry(target_types: ["VIEWS"])
          #
          def reader_dataset? dataset
            lookup_access_dataset dataset
          end

          ##
          # Checks writer access for a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.writer_user? "entity@example.com" #=> false
          #
          def writer_user? email
            lookup_access_role_scope_value :writer, :user, email
          end

          ##
          # Checks writer access for a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.writer_group? "entity@example.com" #=> false
          #
          def writer_group? email
            lookup_access_role_scope_value :writer, :group, email
          end

          ##
          # Checks writer access for some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.writer_iam_member? "entity@example.com" #=> false
          #
          def writer_iam_member? identity
            lookup_access_role_scope_value :writer, :iam_member, identity
          end

          ##
          # Checks writer access for a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.writer_domain? "example.com" #=> false
          #
          def writer_domain? domain
            lookup_access_role_scope_value :writer, :domain, domain
          end

          ##
          # Checks writer access for a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.writer_special? :all_users #=> false
          #
          def writer_special? group
            lookup_access_role_scope_value :writer, :special, group
          end

          ##
          # Checks owner access for a user.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.owner_user? "entity@example.com" #=> false
          #
          def owner_user? email
            lookup_access_role_scope_value :owner, :user, email
          end

          ##
          # Checks owner access for a group.
          #
          # @param [String] email The email address for the entity.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.owner_group? "entity@example.com" #=> false
          #
          def owner_group? email
            lookup_access_role_scope_value :owner, :group, email
          end

          ##
          # Checks owner access for some other type of member that appears in the IAM
          # Policy but isn't a user, group, domain, or special group.
          #
          # @param [String] identity The identity reference.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.owner_iam_member? "entity@example.com" #=> false
          #
          def owner_iam_member? identity
            lookup_access_role_scope_value :owner, :iam_member, identity
          end

          ##
          # Checks owner access for a domain.
          #
          # @param [String] domain A [Cloud Identity
          #   domain](https://cloud.google.com/iam/docs/overview#cloudid_name_domain).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.owner_domain? "example.com" #=> false
          #
          def owner_domain? domain
            lookup_access_role_scope_value :owner, :domain, domain
          end

          ##
          # Checks owner access for a special group.
          #
          # @param [String] group Accepted values are `owners`, `writers`,
          #   `readers`, `all_authenticated_users`, and `all_users`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.owner_special? :all_users #=> false
          #
          def owner_special? group
            lookup_access_role_scope_value :owner, :special, group
          end

          # @private
          def self.from_gapi gapi
            rules = Array gapi.access
            new.tap do |s|
              s.instance_variable_set :@rules, rules
              s.instance_variable_set :@original_rules_hashes, rules.map(&:to_h)
              s.instance_variable_set :@dataset_reference, gapi.dataset_reference
            end
          end

          # @private
          def to_gapi
            @rules
          end

          protected

          # @private
          def validate_role role
            good_role = ROLES[role.to_s]
            raise ArgumentError "Unable to determine role for #{role}" if good_role.nil?
            good_role
          end

          # @private
          def validate_scope scope
            good_scope = SCOPES[scope.to_s]
            raise ArgumentError "Unable to determine scope for #{scope}" if good_scope.nil?
            good_scope
          end

          # @private
          def validate_special_group value
            good_value = GROUPS[value.to_s]
            return good_value unless good_value.nil?
            value
          end

          # @private
          def validate_view view
            if view.respond_to? :table_ref
              view.table_ref
            else
              Service.table_ref_from_s view, default_ref: @dataset_reference
            end
          end

          # @private
          #
          # Checks the type of user input and converts it to acceptable format.
          #
          def validate_dataset dataset
            if dataset.is_a? Google::Apis::BigqueryV2::DatasetAccessEntry
              dataset
            else
              Service.dataset_access_entry_from_hash dataset
            end
          end

          # @private
          def add_access_role_scope_value role, scope, value
            role = validate_role role
            scope = validate_scope scope
            # If scope is special group, make sure value is in the list
            value = validate_special_group value if scope == :special_group
            # Remove any rules of this scope and value
            @rules.reject!(&find_by_scope_and_value(scope, value))
            # Add new rule for this role, scope, and value
            opts = { role: role, scope => value }
            @rules << Google::Apis::BigqueryV2::Dataset::Access.new(**opts)
          end

          # @private
          def add_access_routine routine
            value = routine.routine_ref
            # Remove existing routine rule, if any
            @rules.reject!(&find_by_scope_and_resource_ref(:routine, value))
            # Add new rule for this role, scope, and value
            opts = { routine: value }
            @rules << Google::Apis::BigqueryV2::Dataset::Access.new(**opts)
          end

          # @private
          def add_access_view value
            # scope is view, make sure value is in the right format
            value = validate_view value
            # Remove existing view rule, if any
            @rules.reject!(&find_by_scope_and_resource_ref(:view, value))
            # Add new rule for this role, scope, and value
            opts = { view: value }
            @rules << Google::Apis::BigqueryV2::Dataset::Access.new(**opts)
          end

          # @private
          def add_access_dataset dataset
            # scope is dataset, make sure value is in the right format
            value = validate_dataset dataset
            # Remove existing rule for input dataset, if any
            @rules.reject!(&find_by_scope_and_resource_ref(:dataset, value))
            # Add new rule for this role, scope, and value
            opts = { dataset: value }
            @rules << Google::Apis::BigqueryV2::Dataset::Access.new(**opts)
          end

          # @private
          def remove_access_role_scope_value role, scope, value
            role = validate_role role
            scope = validate_scope scope
            # If scope is special group, make sure value is in the list
            value = validate_special_group value if scope == :special_group
            # Remove any rules of this role, scope, and value
            @rules.reject!(
              &find_by_role_and_scope_and_value(role, scope, value)
            )
          end

          # @private
          def remove_access_routine routine
            # Remove existing routine rule, if any
            @rules.reject!(&find_by_scope_and_resource_ref(:routine, routine.routine_ref))
          end

          # @private
          def remove_access_view value
            # scope is view, make sure value is in the right format
            value = validate_view value
            # Remove existing view rule, if any
            @rules.reject!(&find_by_scope_and_resource_ref(:view, value))
          end

          # @private
          def remove_access_dataset dataset
            # scope is dataset, make sure value is in the right format
            value = validate_dataset dataset
            # Remove existing rule for input dataset, if any
            @rules.reject!(&find_by_scope_and_resource_ref(:dataset, value))
          end

          # @private
          def lookup_access_role_scope_value role, scope, value
            role = validate_role role
            scope = validate_scope scope
            # If scope is special group, make sure value is in the list
            value = validate_special_group value if scope == :special_group
            # Detect any rules of this role, scope, and value
            !(!@rules.detect(&find_by_role_and_scope_and_value(role, scope, value)))
          end

          # @private
          def lookup_access_routine routine
            # Detect routine rule, if any
            !(!@rules.detect(&find_by_scope_and_resource_ref(:routine, routine.routine_ref)))
          end

          # @private
          def lookup_access_view value
            # scope is view, make sure value is in the right format
            value = validate_view value
            # Detect view rule, if any
            !(!@rules.detect(&find_by_scope_and_resource_ref(:view, value)))
          end

          # @private
          def lookup_access_dataset dataset
            # scope is dataset, make sure value is in the right format
            value = validate_dataset dataset
            # Detect existing rule for input dataset, if any
            !(!@rules.detect(&find_by_scope_and_resource_ref(:dataset, value)))
          end

          # @private
          def find_by_role_and_scope_and_value role, scope, value
            lambda do |a|
              h = a.to_h
              h[:role] == role && h[scope] == value
            end
          end

          # @private
          def find_by_scope_and_value scope, value
            lambda do |a|
              h = a.to_h
              h[scope] == value
            end
          end

          # @private Compare hash representations to find table_ref, routine_ref.
          def find_by_scope_and_resource_ref scope, value
            lambda do |a|
              h = a.to_h
              h[scope].to_h == value.to_h
            end
          end
        end
      end
    end
  end
end
