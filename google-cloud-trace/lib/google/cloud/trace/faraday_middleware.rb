# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
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

            add_response_labels span, env if span

            response
          end
        end

        protected

        ##
        # @private Set Trace span labels from request object
        def add_request_labels span, env
          labels = span.labels
          label_keys = Google::Cloud::Trace::LabelKey

          set_label labels, label_keys::HTTP_METHOD, env.method
          set_label labels, label_keys::HTTP_URL, env.url.to_s

          # Only sets request size if request is not sent yet.
          unless env.status
            request_body = env.body || ""
            set_label labels, label_keys::RPC_REQUEST_SIZE,
                      request_body.bytesize.to_s
          end
        end

        ##
        # @private Set Trace span labels from response
        def add_response_labels span, env
          labels = span.labels
          label_keys = Google::Cloud::Trace::LabelKey

          response = env.response
          response_body = response.body || ""
          response_status = response.status
          response_url = response.headers[:location]

          set_label labels, label_keys::RPC_RESPONSE_SIZE,
                    response_body.bytesize.to_s
          set_label labels, label_keys::HTTP_STATUS_CODE, response_status.to_s

          if response_status >= 300 && response_status < 400 && response_url
            set_label labels, label_keys::HTTP_REDIRECTED_URL, response_url
          end
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
