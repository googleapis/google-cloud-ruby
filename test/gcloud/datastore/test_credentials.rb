# Copyright 2014 Google Inc. All rights reserved.
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
require "gcloud/datastore"

describe Gcloud::Datastore::Credentials do
  let(:keyfile_json) do
    { client_email: "test@example.net",
      private_key: OpenSSL::PKey::RSA.new(32).to_s }.to_json
  end

  it "creates a Signet client and fetches access token" do
    credz = nil
    client_mock = Minitest::Mock.new
    client_mock.expect :fetch_access_token!, true
    Signet::OAuth2::Client.stub :new, client_mock do
      File.stub :exist?, true do
        File.stub :read, keyfile_json do
          credz = Gcloud::Datastore::Credentials.new "fake.json"
        end
      end
    end
    client_mock.verify
    credz.must_respond_to :sign_http_request
  end
end
