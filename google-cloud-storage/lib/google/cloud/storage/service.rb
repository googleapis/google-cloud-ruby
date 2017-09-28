# Copyright 2014 Google Inc. All rights reserved.
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


require "google/cloud/storage/version"
require "google/apis/storage_v1"
require "digest"
require "mime/types"
require "pathname"

module Google
  module Cloud
    module Storage
      ##
      # @private Represents the connection to Storage,
      # as well as expose the API calls.
      class Service
        ##
        # Alias to the Google Client API module
        API = Google::Apis::StorageV1

        # @private
        attr_accessor :project

        # @private
        attr_accessor :credentials

        ##
        # Creates a new Service instance.
        def initialize project, credentials, retries: nil, timeout: nil
          @project = project
          @credentials = credentials
          @credentials = credentials
          @service = API::StorageService.new
          @service.client_options.application_name    = "gcloud-ruby"
          @service.client_options.application_version = \
            Google::Cloud::Storage::VERSION
          @service.client_options.open_timeout_sec = timeout
          @service.client_options.read_timeout_sec = timeout
          @service.client_options.send_timeout_sec = timeout
          @service.request_options.retries = retries || 3
          @service.request_options.header ||= {}
          @service.request_options.header["x-goog-api-client"] = \
            "gl-ruby/#{RUBY_VERSION} gccl/#{Google::Cloud::Storage::VERSION}"
          @service.authorization = @credentials.client
        end

        def service
          return mocked_service if mocked_service
          @service
        end
        attr_accessor :mocked_service

        ##
        # Retrieves a list of buckets for the given project.
        def list_buckets prefix: nil, token: nil, max: nil, user_project: nil
          execute do
            service.list_buckets \
              @project, prefix: prefix, page_token: token, max_results: max,
                        user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves bucket by name.
        # Returns Google::Apis::StorageV1::Bucket.
        def get_bucket bucket_name, user_project: nil
          execute do
            service.get_bucket bucket_name,
                               user_project: user_project(user_project)
          end
        end

        ##
        # Creates a new bucket.
        # Returns Google::Apis::StorageV1::Bucket.
        def insert_bucket bucket_gapi, acl: nil, default_acl: nil,
                          user_project: nil
          execute do
            service.insert_bucket \
              @project, bucket_gapi,
              predefined_acl: acl,
              predefined_default_object_acl: default_acl,
              user_project: user_project(user_project)
          end
        end

        ##
        # Updates a bucket, including its ACL metadata.
        def patch_bucket bucket_name, bucket_gapi = nil, predefined_acl: nil,
                         predefined_default_acl: nil, user_project: nil
          bucket_gapi ||= Google::Apis::StorageV1::Bucket.new
          bucket_gapi.acl = [] if predefined_acl
          bucket_gapi.default_object_acl = [] if predefined_default_acl

          execute do
            service.patch_bucket \
              bucket_name, bucket_gapi,
              predefined_acl: predefined_acl,
              predefined_default_object_acl: predefined_default_acl,
              user_project: user_project(user_project)
          end
        end

        ##
        # Permanently deletes an empty bucket.
        def delete_bucket bucket_name, user_project: nil
          execute do
            service.delete_bucket bucket_name,
                                  user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves a list of ACLs for the given bucket.
        def list_bucket_acls bucket_name, user_project: nil
          execute do
            service.list_bucket_access_controls \
              bucket_name, user_project: user_project(user_project)
          end
        end

        ##
        # Creates a new bucket ACL.
        def insert_bucket_acl bucket_name, entity, role, user_project: nil
          new_acl = Google::Apis::StorageV1::BucketAccessControl.new({
            entity: entity, role: role }.delete_if { |_k, v| v.nil? })
          execute do
            service.insert_bucket_access_control \
              bucket_name, new_acl, user_project: user_project(user_project)
          end
        end

        ##
        # Permanently deletes a bucket ACL.
        def delete_bucket_acl bucket_name, entity, user_project: nil
          execute do
            service.delete_bucket_access_control \
              bucket_name, entity, user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves a list of default ACLs for the given bucket.
        def list_default_acls bucket_name, user_project: nil
          execute do
            service.list_default_object_access_controls \
              bucket_name, user_project: user_project(user_project)
          end
        end

        ##
        # Creates a new default ACL.
        def insert_default_acl bucket_name, entity, role, user_project: nil
          new_acl = Google::Apis::StorageV1::ObjectAccessControl.new({
            entity: entity, role: role }.delete_if { |_k, v| v.nil? })
          execute do
            service.insert_default_object_access_control \
              bucket_name, new_acl, user_project: user_project(user_project)
          end
        end

        ##
        # Permanently deletes a default ACL.
        def delete_default_acl bucket_name, entity, user_project: nil
          execute do
            service.delete_default_object_access_control \
              bucket_name, entity, user_project: user_project(user_project)
          end
        end

        ##
        # Returns Google::Apis::StorageV1::Policy
        def get_bucket_policy bucket_name, user_project: nil
          # get_bucket_iam_policy(bucket, fields: nil, quota_user: nil,
          #                               user_ip: nil, options: nil)
          execute do
            service.get_bucket_iam_policy \
              bucket_name, user_project: user_project(user_project)
          end
        end

        ##
        # Returns Google::Apis::StorageV1::Policy
        def set_bucket_policy bucket_name, new_policy, user_project: nil
          execute do
            service.set_bucket_iam_policy \
              bucket_name, new_policy, user_project: user_project(user_project)
          end
        end

        ##
        # Returns Google::Apis::StorageV1::TestIamPermissionsResponse
        def test_bucket_permissions bucket_name, permissions, user_project: nil
          execute do
            service.test_bucket_iam_permissions \
              bucket_name, permissions, user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves a list of Pub/Sub notification subscriptions for a bucket.
        def list_notifications bucket_name, user_project: nil
          execute do
            service.list_notifications bucket_name,
                                       user_project: user_project(user_project)
          end
        end

        ##
        # Creates a new Pub/Sub notification subscription for a bucket.
        def insert_notification bucket_name, topic_name, custom_attrs: nil,
                                event_types: nil, prefix: nil, payload: nil,
                                user_project: nil
          new_notification = Google::Apis::StorageV1::Notification.new({
            custom_attributes: custom_attrs,
            event_types: event_types(event_types),
            object_name_prefix: prefix,
            payload_format: payload_format(payload),
            topic: topic_path(topic_name) }.delete_if { |_k, v| v.nil? })

          execute do
            service.insert_notification \
              bucket_name, new_notification,
              user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves a Pub/Sub notification subscription for a bucket.
        def get_notification bucket_name, notification_id, user_project: nil
          execute do
            service.get_notification bucket_name, notification_id,
                                     user_project: user_project(user_project)
          end
        end

        ##
        # Deletes a new Pub/Sub notification subscription for a bucket.
        def delete_notification bucket_name, notification_id, user_project: nil
          execute do
            service.delete_notification bucket_name, notification_id,
                                        user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves a list of files matching the criteria.
        def list_files bucket_name, delimiter: nil, max: nil, token: nil,
                       prefix: nil, versions: nil, user_project: nil
          execute do
            service.list_objects \
              bucket_name, delimiter: delimiter, max_results: max,
                           page_token: token, prefix: prefix,
                           versions: versions,
                           user_project: user_project(user_project)
          end
        end

        ##
        # Inserts a new file for the given bucket
        def insert_file bucket_name, source, path = nil, acl: nil,
                        cache_control: nil, content_disposition: nil,
                        content_encoding: nil, content_language: nil,
                        content_type: nil, crc32c: nil, md5: nil, metadata: nil,
                        storage_class: nil, key: nil, user_project: nil
          file_obj = Google::Apis::StorageV1::Object.new({
            cache_control: cache_control, content_type: content_type,
            content_disposition: content_disposition, md5_hash: md5,
            content_encoding: content_encoding, crc32c: crc32c,
            content_language: content_language, metadata: metadata,
            storage_class: storage_class }.delete_if { |_k, v| v.nil? })
          content_type ||= mime_type_for(path || Pathname(source).to_path)

          execute do
            service.insert_object \
              bucket_name, file_obj,
              name: path, predefined_acl: acl, upload_source: source,
              content_encoding: content_encoding, content_type: content_type,
              user_project: user_project(user_project),
              options: key_options(key)
          end
        end

        ##
        # Retrieves an object or its metadata.
        def get_file bucket_name, file_path, generation: nil, key: nil,
                     user_project: nil
          execute do
            service.get_object \
              bucket_name, file_path,
              generation: generation,
              user_project: user_project(user_project),
              options: key_options(key)
          end
        end

        ## Copy a file from source bucket/object to a
        # destination bucket/object.
        def copy_file source_bucket_name, source_file_path,
                      destination_bucket_name, destination_file_path,
                      file_gapi = nil, key: nil, acl: nil, generation: nil,
                      token: nil, user_project: nil
          key_options = rewrite_key_options key, key
          execute do
            service.rewrite_object \
              source_bucket_name, source_file_path,
              destination_bucket_name, destination_file_path,
              file_gapi,
              destination_predefined_acl: acl,
              source_generation: generation,
              rewrite_token: token,
              user_project: user_project(user_project),
              options: key_options
          end
        end

        ## Rewrite a file from source bucket/object to a
        # destination bucket/object.
        def rewrite_file source_bucket_name, source_file_path,
                         destination_bucket_name, destination_file_path,
                         file_gapi = nil, source_key: nil, destination_key: nil,
                         acl: nil, generation: nil, token: nil,
                         user_project: nil
          key_options = rewrite_key_options source_key, destination_key
          execute do
            service.rewrite_object \
              source_bucket_name, source_file_path,
              destination_bucket_name, destination_file_path,
              file_gapi,
              destination_predefined_acl: acl,
              source_generation: generation,
              rewrite_token: token,
              user_project: user_project(user_project),
              options: key_options
          end
        end

        ##
        # Download contents of a file.
        def download_file bucket_name, file_path, target_path, generation: nil,
                          key: nil, user_project: nil
          execute do
            service.get_object \
              bucket_name, file_path,
              download_dest: target_path, generation: generation,
              user_project: user_project(user_project),
              options: key_options(key)
          end
        end

        ##
        # Updates a file's metadata.
        def patch_file bucket_name, file_path, file_gapi = nil,
                       predefined_acl: nil, user_project: nil
          file_gapi ||= Google::Apis::StorageV1::Object.new
          execute do
            service.patch_object \
              bucket_name, file_path, file_gapi,
              predefined_acl: predefined_acl,
              user_project: user_project(user_project)
          end
        end

        ##
        # Permanently deletes a file.
        def delete_file bucket_name, file_path, generation: nil,
                        user_project: nil
          execute do
            service.delete_object bucket_name, file_path,
                                  generation: generation,
                                  user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves a list of ACLs for the given file.
        def list_file_acls bucket_name, file_name, user_project: nil
          execute do
            service.list_object_access_controls \
              bucket_name, file_name, user_project: user_project(user_project)
          end
        end

        ##
        # Creates a new file ACL.
        def insert_file_acl bucket_name, file_name, entity, role,
                            generation: nil, user_project: nil
          new_acl = Google::Apis::StorageV1::ObjectAccessControl.new({
            entity: entity, role: role }.delete_if { |_k, v| v.nil? })
          execute do
            service.insert_object_access_control \
              bucket_name, file_name, new_acl,
              generation: generation, user_project: user_project(user_project)
          end
        end

        ##
        # Permanently deletes a file ACL.
        def delete_file_acl bucket_name, file_name, entity, generation: nil,
                            user_project: nil
          execute do
            service.delete_object_access_control \
              bucket_name, file_name, entity,
              generation: generation, user_project: user_project(user_project)
          end
        end

        ##
        # Retrieves the mime-type for a file path.
        # An empty string is returned if no mime-type can be found.
        def mime_type_for path
          MIME::Types.of(path).first.to_s
        end

        # @private
        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def user_project user_project
          return nil unless user_project # nil or false get nil
          return @project if user_project == true # handle the true  condition
          String(user_project) # convert the value to a string
        end

        def key_options key
          options = {}
          encryption_key_headers options, key if key
          options
        end

        def rewrite_key_options source_key, destination_key
          options = {}
          if source_key
            encryption_key_headers options, source_key, copy_source: true
          end
          encryption_key_headers options, destination_key if destination_key
          options
        end

        # @private
        # @param copy_source If true, header names are those for source object
        #   in rewrite request. If false, the header names are for use with any
        #   method supporting customer-supplied encryption keys.
        #   See https://cloud.google.com/storage/docs/encryption#request
        def encryption_key_headers options, key, copy_source: false
          source = copy_source ? "copy-source-" : ""
          key_sha256 = Digest::SHA256.digest key
          headers = (options[:header] ||= {})
          headers["x-goog-#{source}encryption-algorithm"] = "AES256"
          headers["x-goog-#{source}encryption-key"] = Base64.strict_encode64 key
          headers["x-goog-#{source}encryption-key-sha256"] = \
            Base64.strict_encode64 key_sha256
          options
        end

        def topic_path topic_name
          return topic_name if topic_name.to_s.include? "/"
          "//pubsub.googleapis.com/projects/#{project}/topics/#{topic_name}"
        end

        # Pub/Sub notification subscription event_types
        def event_types str_or_arr
          Array(str_or_arr).map { |x| event_type x } if str_or_arr
        end

        # Pub/Sub notification subscription event_types
        def event_type str
          { "object_finalize" => "OBJECT_FINALIZE",
            "finalize" => "OBJECT_FINALIZE",
            "create" => "OBJECT_FINALIZE",
            "object_metadata_update" => "OBJECT_METADATA_UPDATE",
            "object_update" => "OBJECT_METADATA_UPDATE",
            "metadata_update" => "OBJECT_METADATA_UPDATE",
            "update" => "OBJECT_METADATA_UPDATE",
            "object_delete" => "OBJECT_DELETE",
            "delete" => "OBJECT_DELETE",
            "object_archive" => "OBJECT_ARCHIVE",
            "archive" => "OBJECT_ARCHIVE" }[str.to_s.downcase]
        end

        # Pub/Sub notification subscription payload_format
        # Defaults to "JSON_API_V1"
        def payload_format str_or_bool
          return "JSON_API_V1" if str_or_bool.nil?
          { "json_api_v1" => "JSON_API_V1",
            "json" => "JSON_API_V1",
            "true" => "JSON_API_V1",
            "none" => "NONE",
            "false" => "NONE" }[str_or_bool.to_s.downcase]
        end

        def execute
          yield
        rescue Google::Apis::Error => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
