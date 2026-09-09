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

describe Google::Cloud::PubSub::MessageListener, :mock_pubsub do
  let(:callback) { Proc.new { |msg| puts msg.inspect } }
  let(:subscription_name) { "subscription-name-goes-here" }
  let(:deadline) { 120 }
  let(:streams) { 8 }
  let(:max_outstanding_messages) { 2000 }
  let(:callback_threads) { 16 }
  let(:push_threads) { 8 }
  let :listener do
    Google::Cloud::PubSub::MessageListener.new(
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
    listener = Google::Cloud::PubSub::MessageListener.new(
      subscription_name,
      callback,
      service: pubsub.service
    )
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.deadline).must_equal 60
    _(listener.streams).must_equal 1
    _(listener.max_outstanding_messages).must_equal 1000
    _(listener.max_outstanding_bytes).must_equal 100_000_000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
    _(listener.min_duration_per_lease_extension).must_equal 0
    _(listener.stream_inventory).must_equal({limit: 1000, bytesize: 100000000, max_duration_per_lease_extension: 0, min_duration_per_lease_extension: 0, extension: 3600})
    _(listener.callback_threads).must_equal 8
    _(listener.push_threads).must_equal 4
  end

  it "knows its given attributes and retains defaults" do
    _(listener).must_be_kind_of Google::Cloud::PubSub::MessageListener
    _(listener.callback).must_equal callback
    _(listener.subscription_name).must_equal subscription_name
    _(listener.deadline).must_equal deadline
    _(listener.streams).must_equal streams
    _(listener.max_outstanding_messages).must_equal max_outstanding_messages
    _(listener.max_outstanding_bytes).must_equal 100_000_000
    _(listener.max_total_lease_duration).must_equal 3600
    _(listener.max_duration_per_lease_extension).must_equal 0
    _(listener.min_duration_per_lease_extension).must_equal 0
    _(listener.stream_inventory).must_equal({limit: 250, bytesize: 12500000, max_duration_per_lease_extension: 0, min_duration_per_lease_extension: 0, extension: 3600})
    _(listener.callback_threads).must_equal callback_threads
    _(listener.push_threads).must_equal push_threads

    _(listener.to_s).must_equal "(subscription: subscription-name-goes-here, streams: [(inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started), (inventory: 0, status: running, thread: not started)])"
    _(listener.stream_pool.first.to_s).must_equal "(inventory: 0, status: running, thread: not started)"
  end
end
