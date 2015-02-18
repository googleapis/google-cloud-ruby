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
      def insert_bucket bucket_name, opts = {}
        incremental_backoff opts do
          @client.execute(
            api_method: @storage.buckets.insert,
            parameters: { project: @project },
            body_object: { name: bucket_name }
          )
        end
      end

      ##
      # Permenently deletes an empty bucket.
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
      # Permenently deletes a bucket ACL.
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
      # Permenently deletes a default ACL.
      def delete_default_acl bucket_name, entity
        @client.execute(
          api_method: @storage.default_object_access_controls.delete,
          parameters: { bucket: bucket_name, entity: entity }
        )
      end

      ##
      # Retrieves a list of files matching the criteria.
      def list_files bucket_name
        @client.execute(
          api_method: @storage.objects.list,
          parameters: { bucket: bucket_name }
        )
      end

      # rubocop:disable Metrics/MethodLength
      # Disabled rubocop because the API we need to use
      # is verbose. No getting around it.

      ##
      # Stores a new object and metadata.
      # Uses a multipart form post.
      def insert_file_multipart bucket_name, file, path = nil
        local_path = Pathname(file).to_path
        upload_path = Pathname(path || local_path).to_path
        mime_type = mime_type_for local_path

        media = Google::APIClient::UploadIO.new local_path, mime_type

        @client.execute(
          api_method: @storage.objects.insert,
          media: media,
          parameters: {
            uploadType: "multipart",
            bucket: bucket_name,
            name: upload_path
          },
          body_object: { contentType: mime_type }
        )
      end

      ##
      # Stores a new object and metadata.
      # Uses a resumable upload.
      def insert_file_resumable bucket_name, file, path = nil, chunk_size = nil
        local_path = Pathname(file).to_path
        upload_path = Pathname(path || local_path).to_path
        # mime_type = options[:mime_type] || mime_type_for local_path
        mime_type = mime_type_for local_path

        # This comes from Faraday, which gets it from multipart-post
        # The signature is:
        # filename_or_io, content_type, filename = nil, opts = {}

        media = Google::APIClient::UploadIO.new local_path, mime_type
        media.chunk_size = chunk_size

        result = @client.execute(
          api_method: @storage.objects.insert,
          media: media,
          parameters: {
            uploadType: "resumable",
            bucket: bucket_name,
            name: upload_path
          },
          body_object: { contentType: mime_type }
        )
        upload = result.resumable_upload
        result = @client.execute upload while upload.resumable?
        result
      end

      # rubocop:enable Metrics/MethodLength

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
                    destination_bucket_name, destination_file_path
        @client.execute(
          api_method: @storage.objects.copy,
          parameters: { sourceBucket: source_bucket_name,
                        sourceObject: source_file_path,
                        destinationBucket: destination_bucket_name,
                        destinationObject: destination_file_path }
        )
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
      # Permenently deletes a file.
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
      # Permenently deletes a file ACL.
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

      protected

      def incremental_backoff options = {}
        Gcloud::Backoff.new(options).execute do
          yield
        end
      end
    end
  end
end
