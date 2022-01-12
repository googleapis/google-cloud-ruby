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

class RetryPolicySettingsTest < Minitest::Test
  def test_defaults
    retry_policy = Gapic::CallOptions::RetryPolicy.new

    assert_equal [], retry_policy.retry_codes
    assert_equal 1, retry_policy.initial_delay
    assert_equal 1.3, retry_policy.multiplier
    assert_equal 15, retry_policy.max_delay
  end

  def test_apply_defaults_overrides_default_values
    retry_policy = Gapic::CallOptions::RetryPolicy.new
    retry_policy.apply_defaults(
      retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE],
      initial_delay: 4, multiplier: 5, max_delay: 6
    )

    assert_equal(
      [GRPC::Core::StatusCodes::UNAVAILABLE],
      retry_policy.retry_codes
    )
    assert_equal 4, retry_policy.initial_delay
    assert_equal 5, retry_policy.multiplier
    assert_equal 6, retry_policy.max_delay
  end

  def test_overrides_default_values
    retry_policy = Gapic::CallOptions::RetryPolicy.new(
      retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE],
      initial_delay: 4, multiplier: 5, max_delay: 6
    )

    assert_equal(
      [GRPC::Core::StatusCodes::UNAVAILABLE],
      retry_policy.retry_codes
    )
    assert_equal 4, retry_policy.initial_delay
    assert_equal 5, retry_policy.multiplier
    assert_equal 6, retry_policy.max_delay
  end

  def test_apply_defaults_wont_override_custom_values
    retry_policy = Gapic::CallOptions::RetryPolicy.new(
      retry_codes: [GRPC::Core::StatusCodes::UNIMPLEMENTED],
      initial_delay: 7, multiplier: 6, max_delay: 5
    )
    retry_policy.apply_defaults(
      retry_codes: [GRPC::Core::StatusCodes::UNAVAILABLE],
      initial_delay: 4, multiplier: 5, max_delay: 6
    )

    assert_equal(
      [GRPC::Core::StatusCodes::UNIMPLEMENTED],
      retry_policy.retry_codes
    )
    assert_equal 7, retry_policy.initial_delay
    assert_equal 6, retry_policy.multiplier
    assert_equal 5, retry_policy.max_delay
  end

  def test_existing_and_nonexisting_string_codes
    input_codes = ["INTERNAL", "UNAVAILABLE", "WUT"]
    expected_codes = [GRPC::Core::StatusCodes::INTERNAL, GRPC::Core::StatusCodes::UNAVAILABLE]

    retry_policy = Gapic::CallOptions::RetryPolicy.new retry_codes: input_codes
    assert_equal expected_codes, retry_policy.retry_codes

    retry_policy = Gapic::CallOptions::RetryPolicy.new
    assert_equal [], retry_policy.retry_codes
    retry_policy.apply_defaults retry_codes: input_codes
    assert_equal expected_codes, retry_policy.retry_codes
  end

  def test_all_string_codes
    [
      "OK",
      "CANCELLED",
      "UNKNOWN",
      "INVALID_ARGUMENT",
      "DEADLINE_EXCEEDED",
      "NOT_FOUND",
      "ALREADY_EXISTS",
      "PERMISSION_DENIED",
      "RESOURCE_EXHAUSTED",
      "FAILED_PRECONDITION",
      "ABORTED",
      "OUT_OF_RANGE",
      "UNIMPLEMENTED",
      "INTERNAL",
      "UNAVAILABLE",
      "DATA_LOSS",
      "UNAUTHENTICATED"
    ].each_with_index do |str, num|
      retry_policy = Gapic::CallOptions::RetryPolicy.new retry_codes: str
      assert_equal [num], retry_policy.retry_codes
    end
  end
end
