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
      # = Bucket Access Control List
      #
      # Represents a Bucket's Access Control List.
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.acl.readers.each { |reader| puts reader }
      #
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
                  "public_write" => "publicReadWrite" } #:nodoc:

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

        ##
        # Reloads all Access Control List data for the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.refresh!
        #
        def refresh!
          resp = @connection.list_bucket_acls @bucket
          acls = resp.data["items"]
          @owners  = entities_from_acls acls, "OWNER"
          @writers = entities_from_acls acls, "WRITER"
          @readers = entities_from_acls acls, "READER"
        end

        ##
        # Lists the owners of the bucket.
        #
        # === Returns
        #
        # Array of Strings
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.owners.each { |owner| puts owner }
        #
        def owners
          refresh! if @owners.nil?
          @owners
        end

        ##
        # Lists the owners of the bucket.
        #
        # === Returns
        #
        # Array of Strings
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.writers.each { |writer| puts writer }
        #
        def writers
          refresh! if @writers.nil?
          @writers
        end

        ##
        # Lists the readers of the bucket.
        #
        # === Returns
        #
        # Array of Strings
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.readers.each { |reader| puts reader }
        #
        def readers
          refresh! if @readers.nil?
          @readers
        end

        ##
        # Grants owner permission to the bucket.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Examples
        #
        # Access to a bucket can be granted to a user by appending +"user-"+ to
        # the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.acl.add_owner "user-#{email}"
        #
        # Access to a bucket can be granted to a group by appending +"group-"+
        # to the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "authors@example.net"
        #   bucket.acl.add_owner "group-#{email}"
        #
        def add_owner entity
          resp = @connection.insert_bucket_acl @bucket, entity, "OWNER"
          if resp.success?
            entity = resp.data["entity"]
            @owners.push entity unless @owners.nil?
            return entity
          end
          nil
        end

        ##
        # Grants writer permission to the bucket.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Examples
        #
        # Access to a bucket can be granted to a user by appending +"user-"+ to
        # the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.acl.add_writer "user-#{email}"
        #
        # Access to a bucket can be granted to a group by appending +"group-"+
        # to the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "authors@example.net"
        #   bucket.acl.add_writer "group-#{email}"
        #
        def add_writer entity
          resp = @connection.insert_bucket_acl @bucket, entity, "WRITER"
          if resp.success?
            entity = resp.data["entity"]
            @writers.push entity unless @writers.nil?
            return entity
          end
          nil
        end

        ##
        # Grants reader permission to the bucket.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Examples
        #
        # Access to a bucket can be granted to a user by appending +"user-"+ to
        # the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.acl.add_reader "user-#{email}"
        #
        # Access to a bucket can be granted to a group by appending +"group-"+
        # to the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "authors@example.net"
        #   bucket.acl.add_reader "group-#{email}"
        #
        def add_reader entity
          resp = @connection.insert_bucket_acl @bucket, entity, "READER"
          if resp.success?
            entity = resp.data["entity"]
            @readers.push entity unless @readers.nil?
            return entity
          end
          nil
        end

        ##
        # Permenently deletes the entity from the bucket's access control list.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.acl.delete "user-#{email}"
        #
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

        def self.predefined_rule_for rule_name #:nodoc:
          RULES[rule_name.to_s]
        end

        # Predefined ACL helpers

        ##
        # Convenience method to apply the +authenticatedRead+ predefined ACL
        # rule to the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.auth!
        #
        def auth!
          update_predefined_acl! "authenticatedRead"
        end
        alias_method :authenticatedRead!, :auth!
        alias_method :auth_read!, :auth!
        alias_method :authenticated!, :auth!
        alias_method :authenticated_read!, :auth!

        ##
        # Convenience method to apply the +private+ predefined ACL
        # rule to the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.private!
        #
        def private!
          update_predefined_acl! "private"
        end

        ##
        # Convenience method to apply the +projectPrivate+ predefined ACL
        # rule to the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.project_private!
        #
        def project_private!
          update_predefined_acl! "projectPrivate"
        end
        alias_method :projectPrivate!, :project_private!

        ##
        # Convenience method to apply the +publicRead+ predefined ACL
        # rule to the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.public!
        #
        def public!
          update_predefined_acl! "publicRead"
        end
        alias_method :publicRead!, :public!
        alias_method :public_read!, :public!

        # Convenience method to apply the +publicReadWrite+ predefined ACL
        # rule to the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.public_write!
        #
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
      # = Bucket Default Access Control List
      #
      # Represents a Bucket's Default Access Control List.
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.default_acl.readers.each { |reader| puts reader }
      #
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
                  "public_read" => "publicRead" } #:nodoc:

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

        ##
        # Reloads all Default Access Control List data for the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.default_acl.refresh!
        #
        def refresh!
          resp = @connection.list_default_acls @bucket
          acls = resp.data["items"]
          @owners  = entities_from_acls acls, "OWNER"
          @writers = entities_from_acls acls, "WRITER"
          @readers = entities_from_acls acls, "READER"
        end

        ##
        # Lists the default owners for files in the bucket.
        #
        # === Returns
        #
        # Array of Strings
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.default_acl.owners.each { |owner| puts owner }
        #
        def owners
          refresh! if @owners.nil?
          @owners
        end

        ##
        # Lists the default writers for files in the bucket.
        #
        # === Returns
        #
        # Array of Strings
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.default_acl.writers.each { |writer| puts writer }
        #
        def writers
          refresh! if @writers.nil?
          @writers
        end

        ##
        # Lists the default readers for files in the bucket.
        #
        # === Returns
        #
        # Array of Strings
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.default_acl.readers.each { |reader| puts reader }
        #
        def readers
          refresh! if @readers.nil?
          @readers
        end

        ##
        # Grants default owner permission to files in the bucket.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Examples
        #
        # Access to a bucket can be granted to a user by appending +"user-"+ to
        # the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.default_acl.add_owner "user-#{email}"
        #
        # Access to a bucket can be granted to a group by appending +"group-"+
        # to the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "authors@example.net"
        #   bucket.default_acl.add_owner "group-#{email}"
        #
        def add_owner entity
          resp = @connection.insert_default_acl @bucket, entity, "OWNER"
          if resp.success?
            entity = resp.data["entity"]
            @owners.push entity unless @owners.nil?
            return entity
          end
          nil
        end

        ##
        # Grants default writer permission to files in the bucket.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Examples
        #
        # Access to a bucket can be granted to a user by appending +"user-"+ to
        # the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.default_acl.add_writer "user-#{email}"
        #
        # Access to a bucket can be granted to a group by appending +"group-"+
        # to the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "authors@example.net"
        #   bucket.default_acl.add_writer "group-#{email}"
        #
        def add_writer entity
          resp = @connection.insert_default_acl @bucket, entity, "WRITER"
          if resp.success?
            entity = resp.data["entity"]
            @writers.push entity unless @writers.nil?
            return entity
          end
          nil
        end

        ##
        # Grants default reader permission to files in the bucket.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Examples
        #
        # Access to a bucket can be granted to a user by appending +"user-"+ to
        # the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.default_acl.add_reader "user-#{email}"
        #
        # Access to a bucket can be granted to a group by appending +"group-"+
        # to the email address:
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "authors@example.net"
        #   bucket.default_acl.add_reader "group-#{email}"
        #
        def add_reader entity
          resp = @connection.insert_default_acl @bucket, entity, "READER"
          if resp.success?
            entity = resp.data["entity"]
            @readers.push entity unless @readers.nil?
            return entity
          end
          nil
        end

        ##
        # Permenently deletes the entity from the bucket's default access
        # control list for files.
        #
        # === Parameters
        #
        # +entity+::
        #   The entity holding the permission, in one of the following forms:
        #   (+String+)
        #
        #   * user-userId
        #   * user-email
        #   * group-groupId
        #   * group-email
        #   * domain-domain
        #   * project-team-projectId
        #   * allUsers
        #   * allAuthenticatedUsers
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   email = "heidi@example.net"
        #   bucket.default_acl.delete "user-#{email}"
        #
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

        def self.predefined_rule_for rule_name #:nodoc:
          RULES[rule_name.to_s]
        end

        # Predefined ACL helpers

        ##
        # Convenience method to apply the default +authenticatedRead+
        # predefined ACL rule to files in the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.auth!
        #
        def auth!
          update_predefined_default_acl! "authenticatedRead"
        end
        alias_method :authenticatedRead!, :auth!
        alias_method :auth_read!, :auth!
        alias_method :authenticated!, :auth!
        alias_method :authenticated_read!, :auth!

        ##
        # Convenience method to apply the default +bucketOwnerFullControl+
        # predefined ACL rule to files in the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.owner_full!
        #
        def owner_full!
          update_predefined_default_acl! "bucketOwnerFullControl"
        end
        alias_method :bucketOwnerFullControl!, :owner_full!

        ##
        # Convenience method to apply the default +bucketOwnerRead+
        # predefined ACL rule to files in the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.owner_read!
        #
        def owner_read!
          update_predefined_default_acl! "bucketOwnerRead"
        end
        alias_method :bucketOwnerRead!, :owner_read!

        ##
        # Convenience method to apply the default +private+
        # predefined ACL rule to files in the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.private!
        #
        def private!
          update_predefined_default_acl! "private"
        end

        ##
        # Convenience method to apply the default +projectPrivate+
        # predefined ACL rule to files in the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.project_private!
        #
        def project_private!
          update_predefined_default_acl! "projectPrivate"
        end
        alias_method :projectPrivate!, :project_private!

        ##
        # Convenience method to apply the default +publicRead+
        # predefined ACL rule to files in the bucket.
        #
        # === Example
        #
        #   require "gcloud/storage"
        #
        #   storage = Gcloud.storage
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.acl.public!
        #
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
