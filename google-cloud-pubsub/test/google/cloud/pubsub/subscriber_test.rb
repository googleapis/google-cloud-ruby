# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Pubsub::Subscriber, :mock_pubsub do
  let(:callback) { Proc.new { |msg| puts msg.inspect } }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:deadline) { 120 }
  let(:threads) { 4 }
  let(:subscriber) { Google::Cloud::Pubsub::Subscriber.new callback, subscription_name, deadline, threads, pubsub.service }

  it "knows itself" do
    subscriber.must_be_kind_of Google::Cloud::Pubsub::Subscriber
    subscriber.callback.must_equal callback
    subscriber.subscription_name.must_equal subscription_name
    subscriber.deadline.must_equal deadline
    subscriber.threads.must_equal threads
  end
end
