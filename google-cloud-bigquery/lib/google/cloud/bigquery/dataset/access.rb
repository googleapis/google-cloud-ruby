# Copyright 2015 Google Inc. All rights reserved.
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
        #     access.add_reader_special :all
        #   end
        #
        class Access
          # @private
          ROLES = { "reader" => "READER",
                    "writer" => "WRITER",
                    "owner"  => "OWNER" }

          # @private
          SCOPES = { "user"           => :user_by_email,
                     "user_by_email"  => :user_by_email,
                     "userByEmail"    => :user_by_email,
                     "group"          => :group_by_email,
                     "group_by_email" => :group_by_email,
                     "groupByEmail"   => :group_by_email,
                     "domain"         => :domain,
                     "special"        => :special_group,
                     "special_group"  => :special_group,
                     "specialGroup"   => :special_group,
                     "view"           => :view }

          # @private
          GROUPS = { "owners"                  => "projectOwners",
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
                     "allAuthenticatedUsers"   => "allAuthenticatedUsers" }

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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_reader_special :all
          #   end
          #
          def add_reader_special group
            add_access_role_scope_value :reader, :special, group
          end

          ##
          # Add reader access to a view.
          #
          # @param [Google::Cloud::Bigquery::Table, String] view A table object
          #   or a string identifier as specified by the [Query
          #   Reference](https://cloud.google.com/bigquery/query-reference#from):
          #   `project_name:datasetId.tableId`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset"
          #
          #   view = other_dataset.table "my_view"
          #
          #   dataset.access do |access|
          #     access.add_reader_view view
          #   end
          #
          def add_reader_view view
            add_access_view view
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_writer_special :all
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.add_owner_special :all
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_reader_special :all
          #   end
          #
          def remove_reader_special group
            remove_access_role_scope_value :reader, :special, group
          end

          ##
          # Remove reader access from a view.
          #
          # @param [Google::Cloud::Bigquery::Table, String] view A table object
          #   or a string identifier as specified by the [Query
          #   Reference](https://cloud.google.com/bigquery/query-reference#from):
          #   `project_name:datasetId.tableId`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset"
          #
          #   view = other_dataset.table "my_view"
          #
          #   dataset.access do |access|
          #     access.remove_reader_view view
          #   end
          #
          def remove_reader_view view
            remove_access_view view
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_writer_special :all
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.access do |access|
          #     access.remove_owner_special :all
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.reader_special? :all #=> false
          #
          def reader_special? group
            lookup_access_role_scope_value :reader, :special, group
          end

          ##
          # Checks reader access for a view.
          #
          # @param [Google::Cloud::Bigquery::Table, String] view A table object
          #   or a string identifier as specified by the [Query
          #   Reference](https://cloud.google.com/bigquery/query-reference#from):
          #   `project_name:datasetId.tableId`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   other_dataset = bigquery.dataset "my_other_dataset"
          #
          #   view = other_dataset.table "my_view"
          #
          #   access = dataset.access
          #   access.reader_view? view #=> false
          #
          def reader_view? view
            lookup_access_view view
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.writer_special? :all #=> false
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
          #   `readers`, and `all`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   access = dataset.access
          #   access.owner_special? :all #=> false
          #
          def owner_special? group
            lookup_access_role_scope_value :owner, :special, group
          end

          # @private
          def self.from_gapi gapi
            rules = Array gapi.access
            new.tap do |s|
              s.instance_variable_set :@rules, rules
              s.instance_variable_set :@original_rules_hashes,
                                      rules.map(&:to_h)
              s.instance_variable_set :@dataset_reference,
                                      gapi.dataset_reference
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
            if good_role.nil?
              fail ArgumentError "Unable to determine role for #{role}"
            end
            good_role
          end

          # @private
          def validate_scope scope
            good_scope = SCOPES[scope.to_s]
            if good_scope.nil?
              fail ArgumentError "Unable to determine scope for #{scope}"
            end
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
              Service.table_ref_from_s view, @dataset_reference
            end
          end

          # @private
          def add_access_role_scope_value role, scope, value
            role = validate_role(role)
            scope = validate_scope scope
            # If scope is special group, make sure value is in the list
            value = validate_special_group(value) if scope == :special_group
            # Remove any rules of this scope and value
            @rules.reject!(&find_by_scope_and_value(scope, value))
            # Add new rule for this role, scope, and value
            opts = { role: role, scope => value }
            @rules << Google::Apis::BigqueryV2::Dataset::Access.new(opts)
          end

          # @private
          def add_access_view value
            # scope is view, make sure value is in the right format
            value = validate_view(value)
            # Remove existing view rule, if any
            @rules.reject!(&find_view(value))
            # Add new rule for this role, scope, and value
            opts = { view: value }
            @rules << Google::Apis::BigqueryV2::Dataset::Access.new(opts)
          end

          # @private
          def remove_access_role_scope_value role, scope, value
            role = validate_role(role)
            scope = validate_scope scope
            # If scope is special group, make sure value is in the list
            value = validate_special_group(value) if scope == :special_group
            # Remove any rules of this role, scope, and value
            @rules.reject!(
              &find_by_role_and_scope_and_value(role, scope, value))
          end

          # @private
          def remove_access_view value
            # scope is view, make sure value is in the right format
            value = validate_view(value)
            # Remove existing view rule, if any
            @rules.reject!(&find_view(value))
          end

          # @private
          def lookup_access_role_scope_value role, scope, value
            role = validate_role(role)
            scope = validate_scope scope
            # If scope is special group, make sure value is in the list
            value = validate_special_group(value) if scope == :special_group
            # Detect any rules of this role, scope, and value
            !(!@rules.detect(
              &find_by_role_and_scope_and_value(role, scope, value)))
          end

          # @private
          def lookup_access_view value
            # scope is view, make sure value is in the right format
            value = validate_view(value)
            # Detect view rule, if any
            !(!@rules.detect(&find_view(value)))
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

          # @private
          def find_view value
            lambda do |a|
              h = a.to_h
              h[:view].to_h == value.to_h
            end
          end
        end
      end
    end
  end
end
