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
    class Bucket
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Bucket object.
      def initialize
        @connection = nil
        @gapi = {}
      end

      ##
      # The kind of item this is.
      # For buckets, this is always storage#bucket.
      def kind
        @gapi["kind"]
      end

      ##
      # The ID of the bucket.
      def id
        @gapi["id"]
      end

      ##
      # The name of the bucket.
      def name
        @gapi["name"]
      end

      ##
      # The URI of this bucket.
      def url
        @gapi["selfLink"]
      end

      ##
      # The location of the bucket.
      # Object data for objects in the bucket resides in physical
      # storage within this region. Defaults to US.
      # See the developer's guide for the authoritative list.
      def location
        @gapi["location"]
      end

      ##
      # Creation time of the bucket.
      def created_at
        @gapi["timeCreated"]
      end

      ##
      # Permenently deletes the bucket.
      # The bucket must be empty.
      def delete
        ensure_connection!
        resp = connection.delete_bucket name
        if resp.success?
          true
        else
          ApiError.from_response(resp)
        end
      end

      ##
      # New Bucket from a Google API Client object.
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
    end
  end
end
