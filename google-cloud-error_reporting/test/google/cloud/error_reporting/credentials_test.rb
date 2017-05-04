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


require "helper"

describe Google::Cloud::ErrorReporting::Credentials do
  describe ".credentials_with_scope" do
    let(:default_credentials) { "default_credential" }
    let(:default_scope) { "gcp_scope" }

    it "calls for default credentials if no keyfile" do
      Google::Cloud::ErrorReporting::Credentials.stub :default, default_credentials do
        Google::Cloud::ErrorReporting::Credentials.credentials_with_scope(nil).must_equal default_credentials
      end
    end

    it "passes scope to get default credentials" do
      stubbed_default = ->(scope: nil) {
        scope.must_equal default_scope
        default_credentials
      }
      Google::Cloud::ErrorReporting::Credentials.stub :default, stubbed_default do
        credentials = Google::Cloud::ErrorReporting::Credentials.credentials_with_scope(
          nil, default_scope
        )
        credentials.must_equal default_credentials
      end
    end

    it "creates credential with keyfile and scope" do
      stubbed_new_credential = ->(keyfile, scope: nil) {
        keyfile.must_equal "/path/to/a/keyfile"
        scope.must_equal default_scope
        "new credentials"
      }
      Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_new_credential do
        credentials = Google::Cloud::ErrorReporting::Credentials.credentials_with_scope "/path/to/a/keyfile",
                                                                                        default_scope
        credentials.must_equal "new credentials"
      end
    end
  end
end
