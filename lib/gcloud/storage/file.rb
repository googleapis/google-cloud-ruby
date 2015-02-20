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

require "gcloud/storage/file/acl"
require "gcloud/storage/file/list"
require "gcloud/storage/file/verifier"

module Gcloud
  module Storage
    ##
    # Represents the File/Object that belong to a Bucket.
    class File
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty File object.
      def initialize
        @connection = nil
        @gapi = {}
      end

      ##
      # The kind of item this is.
      # For files, this is always storage#object.
      def kind
        @gapi["kind"]
      end

      ##
      # The ID of the file.
      def id
        @gapi["id"]
      end

      ##
      # The name of this file.
      def name
        @gapi["name"]
      end

      ##
      # The name of the bucket containing this file.
      def bucket
        @gapi["bucket"]
      end

      ##
      # The content generation of this file.
      # Used for object versioning.
      def generation
        @gapi["generation"]
      end

      ##
      # The version of the metadata for this file at this generation.
      # Used for preconditions and for detecting changes in metadata.
      # A metageneration number is only meaningful in the context of a
      # particular generation of a particular file.
      def metageneration
        @gapi["metageneration"]
      end

      ##
      # The url to the file.
      def url
        @gapi["selfLink"]
      end

      ##
      # Content-Length of the data in bytes.
      def size
        @gapi["size"]
      end

      ##
      # The creation or modification time of the file.
      # For buckets with versioning enabled, changing an object's
      # metadata does not change this property.
      def updated_at
        @gapi["updated"]
      end

      ##
      # MD5 hash of the data; encoded using base64.
      def md5
        @gapi["md5Hash"]
      end

      ##
      # CRC32c checksum, as described in RFC 4960, Appendix B;
      # encoded using base64.
      def crc32c
        @gapi["crc32c"]
      end

      ##
      # HTTP 1.1 Entity tag for the file.
      def etag
        @gapi["etag"]
      end

      ##
      # Download the file's contents to a local file.
      # The path provided must be writable.
      #
      #   file.download "path/to/downloaded/file.ext"
      #
      # The download is verified by calculating the MD5 digest.
      # The CRC32c digest can be used by passing :crc32c.
      #
      #   file.download "path/to/downloaded/file.ext", verify: :crc32c
      #
      # Both the MD5 and CRC32c digest can be used by passing :all.
      #
      #   file.download "path/to/downloaded/file.ext", verify: :all
      #
      # The download verification can be disabled by passing :none
      #
      #   file.download "path/to/downloaded/file.ext", verify: :none
      #
      # If the verification fails FileVerificationError is raised.
      def download path, options = {}
        ensure_connection!
        resp = connection.download_file bucket, name
        if resp.success?
          ::File.open path, "w+" do |f|
            f.write resp.body
          end
          verify_file! ::File.new(path), options
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Copy the file to a new location.
      #
      #   file.copy "path/to/destination/file.ext"
      #
      # The file can also be copied to a different bucket:
      #
      #   file.copy "new-destination-bucket",
      #             "path/to/destination/file.ext"
      def copy dest_bucket_or_path, dest_path = nil, options = {}
        ensure_connection!
        dest_bucket, dest_path, options = fix_copy_args dest_bucket_or_path,
                                                        dest_path, options

        resp = connection.copy_file bucket, name,
                                    dest_bucket, dest_path,
                                    options
        if resp.success?
          File.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Permenently deletes the file.
      def delete
        ensure_connection!
        resp = connection.delete_file bucket, name
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      def signed_url options = {}
        ensure_connection!
        signer = File::Signer.new self
        signer.signed_url options
      end

      ##
      # Access Control List
      def acl
        @acl ||= File::Acl.new self
      end

      ##
      # New File from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      def fix_copy_args dest_bucket_or_path, dest_path, options = {}
        if dest_path.respond_to?(:to_hash) && options.empty?
          options = dest_path
          dest_path = nil
        end
        if dest_path.nil?
          dest_path = dest_bucket_or_path
          dest_bucket_or_path = bucket
        end
        if dest_bucket_or_path.respond_to? :name
          dest_bucket_or_path = dest_bucket_or_path.name
        end
        options[:acl] = File::Acl.predefined_rule_for options[:acl]
        [dest_bucket_or_path, dest_path, options]
      end

      def verify_file! file, options = {}
        verify = options[:verify] || :md5
        verify_md5    = verify == :md5    || verify == :all
        verify_crc32c = verify == :crc32c || verify == :all
        Verifier.verify_md5! self, file    if verify_md5
        Verifier.verify_crc32c! self, file if verify_crc32c
        file
      end

      ##
      # Create a signed_url for a file.
      class Signer #:nodoc
        def initialize file
          @file = file
        end

        ##
        # The external path to the file.
        def ext_path
          "/#{@file.bucket}/#{@file.name}"
        end

        ##
        # The external url to the file.
        def ext_url
          "https://storage.googleapis.com#{ext_path}"
        end

        def apply_option_defaults options
          adjusted_expires = (Time.now.utc + (options[:expires] || 300)).to_i
          options[:expires] = adjusted_expires
          options[:method]  ||= "GET"
          options
        end

        def signature_str options
          [options[:method], options[:content_md5],
           options[:content_type], options[:expires],
           ext_path].join "\n"
        end

        def signing_key
          @file.connection.credentials.signing_key
        end

        def issuer
          @file.connection.credentials.issuer
        end

        def signed_url options
          options = apply_option_defaults options
          signed_string = signing_key.sign OpenSSL::Digest::SHA256.new,
                                           signature_str(options)
          signature = Base64.encode64(signed_string).gsub("\n", "")
          "#{ext_url}?GoogleAccessId=#{CGI.escape issuer}" \
                    "&Expires=#{options[:expires]}" \
                    "&Signature=#{CGI.escape signature}"
        end
      end
    end
  end
end
