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
  let(:max_outstanding_messages) { 2000 }
  let(:callback_threads) { 16 }
  let(:push_threads) { 8 }
  let :subscriber do
    Google::Cloud::PubSub::Subscriber.new(
      subscription_name,
      callback,
      deadline: deadline,
      streams: streams,
      inventory: max_outstanding_messages,
      threads: {
        callback: callback_threads,
        push: push_threads
      },
      service: pubsub.service
    )
  end

  it "knows its defaults" do
    subscriber = Google::Cloud::PubSub::Subscriber.new(
      subscription_name,
      callback,
      service: pubsub.service
    )
    _(subscriber).must_be_kind_of Google::Cloud::PubSub::Subscriber
    _(subscriber.deadline).must_equal 60
    _(subscriber.streams).must_equal 2
    _(subscriber.inventory).must_equal 1000 # deprecated Use #max_outstanding_messages.
    _(subscriber.inventory_limit).must_equal 1000 # deprecated Use #max_outstanding_messages.
    _(subscriber.max_outstanding_messages).must_equal 1000
    _(subscriber.inventory_bytesize).must_equal 100_000_000 # deprecated Use #max_outstanding_bytes.
    _(subscriber.max_outstanding_bytes).must_equal 100_000_000
    _(subscriber.inventory_extension).must_equal 3600 # deprecated Use #max_total_lease_duration.
    _(subscriber.max_total_lease_duration).must_equal 3600
    _(subscriber.max_duration_per_lease_extension).must_equal 0
    _(subscriber.stream_inventory).must_equal({limit: 500, bytesize: 50000000, max_duration_per_lease_extension: 0, extension: 3600})
    _(subscriber.callback_threads).must_equal 8
    _(subscriber.push_threads).must_equal 4
  end

  it "knows its given attributes and retains defaults" do
    _(subscriber).must_be_kind_of Google::Cloud::PubSub::Subscriber
    _(subscriber.callback).must_equal callback
    _(subscriber.subscription_name).must_equal subscription_name
    _(subscriber.deadline).must_equal deadline
    _(subscriber.streams).must_equal streams
    _(subscriber.inventory).must_equal max_outstanding_messages # deprecated Use #max_outstanding_messages.
    _(subscriber.inventory_limit).must_equal max_outstanding_messages # deprecated Use #max_outstanding_messages.
    _(subscriber.max_outstanding_messages).must_equal max_outstanding_messages
    _(subscriber.inventory_bytesize).must_equal 100_000_000 # deprecated Use #max_outstanding_bytes.
    _(subscriber.max_outstanding_bytes).must_equal 100_000_000
    _(subscriber.inventory_extension).must_equal 3600 # deprecated Use #max_total_lease_duration.
    _(subscriber.max_total_lease_duration).must_equal 3600
    _(subscriber.max_duration_per_lease_extension).must_equal 0
    _(subscriber.stream_inventory).must_equal({limit: 250, bytesize: 12500000, max_duration_per_lease_extension: 0, extension: 3600})
    _(subscriber.callback_threads).must_equal callback_threads
    _(subscriber.push_threads).must_equal push_threads

    _(subscriber.to_s).must_equal "(subscription: subscription-name-goes-here, streams: [(inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started)])"
    _(subscriber.stream_pool.first.to_s).must_equal "(inventory: 0, status: running, thread: not started)"
  end
end
