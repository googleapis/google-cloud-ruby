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

describe Gcloud::Pubsub::Subscription, :delete, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let :subscription do
    Gcloud::Pubsub::Subscription.from_gapi sub_hash, pubsub.connection, pubsub.service
  end

  it "can delete itself" do
    mock_connection.delete "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    subscription.delete
  end

  describe "lazy subscription object of a subscription that does exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection, pubsub.service
    end

    it "can delete itself" do
      mock_connection.delete "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      subscription.delete
    end
  end

  describe "lazy subscription object of a subscription that does not exist" do
    let :subscription do
      Gcloud::Pubsub::Subscription.new_lazy sub_name,
                                            pubsub.connection, pubsub.service
    end

    it "raises NotFoundError when deleting itself" do
      mock_connection.delete "/v1/projects/#{project}/subscriptions/#{sub_name}" do |env|
        [404, {"Content-Type"=>"application/json"},
         not_found_error_json(sub_name)]
      end

      expect do
        subscription.delete
      end.must_raise Gcloud::Pubsub::NotFoundError
    end
  end
end
