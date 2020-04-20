# Copyright 2017 Google LLC
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

describe Google::Cloud::PubSub::Subscriber, :mock_pubsub do
  let(:callback) { Proc.new { |msg| puts msg.inspect } }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:deadline) { 120 }
  let(:streams) { 8 }
  let(:inventory) { 2000 }
  let(:callback_threads) { 16 }
  let(:push_threads) { 8 }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.new subscription_name, callback, deadline: deadline, streams: streams, inventory: inventory, threads: { callback: callback_threads, push: push_threads}, service: pubsub.service }

  it "knows itself" do
    _(subscriber).must_be_kind_of Google::Cloud::PubSub::Subscriber
    _(subscriber.callback).must_equal callback
    _(subscriber.subscription_name).must_equal subscription_name
    _(subscriber.deadline).must_equal deadline
    _(subscriber.streams).must_equal streams
    _(subscriber.inventory).must_equal inventory
    _(subscriber.inventory_limit).must_equal inventory
    _(subscriber.max_outstanding_messages).must_equal inventory
    _(subscriber.inventory_bytesize).must_equal 100_000_000
    _(subscriber.max_outstanding_bytes).must_equal 100_000_000
    _(subscriber.inventory_extension).must_equal 3600
    _(subscriber.max_total_lease_duration).must_equal 3600
    _(subscriber.max_duration_per_lease_extension).must_equal 0
    _(subscriber.stream_inventory).must_equal({limit: 250, bytesize: 12500000, max_duration_per_lease_extension: 0, extension: 3600})
    _(subscriber.callback_threads).must_equal callback_threads
    _(subscriber.push_threads).must_equal push_threads

    _(subscriber.to_s).must_equal "(subscription: subscription-name-goes-here, streams: [(inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started)])"
    _(subscriber.stream_pool.first.to_s).must_equal "(inventory: 0, status: running, thread: not started)"
  end
end
