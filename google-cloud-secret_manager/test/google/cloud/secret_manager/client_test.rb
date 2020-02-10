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
require "google/cloud/secret_manager"
require "gapic/common"
require "gapic/grpc"

describe Google::Cloud::SecretManager do
  let(:grpc_channel) { GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure }

  it "constructs a secret manager service client with the default version" do
    Gapic::ServiceStub.stub :new, :stub do
      client = Google::Cloud::SecretManager.secret_manager_service do |config|
        config.credentials = grpc_channel
      end
      client.must_be_kind_of Google::Cloud::SecretManager::V1beta1::SecretManagerService::Client
    end
  end
end
