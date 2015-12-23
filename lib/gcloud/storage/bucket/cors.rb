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

require "delegate"

module Gcloud
  module Storage
    class Bucket
      ##
      # # Bucket Cors
      #
      # A special-case Array for managing the website CORS rules for a bucket.
      # Accessed via a block argument to {Project#create_bucket}, {Bucket#cors},
      # or {Bucket#update}.
      #
      # @see https://cloud.google.com/storage/docs/cross-origin Cross-Origin
      #   Resource Sharing (CORS)
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.cors do |c|
      #     # Remove the last CORS rule from the array
      #     c.pop
      #     # Remove all existing rules with the https protocol
      #     c.delete_if { |r| r["origin"].include? "http://example.com" }
      #     c.add_rule ["http://example.org", "https://example.org"],
      #                ["GET", "POST", "DELETE"],
      #                response_headers: ["X-My-Custom-Header"],
      #                max_age: 3600
      #   end
      #
      class Cors < DelegateClass(::Array)
        ##
        # @private
        # Initialize a new CORS rules builder with existing CORS rules, if any.
        def initialize cors = []
          super cors.dup
          @original = cors.dup
        end

        # @private
        def changed?
          @original != self
        end

        ##
        # Add a CORS rule to the CORS rules for a bucket. Accepts options for
        # setting preflight response headers. Preflight requests and responses
        # are required if the request method and headers are not both [simple
        # methods](http://www.w3.org/TR/cors/#simple-method) and [simple
        # headers](http://www.w3.org/TR/cors/#simple-header).
        #
        # @param [String, Array<String>] origin The
        #   [origin](http://tools.ietf.org/html/rfc6454) or origins permitted
        #   for cross origin resource sharing with the bucket. Note: "*" is
        #   permitted in the list of origins, and means "any Origin".
        # @param [String, Array<String>] methods The list of HTTP methods
        #   permitted in cross origin resource sharing with the bucket. (GET,
        #   OPTIONS, POST, etc) Note: "*" is permitted in the list of methods,
        #   and means "any method".
        # @param [String, Array<String>] headers The list of header field names
        #   to send in the Access-Control-Allow-Headers header in the preflight
        #   response. Indicates the custom request headers that may be used in
        #   the actual request.
        # @param [Integer] max_age The value to send in the
        #   Access-Control-Max-Age header in the preflight response. Indicates
        #   how many seconds the results of a preflight request can be cached in
        #   a preflight result cache. The default value is `1800` (30 minutes.)
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   storage = gcloud.storage
        #
        #   bucket = storage.create_bucket "my-bucket" do |c|
        #     c.add_rule ["http://example.org", "https://example.org"],
        #                "*",
        #                response_headers: ["X-My-Custom-Header"],
        #                max_age: 300
        #   end
        #
        def add_rule origin, methods, headers: nil, max_age: nil
          rule = { "origin" => Array(origin), "method" => Array(methods) }
          rule["responseHeader"] = Array(headers) || []
          rule["maxAgeSeconds"]  = max_age || 1800
          push rule
        end
      end
    end
  end
end
