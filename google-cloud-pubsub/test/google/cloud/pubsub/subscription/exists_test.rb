# Copyright 2015 Google LLC
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

describe Google::Cloud::PubSub::Subscription, :exists, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash(topic_name, sub_name) }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "knows if it exists when created with an HTTP method" do
    # The absense of a mock means this test will fail
    # if the method exists? makes an HTTP call.
    _(subscription).must_be :exists?
    # Additional exists? calls do not make HTTP calls either
    _(subscription).must_be :exists?
  end

  describe "reference subscription object of a subscription that exists" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "checks if the subscription exists by making an HTTP call" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription: subscription_path(sub_name)]
      subscription.service.mocked_subscriber = mock

      _(subscription).must_be :exists?

      mock.verify

      # Additional exists? calls do not make HTTP calls
      _(subscription).must_be :exists?
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "checks if the subscription exists by making an HTTP call" do
      stub = Object.new
      def stub.get_subscription *args
        raise Google::Cloud::NotFoundError.new("not found")
      end
      subscription.service.mocked_subscriber = stub

      _(subscription).wont_be :exists?
      # Additional exists? calls do not make HTTP calls
      _(subscription).wont_be :exists?
    end
  end
end
