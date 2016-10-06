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

require "helper"
require "google/cloud/translate"

describe Google::Cloud do
  describe "#translate" do
    it "calls out to Google::Cloud.translate" do
      gcloud = Google::Cloud.new
      stubbed_translate = ->(key, retries: nil, timeout: nil) {
        key.must_equal "this-is-the-api-key"
        retries.must_be :nil?
        timeout.must_be :nil?
        "translate-api-object-empty"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        api = gcloud.translate "this-is-the-api-key"
        api.must_equal "translate-api-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.translate" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_translate = ->(key, retries: nil, timeout: nil) {
        key.must_equal "this-is-the-api-key"
        retries.must_be :nil?
        timeout.must_be :nil?
        "translate-api-object"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        api = gcloud.translate "this-is-the-api-key"
        api.must_equal "translate-api-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.translate" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_translate = ->(key, retries: nil, timeout: nil) {
        key.must_equal "this-is-the-api-key"
        retries.must_equal 5
        timeout.must_equal 60
        "translate-api-object-scoped"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        api = gcloud.translate "this-is-the-api-key", retries: 5, timeout: 60
        api.must_equal "translate-api-object-scoped"
      end
    end
  end

  describe ".translate" do
    it "gets defaults for api_key" do
      stubbed_env = ->(name) {
        "found-api-key" if name == "GOOGLE_CLOUD_KEY"
      }
      stubbed_service = ->(key, retries: nil, timeout: nil) {
        key.must_equal "found-api-key"
        retries.must_equal nil
        timeout.must_equal nil
        OpenStruct.new key: key
      }

      # Clear all environment variables
      # ENV.stub :[], nil do
      ENV.stub :[], stubbed_env do
        Google::Cloud::Translate::Service.stub :new, stubbed_service do
          translate = Google::Cloud.translate
          translate.must_be_kind_of Google::Cloud::Translate::Api
          translate.service.must_be_kind_of OpenStruct
          translate.service.key.must_equal "found-api-key"
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_service = ->(key, retries: nil, timeout: nil) {
        key.must_equal "my-api-key"
        retries.must_equal nil
        timeout.must_equal nil
        OpenStruct.new key: key
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Translate::Service.stub :new, stubbed_service do
          translate = Google::Cloud.translate "my-api-key"
          translate.must_be_kind_of Google::Cloud::Translate::Api
          translate.service.must_be_kind_of OpenStruct
          translate.service.key.must_equal "my-api-key"
        end
      end
    end
  end

  describe "Translate.new" do
    it "gets defaults for api_key" do
      stubbed_env = ->(name) {
        "found-api-key" if name == "GOOGLE_CLOUD_KEY"
      }
      stubbed_service = ->(key, retries: nil, timeout: nil) {
        key.must_equal "found-api-key"
        retries.must_equal nil
        timeout.must_equal nil
        OpenStruct.new key: key
      }

      # Clear all environment variables
      # ENV.stub :[], nil do
      ENV.stub :[], stubbed_env do
        Google::Cloud::Translate::Service.stub :new, stubbed_service do
          translate = Google::Cloud::Translate.new
          translate.must_be_kind_of Google::Cloud::Translate::Api
          translate.service.must_be_kind_of OpenStruct
          translate.service.key.must_equal "found-api-key"
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_service = ->(key, retries: nil, timeout: nil) {
        key.must_equal "my-api-key"
        retries.must_equal nil
        timeout.must_equal nil
        OpenStruct.new key: key
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Translate::Service.stub :new, stubbed_service do
          translate = Google::Cloud::Translate.new key: "my-api-key"
          translate.must_be_kind_of Google::Cloud::Translate::Api
          translate.service.must_be_kind_of OpenStruct
          translate.service.key.must_equal "my-api-key"
        end
      end
    end
  end
end
