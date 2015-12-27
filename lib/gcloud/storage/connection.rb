#--
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

require "pathname"
require "gcloud/version"
require "gcloud/backoff"
require "google/api_client"
require "mime/types"

module Gcloud
  module Storage
    ##
    # Represents the connection to Storage,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v1"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @storage = @client.discovered_api "storage", API_VERSION
      end

      ##
      # Retrieves a list of buckets for the given project.
      def list_buckets options = {}
        params = { project: @project }
        params["prefix"]     = options[:prefix] if options[:prefix]
        params["pageToken"]  = options[:token]  if options[:token]
        params["maxResults"] = options[:max]    if options[:max]

        @client.execute(
          api_method: @storage.buckets.list,
          parameters: params
        )
      end

      ##
      # Retrieves bucket by name.
      def get_bucket bucket_name
        @client.execute(
          api_method: @storage.buckets.get,
          parameters: { bucket: bucket_name }
        )
      end

      ##
      # Creates a new bucket.
      def insert_bucket bucket_name, options = {}
        params = { project: @project, predefinedAcl: options[:acl],
                   predefinedDefaultObjectAcl: options[:default_acl]
                 }.delete_if { |_, v| v.nil? }

        incremental_backoff options do
          @client.execute(
            api_method: @storage.buckets.insert,
            parameters: params,
            body_object: insert_bucket_request(bucket_name, options)
          )
        end
      end

      ##
      # Updates a bucket, including its ACL metadata.
      def patch_bucket bucket_name, options = {}
        params = { bucket: bucket_name,
                   predefinedAcl: options[:predefined_acl],
                   predefinedDefaultObjectAcl: options[:predefined_default_acl]
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @storage.buckets.patch,
          parameters: params,
          body_object: patch_bucket_request(options)
        )
      end

      ##
      # Permanently deletes an empty bucket.
      def delete_bucket bucket_name, opts = {}
        incremental_backoff opts do
          @client.execute(
            api_method: @storage.buckets.delete,
            parameters: { bucket: bucket_name }
          )
        end
      end

      ##
      # Retrieves a list of ACLs for the given bucket.
      def list_bucket_acls bucket_name
        @client.execute(
          api_method: @storage.bucket_access_controls.list,
          parameters: { bucket: bucket_name }
        )
      end

      ##
      # Creates a new bucket ACL.
      def insert_bucket_acl bucket_name, entity, role
        @client.execute(
          api_method: @storage.bucket_access_controls.insert,
          parameters: { bucket: bucket_name },
          body_object: { entity: entity, role: role }
        )
      end

      ##
      # Permanently deletes a bucket ACL.
      def delete_bucket_acl bucket_name, entity
        @client.execute(
          api_method: @storage.bucket_access_controls.delete,
          parameters: { bucket: bucket_name, entity: entity }
        )
      end

      ##
      # Retrieves a list of default ACLs for the given bucket.
      def list_default_acls bucket_name
        @client.execute(
          api_method: @storage.default_object_access_controls.list,
          parameters: { bucket: bucket_name }
        )
      end

      ##
      # Creates a new default ACL.
      def insert_default_acl bucket_name, entity, role
        @client.execute(
          api_method: @storage.default_object_access_controls.insert,
          parameters: { bucket: bucket_name },
          body_object: { entity: entity, role: role }
        )
      end

      ##
      # Permanently deletes a default ACL.
      def delete_default_acl bucket_name, entity
        @client.execute(
          api_method: @storage.default_object_access_controls.delete,
          parameters: { bucket: bucket_name, entity: entity }
        )
      end

      ##
      # Retrieves a list of files matching the criteria.
      def list_files bucket_name, options = {}
        params = {
          bucket:        bucket_name,
          prefix:          options[:prefix],
          delimiter:     options[:delimiter],
          pageToken:  options[:token],
          maxResults: options[:max],
          versions:      options[:versions]
        }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @storage.objects.list,
          parameters: params
        )
      end

      ##
      # Stores a new object and metadata. If resumable is true, a resumable
      # upload, otherwise uses a multipart form post.
      #
      # UploadIO comes from Faraday, which gets it from multipart-post
      # The initializer signature is:
      # filename_or_io, content_type, filename = nil, opts = {}
      def upload_file resumable, bucket_name, file, path = nil, options = {}
        local_path = Pathname(file).to_path
        options[:content_type] ||= mime_type_for(local_path)
        media = file_media local_path, options, resumable
        upload_path = Pathname(path || local_path).to_path
        result = insert_file resumable, bucket_name, upload_path, media, options
        return result unless resumable
        upload = result.resumable_upload
        result = @client.execute upload while upload.resumable?
        result
      end

      ##
      # Retrieves an object or its metadata.
      def get_file bucket_name, file_path, options = {}
        query = { bucket: bucket_name, object: file_path }
        query[:generation] = options[:generation] if options[:generation]

        @client.execute(
          api_method: @storage.objects.get,
          parameters: query
        )
      end

      ## Copy a file from source bucket/object to a
      # destination bucket/object.
      def copy_file source_bucket_name, source_file_path,
                    destination_bucket_name, destination_file_path, options = {}
        @client.execute(
          api_method: @storage.objects.copy,
          parameters: { sourceBucket: source_bucket_name,
                        sourceObject: source_file_path,
                        sourceGeneration: options[:generation],
                        destinationBucket: destination_bucket_name,
                        destinationObject: destination_file_path,
                        predefinedAcl: options[:acl]
                      }.delete_if { |_, v| v.nil? })
      end

      ##
      # Download contents of a file.
      def download_file bucket_name, file_path
        @client.execute(
          api_method: @storage.objects.get,
          parameters: { bucket: bucket_name,
                        object: file_path,
                        alt: :media }
        )
      end

      ##
      # Updates a file's metadata.
      def patch_file bucket_name, file_path, options = {}
        params = { bucket: bucket_name,
                   object: file_path,
                   predefinedAcl: options[:predefined_acl]
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @storage.objects.patch,
          parameters: params,
          body_object: patch_file_request(options)
        )
      end

      ##
      # Permanently deletes a file.
      def delete_file bucket_name, file_path
        @client.execute(
          api_method: @storage.objects.delete,
          parameters: { bucket: bucket_name,
                        object: file_path }
        )
      end

      ##
      # Retrieves a list of ACLs for the given file.
      def list_file_acls bucket_name, file_name
        @client.execute(
          api_method: @storage.object_access_controls.list,
          parameters: { bucket: bucket_name, object: file_name }
        )
      end

      ##
      # Creates a new file ACL.
      def insert_file_acl bucket_name, file_name, entity, role, options = {}
        query = { bucket: bucket_name, object: file_name }
        query[:generation] = options[:generation] if options[:generation]

        @client.execute(
          api_method: @storage.object_access_controls.insert,
          parameters: query,
          body_object: { entity: entity, role: role }
        )
      end

      ##
      # Permanently deletes a file ACL.
      def delete_file_acl bucket_name, file_name, entity, options = {}
        query = { bucket: bucket_name, object: file_name, entity: entity }
        query[:generation] = options[:generation] if options[:generation]

        @client.execute(
          api_method: @storage.object_access_controls.delete,
          parameters: query
        )
      end

      ##
      # Retrieves the mime-type for a file path.
      # An empty string is returned if no mime-type can be found.
      def mime_type_for path
        MIME::Types.of(path).first.to_s
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end

      protected

      def insert_bucket_request name, options = {}
        {
          "name" => name,
          "location" => options[:location],
          "cors" => options[:cors],
          "logging" => logging_config(options),
          "storageClass" => storage_class(options[:storage_class]),
          "versioning" => versioning_config(options[:versioning]),
          "website" => website_config(options)
        }.delete_if { |_, v| v.nil? }
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
          "logBucket" => bucket,
          "logObjectPrefix" => prefix
        }.delete_if { |_, v| v.nil? } if bucket || prefix
      end

      def website_config options
        website_main = options[:website_main]
        website_404 = options[:website_404]
        {
          "mainPageSuffix" => website_main,
          "notFoundPage" => website_404
        }.delete_if { |_, v| v.nil? } if website_main || website_404
      end

      def storage_class str #:nodoc:
        { "durable_reduced_availability" => "DURABLE_REDUCED_AVAILABILITY",
          "dra" => "DURABLE_REDUCED_AVAILABILITY",
          "durable" => "DURABLE_REDUCED_AVAILABILITY",
          "nearline" => "NEARLINE",
          "standard" => "STANDARD" }[str.to_s.downcase]
      end

      def insert_file resumable, bucket_name, path, media, options
        params = { uploadType: (resumable ? "resumable" : "multipart"),
                   bucket: bucket_name,
                   name: path,
                   predefinedAcl: options[:acl]
        }.delete_if { |_, v| v.nil? }

        @client.execute api_method: @storage.objects.insert,
                        media: media,
                        parameters: params,
                        body_object: insert_file_request(options)
      end

      def file_media local_path, options, resumable
        media = Google::APIClient::UploadIO.new local_path,
                                                options[:content_type]
        return media unless resumable && options[:chunk_size]
        media.chunk_size = verify_chunk_size!(options.delete(:chunk_size))
        media
      end

      def insert_file_request options = {}
        request = {
          "crc32c" => options[:crc32c],
          "md5Hash" => options[:md5],
          "metadata" => options[:metadata]
        }.delete_if { |_, v| v.nil? }
        request.merge patch_file_request(options)
      end

      def patch_file_request options = {}
        {
          "cacheControl" => options[:cache_control],
          "contentDisposition" => options[:content_disposition],
          "contentEncoding" => options[:content_encoding],
          "contentLanguage" => options[:content_language],
          "contentType" => options[:content_type],
          "metadata" => options[:metadata],
          "acl" => options[:acl]
        }.delete_if { |_, v| v.nil? }
      end

      def incremental_backoff options = {}
        Gcloud::Backoff.new(options).execute do
          yield
        end
      end

      ##
      # Determines if a chunk_size is valid.
      def verify_chunk_size! chunk_size
        chunk_size = chunk_size.to_i
        chunk_mod = 256 * 1024 # 256KB
        if (chunk_size.to_i % chunk_mod) != 0
          chunk_size = (chunk_size / chunk_mod) * chunk_mod
        end
        return if chunk_size.zero?
        chunk_size
      end
    end
  end
end
