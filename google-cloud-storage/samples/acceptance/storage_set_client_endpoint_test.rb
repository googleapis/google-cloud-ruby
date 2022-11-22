# Copyright 2022 Google LLC
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

require_relative "helper"
require_relative "../storage_set_client_endpoint"

describe "Storage Set Client Endpoint" do
  it "sets a new endpoint" do
    api_endpoint = "https://storage.googleapis.com"
    assert_output "Client initiated with endpoint #{api_endpoint}\n" do
      StorageSetClientEndpoint.new.set_client_endpoint api_endpoint: api_endpoint
    end
  end
end
