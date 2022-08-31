# frozen_string_literal: true

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

require "helper"
require "google/cloud/kms"
require "gapic/common"
require "gapic/grpc"

# This test is for the partial gapic helper lib/google/cloud/kms/helpers.rb
class Google::Cloud::Kms::ClientConstructionHelperMinitest < Minitest::Test
  def test_iam_policy
    Gapic::ServiceStub.stub :new, :stub do
      grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
      client = Google::Cloud::Kms.iam_policy do |config|
        config.credentials = grpc_channel
      end
      assert_kind_of Google::Cloud::Kms::V1::IAMPolicy::Client, client
    end
  end
end
