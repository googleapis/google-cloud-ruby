# frozen_string_literal: true

# Copyright 2020 Google LLC
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

require "helper"
require "ostruct"
require "google/cloud/translate"
require "google/cloud/translate/v2"

class Google::Cloud::Translate::HelpersMinitest < Minitest::Test
  def dummy_credentials
    creds = OpenStruct.new empty: true
    def creds.is_a? target
      target == Google::Auth::Credentials
    end
    creds
  end

  def test_translation_v2_service
    # Clear all environment variables
    ENV.stub :[], nil do
      # Get project_id from Google Compute Engine
      Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
        Google::Cloud::Translate::V2::Credentials.stub :default, dummy_credentials do
          client = Google::Cloud::Translate.translation_v2_service
          assert_kind_of Google::Cloud::Translate::V2::Api, client
        end
      end
    end
  end
end
