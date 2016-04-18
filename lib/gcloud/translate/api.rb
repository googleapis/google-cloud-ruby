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


require "gcloud/translate/connection"
require "gcloud/translate/translation"
require "gcloud/translate/detection"
require "gcloud/translate/language"
require "gcloud/translate/errors"

module Gcloud
  module Translate
    ##
    # TODO
    class Api
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private Creates a new Translate Api instance.
      #
      # See {Gcloud.translate}
      def initialize key
        key ||= ENV["TRANSLATE_KEY"]
        if key.nil?
          key_mising_msg = "An API key is required to use the Translate API."
          fail ArgumentError, key_mising_msg
        end
        @connection = Connection.new key
      end

      ##
      # TODO
      def translate *text, to: nil, from: nil, format: nil, cid: nil
        return nil if text.empty?
        fail ArgumentError, "to is required" if to.nil?
        to = to.to_s
        from = from.to_s if from
        format = format.to_s if format
        resp = connection.translate(*text, to: to, from: from,
                                           format: format, cid: cid)
        fail ApiError.from_response(resp) unless resp.success?
        Translation.from_response resp, text, to, from
      end

      ##
      # TODO
      def detect *text
        return nil if text.empty?
        resp = connection.detect(*text)
        fail ApiError.from_response(resp) unless resp.success?
        Detection.from_response resp, text
      end

      ##
      # TODO
      def languages language = nil
        language = language.to_s if language
        resp = connection.languages language
        fail ApiError.from_response(resp) unless resp.success?
        Array(resp.data["languages"]).map { |gapi| Language.from_gapi gapi }
      end
    end
  end
end
