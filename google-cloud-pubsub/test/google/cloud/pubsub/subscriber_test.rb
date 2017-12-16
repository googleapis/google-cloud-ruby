# Copyright 2017 Google LLC
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
  let(:streams) { 8 }
  let(:inventory) { 2000 }
  let(:callback_threads) { 16 }
  let(:push_threads) { 8 }
  let(:subscriber) { Google::Cloud::Pubsub::Subscriber.new subscription_name, callback, deadline: deadline, streams: streams, inventory: inventory, threads: { callback: callback_threads, push: push_threads}, service: pubsub.service }

  it "knows itself" do
    subscriber.must_be_kind_of Google::Cloud::Pubsub::Subscriber
    subscriber.callback.must_equal callback
    subscriber.subscription_name.must_equal subscription_name
    subscriber.deadline.must_equal deadline
    subscriber.streams.must_equal streams
    subscriber.inventory.must_equal inventory
    subscriber.stream_inventory.must_equal 250
    subscriber.callback_threads.must_equal callback_threads
    subscriber.push_threads.must_equal push_threads

    subscriber.to_s.must_equal "(subscription: subscription-name-goes-here, streams: 8)"
    subscriber.stream_pool.first.to_s.must_equal "(inventory: 0, status: not started)"
  end
end
