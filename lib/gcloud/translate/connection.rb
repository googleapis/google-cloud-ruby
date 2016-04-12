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
require "google/api_client"

module Gcloud
  module Translate
    ##
    # @private Represents the connection to Translate, as well as expose the API
    # calls
    class Connection
      API_VERSION = "v2"

      attr_accessor :client

      ##
      # Creates a new Connection instance.
      def initialize key
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION,
                                        authorization: nil
        @translate = @client.discovered_api "translate", API_VERSION
        @client.key = key # set key after discovery, helps with tests
      end

      def translate *text, to: nil, from: nil, format: nil, cid: nil,
                    quota_user: nil, user_ip: nil
        params = { q:         text,
                   target:    to,
                   source:    from,
                   format:    format,
                   cid:       cid,
                   quotaUser: quota_user,
                   userIp:    user_ip
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @translate.translations.list,
          parameters: params
        )
      end

      def detect *text, quota_user: nil, user_ip: nil
        params = { q:         text,
                   quotaUser: quota_user,
                   userIp:    user_ip
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @translate.detections.list,
          parameters: params
        )
      end

      def languages language = nil, quota_user: nil, user_ip: nil
        params = { target:    language,
                   quotaUser: quota_user,
                   userIp:    user_ip
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @translate.languages.list,
          parameters: params
        )
      end

      def inspect
        "#{self.class}(#{@project})"
      end
    end
  end
end
