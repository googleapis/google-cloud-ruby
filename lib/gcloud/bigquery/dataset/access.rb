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
      # Represents the Access rules for a Dataset. See {BigQuery Access
      # Control}[https://cloud.google.com/bigquery/access-control].
      #
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
        ROLES = { "reader" => "READER",
                  "writer" => "WRITER",
                  "owner"  => "OWNER" } #:nodoc:

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
                   "view"           => "view" } #:nodoc:

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

        attr_reader :access #:nodoc:

        ##
        # Initialized a new Access object.
        # Must provide a valid Dataset object.
        def initialize access, context #:nodoc:
          @original   = access.dup
          @access     = access.dup
          @context    = context
        end

        def changed? #:nodoc:
          @original != @access
        end

        ##
        # Add

        def add_reader_user email
          add_access_role_scope_value :reader, :user, email
        end

        def add_reader_group email
          add_access_role_scope_value :reader, :group, email
        end

        def add_reader_domain domain
          add_access_role_scope_value :reader, :domain, domain
        end

        def add_reader_special group
          add_access_role_scope_value :reader, :special, group
        end

        def add_reader_view view
          add_access_role_scope_value :reader, :view, view
        end

        def add_writer_user email
          add_access_role_scope_value :writer, :user, email
        end

        def add_writer_group email
          add_access_role_scope_value :writer, :group, email
        end

        def add_writer_domain domain
          add_access_role_scope_value :writer, :domain, domain
        end

        def add_writer_special group
          add_access_role_scope_value :writer, :special, group
        end

        def add_writer_view view
          add_access_role_scope_value :writer, :view, view
        end

        def add_owner_user email
          add_access_role_scope_value :owner, :user, email
        end

        def add_owner_group email
          add_access_role_scope_value :owner, :group, email
        end

        def add_owner_domain domain
          add_access_role_scope_value :owner, :domain, domain
        end

        def add_owner_special group
          add_access_role_scope_value :owner, :special, group
        end

        def add_owner_view view
          add_access_role_scope_value :owner, :view, view
        end

        ##
        # Remove

        def remove_reader_user email
          remove_access_role_scope_value :reader, :user, email
        end

        def remove_reader_group email
          remove_access_role_scope_value :reader, :group, email
        end

        def remove_reader_domain domain
          remove_access_role_scope_value :reader, :domain, domain
        end

        def remove_reader_special group
          remove_access_role_scope_value :reader, :special, group
        end

        def remove_reader_view view
          remove_access_role_scope_value :reader, :view, view
        end

        def remove_writer_user email
          remove_access_role_scope_value :writer, :user, email
        end

        def remove_writer_group email
          remove_access_role_scope_value :writer, :group, email
        end

        def remove_writer_domain domain
          remove_access_role_scope_value :writer, :domain, domain
        end

        def remove_writer_special group
          remove_access_role_scope_value :writer, :special, group
        end

        def remove_writer_view view
          remove_access_role_scope_value :writer, :view, view
        end

        def remove_owner_user email
          remove_access_role_scope_value :owner, :user, email
        end

        def remove_owner_group email
          remove_access_role_scope_value :owner, :group, email
        end

        def remove_owner_domain domain
          remove_access_role_scope_value :owner, :domain, domain
        end

        def remove_owner_special group
          remove_access_role_scope_value :owner, :special, group
        end

        def remove_owner_view view
          remove_access_role_scope_value :owner, :view, view
        end

        ##
        # Lookup

        def reader_user? email
          lookup_access_role_scope_value :reader, :user, email
        end

        def reader_group? email
          lookup_access_role_scope_value :reader, :group, email
        end

        def reader_domain? domain
          lookup_access_role_scope_value :reader, :domain, domain
        end

        def reader_special? group
          lookup_access_role_scope_value :reader, :special, group
        end

        def reader_view? view
          lookup_access_role_scope_value :reader, :view, view
        end

        def writer_user? email
          lookup_access_role_scope_value :writer, :user, email
        end

        def writer_group? email
          lookup_access_role_scope_value :writer, :group, email
        end

        def writer_domain? domain
          lookup_access_role_scope_value :writer, :domain, domain
        end

        def writer_special? group
          lookup_access_role_scope_value :writer, :special, group
        end

        def writer_view? view
          lookup_access_role_scope_value :writer, :view, view
        end

        def owner_user? email
          lookup_access_role_scope_value :owner, :user, email
        end

        def owner_group? email
          lookup_access_role_scope_value :owner, :group, email
        end

        def owner_domain? domain
          lookup_access_role_scope_value :owner, :domain, domain
        end

        def owner_special? group
          lookup_access_role_scope_value :owner, :special, group
        end

        def owner_view? view
          lookup_access_role_scope_value :owner, :view, view
        end

        protected

        def validate_role role #:nodoc:
          good_role = ROLES[role.to_s]
          if good_role.nil?
            fail ArgumentError "Unable to determine role for #{role}"
          end
          good_role
        end

        def validate_scope scope #:nodoc:
          good_scope = SCOPES[scope.to_s]
          if good_scope.nil?
            fail ArgumentError "Unable to determine scope for #{scope}"
          end
          good_scope
        end

        def validate_special_group value #:nodoc:
          good_value = GROUPS[value.to_s]
          return good_value unless good_value.nil?
          scope
        end

        def validate_view view #:nodoc:
          if view.respond_to? :table_ref
            view.table_ref
          else
            Connection.table_ref_from_s view, @context
          end
        end

        def add_access_role_scope_value role, scope, value #:nodoc:
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

        def remove_access_role_scope_value role, scope, value #:nodoc:
          role = validate_role role
          scope = validate_scope scope
          # If scope is special group, make sure value is in the list
          value = validate_special_group(value) if scope == "specialGroup"
          # If scope is view, make sure value is in the right format
          value = validate_view(value) if scope == "view"
          # Remove any rules of this role, scope, and value
          access.reject! { |h| h["role"] == role && h[scope] == value }
        end

        def lookup_access_role_scope_value role, scope, value #:nodoc:
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
