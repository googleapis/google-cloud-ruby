# Copyright 2016 Google Inc. All rights reserved.
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
  module Logging
    class Entry
      ##
      # # Http Request
      #
      # HTTP request data associated with a log entry.
      #
      class HttpRequest
        ##
        # @private Create an empty HttpRequest object.
        def initialize
        end

        ##
        # The request method. Examples: "GET", "HEAD", "PUT", "POST".
        attr_accessor :method

        ##
        # The scheme (http, https), the host name, the path and the query
        # portion of the URL that was requested. Example:
        # "http://example.com/some/info?color=red".
        attr_accessor :url

        ##
        # The size of the HTTP request message in bytes, including the request
        # headers and the request body.
        attr_accessor :size

        ##
        # The response code indicating the status of response. Examples: 200,
        # 404.
        attr_accessor :status

        ##
        # The size of the HTTP response message sent back to the client, in
        # bytes, including the response headers and the response body.
        attr_accessor :response_size

        ##
        # The user agent sent by the client. Example: "Mozilla/4.0 (compatible;
        # MSIE 6.0; Windows 98; Q312461; .NET CLR 1.0.3705)".
        attr_accessor :user_agent

        ##
        # The IP address (IPv4 or IPv6) of the client that issued the HTTP
        # request. Examples: "192.168.1.1", "FE80::0202:B3FF:FE1E:8329".
        attr_accessor :remote_ip

        ##
        # The referer URL of the request, as defined in [HTTP/1.1 Header Field
        # Definitions](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html).
        attr_accessor :referer

        ##
        # Whether or not an entity was served from cache (with or without
        # validation).
        attr_accessor :cache_hit

        ##
        # Whether or not the response was validated with the origin server
        # before being served from cache. This field is only meaningful if
        # cache_hit is `true`.
        attr_accessor :validated

        ##
        # @private Exports the HttpRequest to a Google API Client object.
        def to_gapi
          {
            "requestMethod" => method,
            "requestUrl" => url,
            "requestSize" => size,
            "status" => status,
            "responseSize" => response_size,
            "userAgent" => user_agent,
            "remoteIp" => remote_ip,
            "referer" => referer,
            "cacheHit" => cache_hit,
            "validatedWithOriginServer" => validated
          }.delete_if { |_, v| v.nil? }
        end

        ##
        # @private Determines if the HttpRequest has any data.
        def empty?
          to_gapi.empty?
        end

        ##
        # @private New HttpRequest from a Google API Client object.
        def self.from_gapi gapi
          gapi ||= {}
          gapi = gapi.to_hash if gapi.respond_to? :to_hash
          new.tap do |h|
            h.method        = gapi["requestMethod"]
            h.url           = gapi["requestUrl"]
            h.size          = gapi["requestSize"]
            h.status        = gapi["status"]
            h.response_size = gapi["responseSize"]
            h.user_agent    = gapi["userAgent"]
            h.remote_ip     = gapi["remoteIp"]
            h.referer       = gapi["referer"]
            h.cache_hit     = gapi["cacheHit"]
            h.validated     = gapi["validatedWithOriginServer"]
          end
        end
      end
    end
  end
end
