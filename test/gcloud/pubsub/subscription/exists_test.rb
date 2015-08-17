# Copyright 2015 Google Inc. All rights reserved.
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

describe Gcloud::Pubsub::Subscription, :exists, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json(topic_name, sub_name) }
  let :subscription do
    json = JSON.parse(sub_json)
    Gcloud::Pubsub::Subscription.from_gapi json, pubsub.connection
  end

  it "knows if it exists when created with an HTTP method" do
    # The absense of a mock_connection config means this test will fail
    # if the method exists? makes an HTTP call.
    subscription.must_be :exists?
    # Additional exists? calls do not make HTTP calls either
    subscription.must_be :exists?
  end

  describe "lazy subscription object of a subscription that exists" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection
    end

    it "checks if the subscription exists by making an HTTP call" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [200, {"Content-Type"=>"application/json"},
         sub_json]
      end

      subscription.must_be :exists?
      # Additional exists? calls do not make HTTP calls
      subscription.must_be :exists?
    end
  end

  describe "lazy subscription object of a subscription that does not exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection
    end

    it "checks if the subscription exists by making an HTTP call" do
      mock_connection.get "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      subscription.wont_be :exists?
      # Additional exists? calls do not make HTTP calls
      subscription.wont_be :exists?
    end
  end
end
