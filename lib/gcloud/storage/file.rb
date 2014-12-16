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

module Gcloud
  module Storage
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
      # New File from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end
    end
  end
end
