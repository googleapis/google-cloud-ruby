#--
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

module Gcloud
  module Bigquery
    class Dataset
      ##
      # = Dataset Access Control
      #
      # Represents the Access rules for a {Dataset}.
      #
      # @see https://cloud.google.com/bigquery/access-control BigQuery Access
      #   Control
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   dataset.access do |access|
      #     access.add_owner_group "owners@example.com"
      #     access.add_writer_user "writer@example.com"
      #     access.remove_writer_user "readers@example.com"
      #     access.add_reader_special :all
      #     access.add_reader_view other_dataset_view_object
      #   end
      #
      class Access
        # @private
        ROLES = { "reader" => "READER",
                  "writer" => "WRITER",
                  "owner"  => "OWNER" }

        # @private
        SCOPES = { "user"           => "userByEmail",
                   "user_by_email"  => "userByEmail",
                   "userByEmail"    => "userByEmail",
                   "group"          => "groupByEmail",
                   "group_by_email" => "groupByEmail",
                   "groupByEmail"   => "groupByEmail",
                   "domain"         => "domain",
                   "special"        => "specialGroup",
                   "special_group"  => "specialGroup",
                   "specialGroup"   => "specialGroup",
                   "view"           => "view" }

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

        # @private
        attr_reader :access

        ##
        # @private
        # Initialized a new Access object.
        # Must provide a valid Dataset object.
        def initialize access, context
          @original   = access.dup
          @access     = access.dup
          @context    = context
        end

        # @private
        def changed?
          @original != @access
        end

        ##
        # Add reader access to a user.
        def add_reader_user email
          add_access_role_scope_value :reader, :user, email
        end

        ##
        # Add reader access to a group.
        def add_reader_group email
          add_access_role_scope_value :reader, :group, email
        end

        ##
        # Add reader access to a domain.
        def add_reader_domain domain
          add_access_role_scope_value :reader, :domain, domain
        end

        ##
        # Add reader access to a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def add_reader_special group
          add_access_role_scope_value :reader, :special, group
        end

        ##
        # Add reader access to a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def add_reader_view view
          add_access_role_scope_value :reader, :view, view
        end

        ##
        # Add writer access to a user.
        def add_writer_user email
          add_access_role_scope_value :writer, :user, email
        end

        ##
        # Add writer access to a group.
        def add_writer_group email
          add_access_role_scope_value :writer, :group, email
        end

        ##
        # Add writer access to a domain.
        def add_writer_domain domain
          add_access_role_scope_value :writer, :domain, domain
        end

        ##
        # Add writer access to a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def add_writer_special group
          add_access_role_scope_value :writer, :special, group
        end

        ##
        # Add writer access to a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def add_writer_view view
          add_access_role_scope_value :writer, :view, view
        end

        ##
        # Add owner access to a user.
        def add_owner_user email
          add_access_role_scope_value :owner, :user, email
        end

        ##
        # Add owner access to a group.
        def add_owner_group email
          add_access_role_scope_value :owner, :group, email
        end

        ##
        # Add owner access to a domain.
        def add_owner_domain domain
          add_access_role_scope_value :owner, :domain, domain
        end

        ##
        # Add owner access to a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def add_owner_special group
          add_access_role_scope_value :owner, :special, group
        end

        ##
        # Add owner access to a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def add_owner_view view
          add_access_role_scope_value :owner, :view, view
        end

        ##
        # Remove reader access from a user.
        def remove_reader_user email
          remove_access_role_scope_value :reader, :user, email
        end

        ##
        # Remove reader access from a group.
        def remove_reader_group email
          remove_access_role_scope_value :reader, :group, email
        end

        ##
        # Remove reader access from a domain.
        def remove_reader_domain domain
          remove_access_role_scope_value :reader, :domain, domain
        end

        ##
        # Remove reader access from a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def remove_reader_special group
          remove_access_role_scope_value :reader, :special, group
        end

        ##
        # Remove reader access from a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def remove_reader_view view
          remove_access_role_scope_value :reader, :view, view
        end

        ##
        # Remove writer access from a user.
        def remove_writer_user email
          remove_access_role_scope_value :writer, :user, email
        end

        ##
        # Remove writer access from a group.
        def remove_writer_group email
          remove_access_role_scope_value :writer, :group, email
        end

        ##
        # Remove writer access from a domain.
        def remove_writer_domain domain
          remove_access_role_scope_value :writer, :domain, domain
        end

        ##
        # Remove writer access from a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def remove_writer_special group
          remove_access_role_scope_value :writer, :special, group
        end

        ##
        # Remove writer access from a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def remove_writer_view view
          remove_access_role_scope_value :writer, :view, view
        end

        ##
        # Remove owner access from a user.
        def remove_owner_user email
          remove_access_role_scope_value :owner, :user, email
        end

        ##
        # Remove owner access from a group.
        def remove_owner_group email
          remove_access_role_scope_value :owner, :group, email
        end

        ##
        # Remove owner access from a domain.
        def remove_owner_domain domain
          remove_access_role_scope_value :owner, :domain, domain
        end

        ##
        # Remove owner access from a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def remove_owner_special group
          remove_access_role_scope_value :owner, :special, group
        end

        ##
        # Remove owner access from a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def remove_owner_view view
          remove_access_role_scope_value :owner, :view, view
        end

        ##
        # Checks reader access for a user.
        def reader_user? email
          lookup_access_role_scope_value :reader, :user, email
        end

        ##
        # Checks reader access for a group.
        def reader_group? email
          lookup_access_role_scope_value :reader, :group, email
        end

        ##
        # Checks reader access for a domain.
        def reader_domain? domain
          lookup_access_role_scope_value :reader, :domain, domain
        end

        ##
        # Checks reader access for a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def reader_special? group
          lookup_access_role_scope_value :reader, :special, group
        end

        ##
        # Checks reader access for a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def reader_view? view
          lookup_access_role_scope_value :reader, :view, view
        end

        ##
        # Checks writer access for a user.
        def writer_user? email
          lookup_access_role_scope_value :writer, :user, email
        end

        ##
        # Checks writer access for a group.
        def writer_group? email
          lookup_access_role_scope_value :writer, :group, email
        end

        ##
        # Checks writer access for a domain.
        def writer_domain? domain
          lookup_access_role_scope_value :writer, :domain, domain
        end

        ##
        # Checks writer access for a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def writer_special? group
          lookup_access_role_scope_value :writer, :special, group
        end

        ##
        # Checks writer access for a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def writer_view? view
          lookup_access_role_scope_value :writer, :view, view
        end

        ##
        # Checks owner access for a user.
        def owner_user? email
          lookup_access_role_scope_value :owner, :user, email
        end

        ##
        # Checks owner access for a group.
        def owner_group? email
          lookup_access_role_scope_value :owner, :group, email
        end

        ##
        # Checks owner access for a domain.
        def owner_domain? domain
          lookup_access_role_scope_value :owner, :domain, domain
        end

        ##
        # Checks owner access for a special group.
        # Accepted values are +owners+, +writers+, +readers+, and +all+.
        def owner_special? group
          lookup_access_role_scope_value :owner, :special, group
        end

        ##
        # Checks owner access for a view.
        # The view can be a Gcloud::Bigquery::View object,
        # or a string identifier as specified by the
        # {Query
        # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
        # @param [String] project_name:datasetId.tableId+.
        def owner_view? view
          lookup_access_role_scope_value :owner, :view, view
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
          scope
        end

        # @private
        def validate_view view
          if view.respond_to? :table_ref
            view.table_ref
          else
            Connection.table_ref_from_s view, @context
          end
        end

        # @private
        def add_access_role_scope_value role, scope, value
          role = validate_role role
          scope = validate_scope scope
          # If scope is special group, make sure value is in the list
          value = validate_special_group(value) if scope == "specialGroup"
          # If scope is view, make sure value is in the right format
          value = validate_view(value) if scope == "view"
          # Remove any rules of this scope and value
          access.reject! { |h| h[scope] == value }
          # Add new rule for this role, scope, and value
          access << { "role" => role, scope => value }
        end

        # @private
        def remove_access_role_scope_value role, scope, value
          role = validate_role role
          scope = validate_scope scope
          # If scope is special group, make sure value is in the list
          value = validate_special_group(value) if scope == "specialGroup"
          # If scope is view, make sure value is in the right format
          value = validate_view(value) if scope == "view"
          # Remove any rules of this role, scope, and value
          access.reject! { |h| h["role"] == role && h[scope] == value }
        end

        # @private
        def lookup_access_role_scope_value role, scope, value
          role = validate_role role
          scope = validate_scope scope
          # If scope is special group, make sure value is in the list
          value = validate_special_group(value) if scope == "specialGroup"
          # If scope is view, make sure value is in the right format
          value = validate_view(value) if scope == "view"
          # Detect any rules of this role, scope, and value
          !(!access.detect { |h| h["role"] == role && h[scope] == value })
        end
      end
    end
  end
end
