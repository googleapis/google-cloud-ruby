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
      # Accessed via {Bucket#cors}.
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
      #   bucket = storage.bucket "my-bucket"
      #   bucket.cors do |c|
      #     # Remove the last CORS rule from the array
      #     c.pop
      #     # Remove all existing rules with the https protocol
      #     c.delete_if { |r| r.origin.include? "http://example.com" }
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
        def initialize rules = []
          super rules
          @original = rules.dup
        end

        # @private
        def changed?
          @original.to_json != to_json
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
          push Rule.new(origin, methods, headers: headers, max_age: max_age)
        end

        def to_gapi
          map(&:to_gapi)
        end

        def self.from_gapi gapi_list
          rules = Array(gapi_list).map { |gapi| Rule.from_gapi gapi }
          new rules
        end

        def freeze
          each(&:freeze)
          super
        end

        class Rule
          def initialize origin, methods, headers: nil, max_age: nil
            @gapi = Google::Apis::StorageV1::Bucket::CorsConfiguration.new(
              origin: Array(origin), http_method: Array(methods),
              response_header: Array(headers), max_age_seconds: (max_age||1800)
            )
          end

          def origin
            @gapi.origin
          end

          def origin= new_origin
            @gapi.origin = Array(new_origin)
          end

          def methods
            @gapi.http_method
          end

          def methods= new_methods
            @gapi.http_method = Array(new_methods)
          end

          def headers
            @gapi.response_header
          end

          def headers= new_headers
            @gapi.response_header = Array(new_headers)
          end

          def max_age
            @gapi.max_age_seconds
          end

          def max_age= new_max_age
            @gapi.max_age_seconds = (new_max_age || 1800)
          end

          def to_gapi
            @gapi
          end

          def self.from_gapi gapi
            new gapi.origin, gapi.http_method, \
                headers: gapi.response_header, max_age: gapi.max_age_seconds
          end

          def freeze
            @gapi.freeze
            super
          end
        end
      end
    end
  end
end
