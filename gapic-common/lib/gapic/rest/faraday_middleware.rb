# Copyright 2021 Google LLC
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

module Gapic
  module Rest
    # Registers the middleware with Faraday
    module FaradayMiddleware
      ##
      # Request middleware that constructs the Authorization HTTP header
      # using ::Google::Auth::Credentials
      #
      class GoogleAuthorization < Faraday::Middleware
        ##
        # @param app [#call]
        # @param credentials [::Google::Auth::Credentials]
        def initialize app, credentials
          @credentials = credentials
          super app
        end

        # @param env [Faraday::Env]
        def call env
          auth_hash = @credentials.client.apply({})
          env.request_headers["Authorization"] = auth_hash[:authorization]

          @app.call env
        end
      end

      Faraday::Request.register_middleware google_authorization: -> { GoogleAuthorization }
    end
  end
end
