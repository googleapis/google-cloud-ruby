# Copyright 2017 Google Inc. All rights reserved.
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


require "faraday"
require "google/cloud/trace"

module Google
  module Cloud
    module Trace
      class FaradayMiddleware < Faraday::Middleware
        ##
        # Create a Trace span with the HTTP request/response information.
        def call env
          Google::Cloud::Trace.in_span "faraday_request" do |span|
            add_request_labels span, env if span

            response = @app.call env

            add_response_labels span, response if span

            response
          end
        end

        protected

        ##
        # @private Set Trace span labels from request object
        def add_request_labels span, env
          labels = span.labels
          label_keys = Google::Cloud::Trace::LabelKey

          set_label labels, label_keys::AGENT,
                    Google::Cloud::Trace::Middleware::AGENT_NAME
          set_label labels, label_keys::HTTP_HOST, env.url.host
          set_label labels, label_keys::HTTP_METHOD, env.method
          set_label labels, label_keys::HTTP_CLIENT_PROTOCOL, env.url.scheme
          set_label labels, label_keys::HTTP_USER_AGENT,
                    env.request_headers[:user_agent]
          set_label labels, label_keys::HTTP_URL, env.url.to_s
          set_label labels, label_keys::PID, ::Process.pid.to_s
          set_label labels, label_keys::TID, ::Thread.current.object_id.to_s
        end

        ##
        # @private Set Trace span labels from response
        def add_response_labels span, response
          set_label span.labels,
                    Google::Cloud::Trace::LabelKey::HTTP_STATUS_CODE,
                    response.status.to_s
        end

        ##
        # Sets the given label if the given value is a proper string.
        #
        # @private
        # @param [Hash] labels The labels hash.
        # @param [String] key The key of the label to set.
        # @param [Object] value The value to set.
        #
        def set_label labels, key, value
          labels[key] = value if value.is_a? ::String
        end
      end
    end
  end
end
