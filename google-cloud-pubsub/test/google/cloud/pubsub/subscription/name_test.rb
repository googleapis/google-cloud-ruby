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

describe Google::Cloud::Pubsub::Subscription, :name, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_path) { subscription_path sub_name }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "gives the name returned from the HTTP method" do
    subscription.name.must_equal sub_path
  end

  describe "reference subscription given the short name" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "matches the name returned from the HTTP method" do
      subscription.name.must_equal sub_path
    end
  end

  describe "reference subscription object given the full path" do
    let :subscription do
      Google::Cloud::Pubsub::Subscription.from_name sub_path,
                                            pubsub.service
    end

    it "matches the name returned from the HTTP method" do
      subscription.name.must_equal sub_path
    end
  end
end
