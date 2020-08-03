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

describe Google::Cloud::PubSub::Subscription, :detach, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_path) { subscription_path sub_name }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }

  describe "resource subscription" do
    let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }

    it "can detach itself" do
      mock = Minitest::Mock.new
      mock.expect :detach_subscription, nil, [subscription: sub_path]
      pubsub.service.mocked_publisher = mock

      subscription.detach

      mock.verify
    end
  end

  describe "reference subscription" do
    let(:subscription) { Google::Cloud::PubSub::Subscription.from_name sub_name, pubsub.service }

    it "can detach itself if it exists" do
      mock = Minitest::Mock.new
      mock.expect :detach_subscription, nil, [subscription: sub_path]
      pubsub.service.mocked_publisher = mock

      subscription.detach

      mock.verify
    end

    it "raises NotFoundError when detach is called if it does not exist" do
      stub = Object.new
      def stub.detach_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_publisher = stub

      expect do
        subscription.detach
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
