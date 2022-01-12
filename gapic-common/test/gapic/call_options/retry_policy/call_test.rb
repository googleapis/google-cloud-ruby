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

class RetryPolicyCallTest < Minitest::Test
  def test_wont_retry_when_unconfigured
    retry_policy = Gapic::CallOptions::RetryPolicy.new
    grpc_error = GRPC::Unavailable.new

    refute_includes retry_policy.retry_codes, grpc_error.code

    sleep_proc = ->(_count) { raise "must not call sleep" }

    Kernel.stub :sleep, sleep_proc do
      refute retry_policy.call(grpc_error)
    end
  end

  def test_retries_configured_grpc_errors
    retry_policy = Gapic::CallOptions::RetryPolicy.new(
      retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE]
    )
    grpc_error = GRPC::Unavailable.new

    assert_includes retry_policy.retry_codes, grpc_error.code

    sleep_mock = Minitest::Mock.new
    sleep_mock.expect :sleep, nil, [1]
    sleep_proc = ->(count) { sleep_mock.sleep count }

    Kernel.stub :sleep, sleep_proc do
      assert retry_policy.call(grpc_error)
    end

    sleep_mock.verify
  end

  def test_wont_retry_unconfigured_grpc_errors
    retry_policy = Gapic::CallOptions::RetryPolicy.new(
      retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE]
    )
    grpc_error = GRPC::Unimplemented.new

    refute_includes retry_policy.retry_codes, grpc_error.code

    sleep_proc = ->(_count) { raise "must not call sleep" }

    Kernel.stub :sleep, sleep_proc do
      refute retry_policy.call(grpc_error)
    end
  end

  def test_wont_retry_non_grpc_errors
    retry_policy = Gapic::CallOptions::RetryPolicy.new(
      retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE]
    )
    other_error = StandardError.new

    sleep_proc = ->(_count) { raise "must not call sleep" }

    Kernel.stub :sleep, sleep_proc do
      refute retry_policy.call(other_error)
    end
  end

  def test_incremental_backoff
    retry_policy = Gapic::CallOptions::RetryPolicy.new(
      retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE]
    )
    grpc_error = GRPC::Unavailable.new

    assert_includes retry_policy.retry_codes, grpc_error.code

    sleep_counts = [
      1, 1.3, 1.6900000000000002, 2.1970000000000005, 2.856100000000001,
      3.7129300000000014, 4.826809000000002, 6.274851700000003,
      8.157307210000004,  10.604499373000007, 13.785849184900009, 15, 15
    ]

    sleep_mock = Minitest::Mock.new
    sleep_counts.each do |sleep_count|
      sleep_mock.expect :sleep, nil, [sleep_count]
    end
    sleep_proc = ->(count) { sleep_mock.sleep count }

    Kernel.stub :sleep, sleep_proc do
      sleep_counts.count.times do
        assert retry_policy.call(grpc_error)
      end
    end

    sleep_mock.verify
  end
end
