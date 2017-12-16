# Copyright 2016 Google LLC
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


module Google
  module Cloud
    module Logging
      class Entry
        ##
        # # Http Request
        #
        # HTTP request data associated with a log entry.
        #
        # See also {Google::Cloud::Logging::Entry#http_request}.
        #
        class HttpRequest
          ##
          # @private Create an empty HttpRequest object.
          def initialize
          end

          ##
          # The request method. Examples: `"GET"`, `"HEAD"`, `"PUT"`, `"POST"`.
          # (String)
          attr_accessor :request_method

          ##
          # @overload method()
          #   Deprecated. Use {#request_method} instead.
          #
          #   The request method. Examples: `"GET"`, `"HEAD"`, `"PUT"`,
          #   `"POST"`. (String)
          def method *args
            # Call Object#method when args are present.
            return super unless args.empty?

            request_method
          end

          ##
          # @overload method()
          #   Deprecated. Use {#request_method=} instead.
          #
          #   The request method. Examples: `"GET"`, `"HEAD"`, `"PUT"`,
          #   `"POST"`. (String)
          def method= new_request_method
            self.request_method = new_request_method
          end

          ##
          # The URL. The scheme (http, https), the host name, the path and the
          # query portion of the URL that was requested. Example:
          # `"http://example.com/some/info?color=red"`. (String)
          attr_accessor :url

          ##
          # The size of the HTTP request message in bytes, including the request
          # headers and the request body. (Integer)
          attr_accessor :size

          ##
          # The response code indicating the status of response. Examples:
          # `200`, `404`. (Integer)
          attr_accessor :status

          ##
          # The size of the HTTP response message sent back to the client, in
          # bytes, including the response headers and the response body.
          # (Integer)
          attr_accessor :response_size

          ##
          # The user agent sent by the client. Example: `"Mozilla/4.0
          # (compatible; MSIE 6.0; Windows 98; Q312461; .NET CLR 1.0.3705)"`.
          # (String)
          attr_accessor :user_agent

          ##
          # The IP address (IPv4 or IPv6) of the client that issued the HTTP
          # request. Examples: `"192.168.1.1"`, `"FE80::0202:B3FF:FE1E:8329"`.
          # (String)
          attr_accessor :remote_ip

          ##
          # The referer URL of the request, as defined in [HTTP/1.1 Header Field
          # Definitions](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html).
          # (String)
          attr_accessor :referer

          ##
          # Whether an entity was served from cache (with or without
          # validation). (Boolean)
          attr_accessor :cache_hit

          ##
          # Whether the response was validated with the origin server before
          # being served from cache. This field is only meaningful if
          # `cache_hit` is `true`. (Boolean)
          attr_accessor :validated

          ##
          # @private Determines if the HttpRequest has any data.
          def empty?
            method.nil? &&
              url.nil? &&
              size.nil? &&
              status.nil? &&
              response_size.nil? &&
              user_agent.nil? &&
              remote_ip.nil? &&
              referer.nil? &&
              cache_hit.nil? &&
              validated.nil?
          end

          ##
          # @private Exports the HttpRequest to a
          # Google::Logging::Type::HttpRequest object.
          def to_grpc
            return nil if empty?
            Google::Logging::Type::HttpRequest.new(
              request_method:                     request_method.to_s,
              request_url:                        url.to_s,
              request_size:                       size.to_i,
              status:                             status.to_i,
              response_size:                      response_size.to_i,
              user_agent:                         user_agent.to_s,
              remote_ip:                          remote_ip.to_s,
              referer:                            referer.to_s,
              cache_hit:                          !(!cache_hit),
              cache_validated_with_origin_server: !(!validated)
            )
          end

          ##
          # @private New HttpRequest from a Google::Logging::Type::HttpRequest
          # object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |h|
              h.request_method = grpc.request_method
              h.url            = grpc.request_url
              h.size           = grpc.request_size
              h.status         = grpc.status
              h.response_size  = grpc.response_size
              h.user_agent     = grpc.user_agent
              h.remote_ip      = grpc.remote_ip
              h.referer        = grpc.referer
              h.cache_hit      = grpc.cache_hit
              h.validated      = grpc.cache_validated_with_origin_server
            end
          end
        end
      end
    end
  end
end
