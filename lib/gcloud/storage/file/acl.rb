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
    class File
      ##
      # Represents a File's Access Control List.
      class Acl
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
        # Initialized a new Acl object.
        # Must provide a valid Bucket object.
        def initialize file #:nodoc:
          @bucket = file.bucket
          @file = file.name
          @connection = file.connection
          @owners  = nil
          @writers = nil
          @readers = nil
        end

        def refresh!
          resp = @connection.list_file_acls @bucket, @file
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

        def add_owner entity, options = {}
          resp = @connection.insert_file_acl @bucket, @file, entity,
                                             "OWNER", options
          if resp.success?
            entity = resp.data["entity"]
            @owners.push entity unless @owners.nil?
            return entity
          end
          nil
        end

        def add_writer entity, options = {}
          resp = @connection.insert_file_acl @bucket, @file, entity,
                                             "WRITER", options
          if resp.success?
            entity = resp.data["entity"]
            @writers.push entity unless @writers.nil?
            return entity
          end
          nil
        end

        def add_reader entity, options = {}
          resp = @connection.insert_file_acl @bucket, @file, entity,
                                             "READER", options
          if resp.success?
            entity = resp.data["entity"]
            @readers.push entity unless @readers.nil?
            return entity
          end
          nil
        end

        def delete entity, options = {}
          resp = @connection.delete_file_acl @bucket, @file, entity, options
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

        def owner_full!
          update_predefined_acl! "bucketOwnerFullControl"
        end
        alias_method :bucketOwnerFullControl!, :owner_full!

        def owner_read!
          update_predefined_acl! "bucketOwnerRead"
        end
        alias_method :bucketOwnerRead!, :owner_read!

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

        protected

        def update_predefined_acl! acl_role
          resp = @connection.patch_file @bucket, @file,
                                        acl: acl_role

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
