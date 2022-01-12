# Copyright 2019 Google LLC
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

require "test_helper"
require "gapic/grpc"

class RpcCallRetryTest < Minitest::Test
  def default_sleep_counts
    [
      1, 1.3, 1.6900000000000002, 2.1970000000000005, 2.856100000000001,
      3.7129300000000014, 4.826809000000002, 6.274851700000003,
      8.157307210000004,  10.604499373000007, 13.785849184900009
    ]
  end

  def test_retries_with_exponential_backoff
    inner_attempts = 0
    deadline_arg = nil

    inner_responses = Array.new 4 do
      GRPC::Unavailable.new "unavailable"
    end
    inner_responses += [1729]
    inner_stub = proc do |deadline: nil, **_kwargs|
      deadline_arg = deadline
      inner_attempts += 1
      inner_response = inner_responses.shift

      raise inner_response if inner_response.is_a? Exception

      inner_response
    end

    api_meth_stub = proc do |request, **kwargs|
      OperationStub.new { inner_stub.call(request, **kwargs) }
    end

    rpc_call = Gapic::ServiceStub::RpcCall.new api_meth_stub
    options = Gapic::CallOptions.new(
      timeout: 300,
      retry_policy: { retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE] }
    )

    sleep_mock = Minitest::Mock.new
    default_sleep_counts[0, 4].each do |sleep_count|
      sleep_mock.expect :sleep, nil, [sleep_count]
    end
    sleep_proc = ->(count) { sleep_mock.sleep count }

    time_now = Time.now
    Time.stub :now, time_now do
      Kernel.stub :sleep, sleep_proc do
        assert_equal 1729, rpc_call.call(Object.new, options: options)
        assert_equal 5, inner_attempts
        assert_equal time_now + 300, deadline_arg
      end
    end

    sleep_mock.verify
  end

  def test_retries_with_custom_policy
    inner_responses = Array.new 4 do
      GRPC::Unavailable.new "unavailable"
    end
    inner_responses += [1729]
    inner_stub = proc do |**_kwargs|
      inner_response = inner_responses.shift

      raise inner_response if inner_response.is_a? Exception

      inner_response
    end

    api_meth_stub = proc do |request, **kwargs|
      OperationStub.new { inner_stub.call(request, **kwargs) }
    end

    rpc_call = Gapic::ServiceStub::RpcCall.new api_meth_stub
    custom_policy_count = 0
    custom_policy_sleep = [15, 12, 24, 21]
    custom_policy = lambda do |_error|
      custom_policy_count += 1
      delay = custom_policy_sleep.shift
      if delay
        Kernel.sleep delay
        true
      else
        false
      end
    end
    options = Gapic::CallOptions.new retry_policy: custom_policy

    sleep_mock = Minitest::Mock.new
    custom_policy_sleep.each do |sleep_count|
      sleep_mock.expect :sleep, nil, [sleep_count]
    end
    sleep_proc = ->(count) { sleep_mock.sleep count }

    Kernel.stub :sleep, sleep_proc do
      assert_equal 1729, rpc_call.call(Object.new, options: options)

      assert_equal 4, custom_policy_count
    end

    sleep_mock.verify
  end
end
