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
  module Storage
    class Bucket
      ##
      # Represents a Bucket's Access Control List.
      class Acl
        RULES = { "authenticatedRead" => "authenticatedRead",
                  "auth" => "authenticatedRead",
                  "auth_read" => "authenticatedRead",
                  "authenticated" => "authenticatedRead",
                  "authenticated_read" => "authenticatedRead",
                  "private" => "private",
                  "projectPrivate" => "projectPrivate",
                  "proj_private" => "projectPrivate",
                  "project_private" => "projectPrivate",
                  "publicRead" => "publicRead",
                  "public" => "publicRead",
                  "public_read" => "publicRead",
                  "publicReadWrite" => "publicReadWrite",
                  "public_write" => "publicReadWrite" }

        ##
        # Initialized a new Acl object.
        # Must provide a valid Bucket object.
        def initialize bucket #:nodoc:
          @bucket = bucket.name
          @connection = bucket.connection
          @owners  = nil
          @writers = nil
          @readers = nil
        end

        def refresh!
          resp = @connection.list_bucket_acls @bucket
          acls = resp.data["items"]
          @owners  = entities_from_acls acls, "OWNER"
          @writers = entities_from_acls acls, "WRITER"
          @readers = entities_from_acls acls, "READER"
        end

        def owners
          refresh! if @owners.nil?
          @owners
        end

        def writers
          refresh! if @writers.nil?
          @writers
        end

        def readers
          refresh! if @readers.nil?
          @readers
        end

        def add_owner entity
          resp = @connection.insert_bucket_acl @bucket, entity, "OWNER"
          if resp.success?
            entity = resp.data["entity"]
            @owners.push entity unless @owners.nil?
            return entity
          end
          nil
        end

        def add_writer entity
          resp = @connection.insert_bucket_acl @bucket, entity, "WRITER"
          if resp.success?
            entity = resp.data["entity"]
            @writers.push entity unless @writers.nil?
            return entity
          end
          nil
        end

        def add_reader entity
          resp = @connection.insert_bucket_acl @bucket, entity, "READER"
          if resp.success?
            entity = resp.data["entity"]
            @readers.push entity unless @readers.nil?
            return entity
          end
          nil
        end

        def delete entity
          resp = @connection.delete_bucket_acl @bucket, entity
          if resp.success?
            @owners.delete entity  unless @owners.nil?
            @writers.delete entity unless @writers.nil?
            @readers.delete entity unless @readers.nil?
            return true
          end
          false
        end

        def self.predefined_rule_for rule_name
          RULES[rule_name.to_s]
        end

        # Predefined ACL helpers

        def auth!
          update_predefined_acl! "authenticatedRead"
        end
        alias_method :authenticatedRead!, :auth!
        alias_method :auth_read!, :auth!
        alias_method :authenticated!, :auth!
        alias_method :authenticated_read!, :auth!

        def private!
          update_predefined_acl! "private"
        end

        def project_private!
          update_predefined_acl! "projectPrivate"
        end
        alias_method :projectPrivate!, :project_private!

        def public!
          update_predefined_acl! "publicRead"
        end
        alias_method :publicRead!, :public!
        alias_method :public_read!, :public!

        def public_write!
          update_predefined_acl! "publicReadWrite"
        end
        alias_method :publicReadWrite!, :public_write!

        protected

        def update_predefined_acl! acl_role
          resp = @connection.patch_bucket @bucket,
                                          acl: acl_role

          resp.success?
        end

        def entities_from_acls acls, role
          selected = acls.select { |acl| acl["role"] == role }
          entities = selected.map { |acl| acl["entity"] }
          entities
        end
      end

      ##
      # Represents a Bucket's Default Access Control List.
      class DefaultAcl
        RULES = { "authenticatedRead" => "authenticatedRead",
                  "auth" => "authenticatedRead",
                  "auth_read" => "authenticatedRead",
                  "authenticated" => "authenticatedRead",
                  "authenticated_read" => "authenticatedRead",
                  "bucketOwnerFullControl" => "bucketOwnerFullControl",
                  "owner_full" => "bucketOwnerFullControl",
                  "bucketOwnerRead" => "bucketOwnerRead",
                  "owner_read" => "bucketOwnerRead",
                  "private" => "private",
                  "projectPrivate" => "projectPrivate",
                  "project_private" => "projectPrivate",
                  "publicRead" => "publicRead",
                  "public" => "publicRead",
                  "public_read" => "publicRead" }

        ##
        # Initialized a new DefaultAcl object.
        # Must provide a valid Bucket object.
        def initialize bucket #:nodoc:
          @bucket = bucket.name
          @connection = bucket.connection
          @owners  = nil
          @writers = nil
          @readers = nil
        end

        def refresh!
          resp = @connection.list_default_acls @bucket
          acls = resp.data["items"]
          @owners  = entities_from_acls acls, "OWNER"
          @writers = entities_from_acls acls, "WRITER"
          @readers = entities_from_acls acls, "READER"
        end

        def owners
          refresh! if @owners.nil?
          @owners
        end

        def writers
          refresh! if @writers.nil?
          @writers
        end

        def readers
          refresh! if @readers.nil?
          @readers
        end

        def add_owner entity
          resp = @connection.insert_default_acl @bucket, entity, "OWNER"
          if resp.success?
            entity = resp.data["entity"]
            @owners.push entity unless @owners.nil?
            return entity
          end
          nil
        end

        def add_writer entity
          resp = @connection.insert_default_acl @bucket, entity, "WRITER"
          if resp.success?
            entity = resp.data["entity"]
            @writers.push entity unless @writers.nil?
            return entity
          end
          nil
        end

        def add_reader entity
          resp = @connection.insert_default_acl @bucket, entity, "READER"
          if resp.success?
            entity = resp.data["entity"]
            @readers.push entity unless @readers.nil?
            return entity
          end
          nil
        end

        def delete entity
          resp = @connection.delete_default_acl @bucket, entity
          if resp.success?
            @owners.delete entity  unless @owners.nil?
            @writers.delete entity unless @writers.nil?
            @readers.delete entity unless @readers.nil?
            return true
          end
          false
        end

        def self.predefined_rule_for rule_name
          RULES[rule_name.to_s]
        end

        # Predefined ACL helpers

        def auth!
          update_predefined_default_acl! "authenticatedRead"
        end
        alias_method :authenticatedRead!, :auth!
        alias_method :auth_read!, :auth!
        alias_method :authenticated!, :auth!
        alias_method :authenticated_read!, :auth!

        def owner_full!
          update_predefined_default_acl! "bucketOwnerFullControl"
        end
        alias_method :bucketOwnerFullControl!, :owner_full!

        def owner_read!
          update_predefined_default_acl! "bucketOwnerRead"
        end
        alias_method :bucketOwnerRead!, :owner_read!

        def private!
          update_predefined_default_acl! "private"
        end

        def project_private!
          update_predefined_default_acl! "projectPrivate"
        end
        alias_method :projectPrivate!, :project_private!

        def public!
          update_predefined_default_acl! "publicRead"
        end
        alias_method :publicRead!, :public!
        alias_method :public_read!, :public!

        protected

        def update_predefined_default_acl! acl_role
          resp = @connection.patch_bucket @bucket,
                                          default_acl: acl_role

          resp.success?
        end

        def entities_from_acls acls, role
          selected = acls.select { |acl| acl["role"] == role }
          entities = selected.map { |acl| acl["entity"] }
          entities
        end
      end
    end
  end
end
