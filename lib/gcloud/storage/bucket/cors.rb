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
      # = Bucket Cors
      #
      # Accumulates CORS rules to set on a bucket. See {Cross-Origin Resource
      # Sharing (CORS)}[https://cloud.google.com/storage/docs/cross-origin].
      class Cors
        attr_reader :cors #:nodoc:

        ##
        # Initialize a new CORS rules builder with existing CORS rules, if any.
        def initialize cors = [] #:nodoc:
          @original = cors.dup
          @cors = cors.dup
        end

        def changed? #:nodoc:
          @original != @cors
        end

        ##
        # Add a CORS rule to the CORS rules for a bucket. Accepts options for
        # setting preflight response headers. Preflight requests and responses
        # are required if the request method and headers are not both {simple
        # methods}[http://www.w3.org/TR/cors/#simple-method] and {simple
        # headers}[http://www.w3.org/TR/cors/#simple-header].
        #
        # === Parameters
        #
        # +origin+::
        #   The {origin}[http://tools.ietf.org/html/rfc6454] or origins
        #   permitted for cross origin resource sharing with the bucket. Note:
        #   "*" is permitted in the list of origins, and means "any Origin".
        #   (+String+ or +Array+)
        # +methods+::
        #   The list of HTTP methods permitted in cross origin resource sharing
        #   with the bucket. (GET, OPTIONS, POST, etc) Note: "*" is permitted in
        #   the list of methods, and means "any method". (+String+ or +Array+)
        # +options+::
        #   An optional Hash for controlling additional behavior. (+Hash+)
        # <code>options[:headers]</code>::
        #   The list of header field names to send in the
        #   Access-Control-Allow-Headers header in the preflight response.
        #   Indicates the custom request headers that may be used in the actual
        #   request. (+String+ or +Array+)
        # <code>options[:max_age]</code>::
        #   The value to send in the Access-Control-Max-Age header in the
        #   preflight response. Indicates how many seconds the results of a
        #   preflight request can be cached in a preflight result cache. The
        #   default value is +1800+ (30 minutes.) (+Integer+)
        #
        # === Example
        #
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   storage = gcloud.storage
        #   bucket = storage.bucket "my-todo-app"
        #
        #   bucket.update do |b|
        #     b.cors do |c|
        #       c.add_rule ["http://example.org", "https://example.org"],
        #                  "*",
        #                  response_headers: ["X-My-Custom-Header"],
        #                  max_age: 300
        #     end
        #   end
        #
        def add_rule origin, methods, options = {}
          rule = { "origin" => Array(origin), "method" => Array(methods) }
          rule["responseHeader"] = Array(options[:headers]) || []
          rule["maxAgeSeconds"] = options[:max_age] || 1800
          @cors << rule
        end
      end
    end
  end
end
