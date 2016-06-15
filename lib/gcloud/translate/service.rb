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


require "gcloud/version"
require "google/apis/translate_v2"

module Gcloud
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
      def initialize key
        @service = API::TranslateService.new
        @service.client_options.application_name    = "gcloud-ruby"
        @service.client_options.application_version = Gcloud::VERSION
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
        service.list_translations Array(text), to, cid: cid, format: format,
                                                   source: from
      end

      ##
      # Returns API::ListDetectionsResponse
      def detect text
        service.list_detections Array(text)
      end

      ##
      # Returns API::ListLanguagesResponse
      def languages language = nil
        service.list_languages target: language
      end

      def inspect
        "#{self.class}"
      end
    end
  end
end
