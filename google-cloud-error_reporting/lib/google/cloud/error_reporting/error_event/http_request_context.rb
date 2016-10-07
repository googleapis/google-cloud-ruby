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


module Google
  module Cloud
    module ErrorReporting
      class ErrorEvent
        ##
        # HttpRequestContext
        #
        # Rrepresent Google::Devtools::Clouderrorreporting::V1beta1::HttpRequestContext
        # class. The location in the source code where the decision was made to
        # report the error, usually the place where it was logged. For a logged
        # exception this would be the source line where the exception is logged,
        # usually close to the place where it was caught. This value is in
        # contrast to Exception.cause_location, which describes the source line
        # where the exception was thrown.
        #
        class HttpRequestContext
          ##
          # Construct an empty instance
          def initialize
          end

          ##
          # String. The type of HTTP request, such as GET, POST, etc.
          attr_accessor :method

          ##
          # String. The URL of the request.
          attr_accessor :url

          ##
          # String. The user agent information that is provided with the request.
          attr_accessor :user_agent

          ##
          # String. The IP address from which the request originated. This can be
          # IPv4, IPv6, or a token which is derived from the IP address, depending
          # on the data that has been provided in the error report.
          attr_accessor :remote_ip

          ##
          # String. The referrer information that is provided with the request.
          attr_accessor :referrer

          ##
          # Number. The HTTP response status code for the request.
          attr_accessor :status

          ##
          # Determines if the HttpRequestContext has any data
          def empty?
            method.nil? &&
              url.nil? &&
              user_agent.nil? &&
              remote_ip.nil? &&
              referrer.nil? &&
              status.nil?
          end

          ##
          # Exports the HttpRequestContext to a
          # Google::Devtools::Clouderrorreporting::V1beta1::HttpRequestContext
          # object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouderrorreporting::V1beta1::HttpRequestContext.new(
              method:               method.to_s,
              url:                  url.to_s,
              response_status_code: status.to_i,
              user_agent:           user_agent.to_s,
              referrer:             referrer.to_s,
              remote_ip:            remote_ip.to_s
            )
          end

          ##
          # New HttpRequestContext from a
          # Google::Devtools::Clouderrorreporting::V1beta1::HttpRequestContext
          # object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |h|
              h.method     = grpc.to_hash[:method]
              h.url        = grpc.url
              h.status     = grpc.response_status_code
              h.user_agent = grpc.user_agent
              h.referrer   = grpc.referrer
              h.remote_ip  = grpc.remote_ip
            end
          end
        end
      end
    end
  end
end
