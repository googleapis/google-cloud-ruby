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


require "gcloud/version"
require "gcloud/backoff"
require "google/apis/storage_v1"
require "digest"
require "mime/types"
require "pathname"

module Gcloud
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
      def initialize project, credentials, retries: nil
        @project = project
        @credentials = credentials
        @credentials = credentials
        @service = API::StorageService.new
        @service.client_options.application_name    = "gcloud-ruby"
        @service.client_options.application_version = Gcloud::VERSION
        @service.request_options.retries = retries || 3
        @service.authorization = @credentials.client
      end

      def service
        return mocked_service if mocked_service
        @service
      end
      attr_accessor :mocked_service

      ##
      # Retrieves a list of buckets for the given project.
      def list_buckets prefix: nil, token: nil, max: nil
        service.list_buckets @project, prefix: prefix, page_token: token,
                                       max_results: max
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Retrieves bucket by name.
      # Returns Google::Apis::StorageV1::Bucket.
      def get_bucket bucket_name
        service.get_bucket bucket_name
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Creates a new bucket.
      # Returns Google::Apis::StorageV1::Bucket.
      def insert_bucket bucket_gapi, options = {}
        service.insert_bucket \
          @project, bucket_gapi,
          predefined_acl: options[:acl],
          predefined_default_object_acl: options[:default_acl]
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Updates a bucket, including its ACL metadata.
      def patch_bucket bucket_name, bucket_gapi = nil, predefined_acl: nil,
                       predefined_default_acl: nil
        bucket_gapi ||= Google::Apis::StorageV1::Bucket.new
        bucket_gapi.acl = nil if predefined_acl
        bucket_gapi.default_object_acl = nil if predefined_default_acl

        service.patch_bucket \
          bucket_name, bucket_gapi,
          predefined_acl: predefined_acl,
          predefined_default_object_acl: predefined_default_acl
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Permanently deletes an empty bucket.
      def delete_bucket bucket_name
        service.delete_bucket bucket_name
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Retrieves a list of ACLs for the given bucket.
      def list_bucket_acls bucket_name
        service.list_bucket_access_controls bucket_name
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Creates a new bucket ACL.
      def insert_bucket_acl bucket_name, entity, role
        new_acl = Google::Apis::StorageV1::BucketAccessControl.new \
          entity: entity, role: role
        service.insert_bucket_access_control bucket_name, new_acl
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Permanently deletes a bucket ACL.
      def delete_bucket_acl bucket_name, entity
        service.delete_bucket_access_control bucket_name, entity
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Retrieves a list of default ACLs for the given bucket.
      def list_default_acls bucket_name
        service.list_default_object_access_controls bucket_name
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Creates a new default ACL.
      def insert_default_acl bucket_name, entity, role
        new_acl = Google::Apis::StorageV1::ObjectAccessControl.new \
          entity: entity, role: role
        service.insert_default_object_access_control bucket_name, new_acl
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Permanently deletes a default ACL.
      def delete_default_acl bucket_name, entity
        service.delete_default_object_access_control bucket_name, entity
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Retrieves a list of files matching the criteria.
      def list_files bucket_name, options = {}
        service.list_objects \
          bucket_name, delimiter: options[:delimiter],
                       max_results: options[:max], page_token: options[:token],
                       prefix: options[:prefix], versions: options[:versions]
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Inserts a new file for the given bucket
      def insert_file bucket_name, source, path = nil, acl: nil,
                      cache_control: nil, content_disposition: nil,
                      content_encoding: nil, content_language: nil,
                      content_type: nil, crc32c: nil, md5: nil, metadata: nil,
                      key: nil, key_sha256: nil
        file_obj = Google::Apis::StorageV1::Object.new \
          cache_control: cache_control, content_type: content_type,
          content_disposition: content_disposition, md5_hash: md5,
          content_encoding: content_encoding, crc32c: crc32c,
          content_language: content_language, metadata: metadata
        content_type ||= mime_type_for(Pathname(source).to_path)
        service.insert_object \
          bucket_name, file_obj,
          name: path, predefined_acl: acl, upload_source: source,
          content_encoding: content_encoding, content_type: content_type,
          options: key_options(key: key, key_sha256: key_sha256)
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Retrieves an object or its metadata.
      def get_file bucket_name, file_path, generation: nil, key: nil,
                   key_sha256: nil
        service.get_object \
          bucket_name, file_path,
          generation: generation,
          options: key_options(key: key, key_sha256: key_sha256)
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ## Copy a file from source bucket/object to a
      # destination bucket/object.
      def copy_file source_bucket_name, source_file_path,
                    destination_bucket_name, destination_file_path, options = {}
        service.copy_object \
          source_bucket_name, source_file_path,
          destination_bucket_name, destination_file_path,
          destination_predefined_acl: options[:acl],
          source_generation: options[:generation],
          options: key_options(key: options[:key],
                               key_sha256: options[:key_sha256])
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Download contents of a file.
      def download_file bucket_name, file_path, target_path, generation: nil,
                        key: nil, key_sha256: nil
        service.get_object \
          bucket_name, file_path,
          download_dest: target_path, generation: generation,
          options: key_options(key: key, key_sha256: key_sha256)
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Updates a file's metadata.
      def patch_file bucket_name, file_path, file_gapi = nil,
                     predefined_acl: nil
        file_gapi ||= Google::Apis::StorageV1::Object.new
        service.patch_object \
          bucket_name, file_path, file_gapi,
          predefined_acl: predefined_acl
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Permanently deletes a file.
      def delete_file bucket_name, file_path
        service.delete_object bucket_name, file_path
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Retrieves a list of ACLs for the given file.
      def list_file_acls bucket_name, file_name
        service.list_object_access_controls bucket_name, file_name
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Creates a new file ACL.
      def insert_file_acl bucket_name, file_name, entity, role, options = {}
        new_acl = Google::Apis::StorageV1::ObjectAccessControl.new \
          entity: entity, role: role
        service.insert_object_access_control \
          bucket_name, file_name, new_acl, generation: options[:generation]
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Permanently deletes a file ACL.
      def delete_file_acl bucket_name, file_name, entity, options = {}
        service.delete_object_access_control \
          bucket_name, file_name, entity, generation: options[:generation]
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
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

      def key_options key: nil, key_sha256: nil
        options = {}
        if key
          headers = {}
          headers["x-goog-encryption-algorithm"] = "AES256"
          headers["x-goog-encryption-key"] = Base64.strict_encode64 key
          key_sha256 ||= Digest::SHA256.digest key
          headers["x-goog-encryption-key-sha256"] = \
            Base64.strict_encode64 key_sha256
          options[:header] = headers
        end
        options
      end

      def patch_bucket_request options = {}
        {
          "cors" => options[:cors],
          "logging" => logging_config(options),
          "versioning" => versioning_config(options[:versioning]),
          "website" => website_config(options),
          "acl" => options[:acl],
          "defaultObjectAcl" => options[:default_acl]
        }.delete_if { |_, v| v.nil? }
      end

      def versioning_config enabled
        { "enabled" => enabled } unless enabled.nil?
      end

      def logging_config options
        bucket = options[:logging_bucket]
        prefix = options[:logging_prefix]
        {
          log_bucket: bucket,
          log_object_prefix: prefix
        }.delete_if { |_, v| v.nil? } if bucket || prefix
      end

      def website_config options
        website_main = options[:website_main]
        website_404 = options[:website_404]
        {
          main_page_suffix: website_main,
          not_found_page: website_404
        }.delete_if { |_, v| v.nil? } if website_main || website_404
      end
    end
  end
end
