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

describe Google::Cloud::Pubsub::Subscription, :exists, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json(topic_name, sub_name) }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "knows if it exists when created with an HTTP method" do
    # The absense of a mock means this test will fail
    # if the method exists? makes an HTTP call.
    subscription.must_be :exists?
    # Additional exists? calls do not make HTTP calls either
    subscription.must_be :exists?
  end

  describe "reference subscription object of a subscription that exists" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "checks if the subscription exists by making an HTTP call" do
      get_res = Google::Pubsub::V1::Subscription.decode_json subscription_json(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.must_be :exists?

      mock.verify

      # Additional exists? calls do not make HTTP calls
      subscription.must_be :exists?
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "checks if the subscription exists by making an HTTP call" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      subscription.wont_be :exists?
      # Additional exists? calls do not make HTTP calls
      subscription.wont_be :exists?
    end
  end
end
