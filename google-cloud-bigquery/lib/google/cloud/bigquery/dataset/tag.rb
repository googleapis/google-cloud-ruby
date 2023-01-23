# Copyright 2022 Google LLC
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

require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      class Dataset
        ##
        # A global tag managed by Resource Manager.
        #
        # @see https://cloud.google.com/iam/docs/tags-access-control#definitions
        #
        class Tag
          ##
          # @private The Google API Client object.
          attr_accessor :gapi

          ##
          # @private Create an empty Tag object.
          def initialize
            @gapi = Google::Apis::BigqueryV2::Dataset::Tag.new
          end

          ##
          # The namespaced friendly name of the tag key, e.g. "12345/environment" where
          # 12345 is org id.
          #
          # @return [String]
          #
          def tag_key
            @gapi.tag_key
          end

          ##
          # The friendly short name of the tag value, e.g. "production".
          #
          # @return [String]
          #
          def tag_value
            @gapi.tag_value
          end

          ##
          # @private Google API Client object.
          def self.from_gapi gapi
            new_tag = new
            new_tag.instance_variable_set :@gapi, gapi
            new_tag
          end
        end
      end
    end
  end
end
