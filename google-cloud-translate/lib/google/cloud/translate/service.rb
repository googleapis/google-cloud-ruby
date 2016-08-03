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


require "google/cloud/errors"
require "google/cloud/translate/version"
require "google/apis/translate_v2"

module Google
  module Cloud
    module Translate
      ##
      # @private
      # Represents the service to Translate, exposing the API calls.
      class Service
        ##
        # Alias to the Google Client API module
        API = Google::Apis::TranslateV2

        attr_accessor :credentials

        ##
        # Creates a new Service instance.
        def initialize key, retries: nil, timeout: nil
          @service = API::TranslateService.new
          @service.client_options.application_name    = "google-cloud-translate"
          @service.client_options.application_version = \
            Google::Cloud::Translate::VERSION
          @service.request_options.retries = retries || 3
          @service.request_options.timeout_sec = timeout if timeout
          @service.authorization = nil
          @service.key = key
        end

        def service
          return mocked_service if mocked_service
          @service
        end
        attr_accessor :mocked_service

        ##
        # Returns API::ListTranslationsResponse
        def translate text, to: nil, from: nil, format: nil, cid: nil
          execute do
            service.list_translations Array(text), to, cid: cid, format: format,
                                                       source: from
          end
        end

        ##
        # Returns API::ListDetectionsResponse
        def detect text
          execute { service.list_detections Array(text) }
        end

        ##
        # Returns API::ListLanguagesResponse
        def languages language = nil
          execute { service.list_languages target: language }
        end

        def inspect
          "#{self.class}"
        end

        protected

        def execute
          yield
        rescue Google::Apis::Error => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
