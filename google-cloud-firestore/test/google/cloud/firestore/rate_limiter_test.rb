# Copyright 2023 Google LLC
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
require "google/cloud/firestore/rate_limiter"

describe Google::Cloud::Firestore::RateLimiter do

  it "get 501 token from the RateLimiter" do
    rate_limiter = Google::Cloud::Firestore::RateLimiter.new
    time_1 = Time.now
    rate_limiter.wait_for_tokens 501
    time_2 = Time.now
    _((time_2 - time_1).to_f).must_be :>, 1
  end


  it "checks whether the bandwidth increases after phase length" do
    rate_limiter = Google::Cloud::Firestore::RateLimiter.new phase_length: 2
    rate_limiter.wait_for_tokens 500
    _(rate_limiter.bandwidth).must_equal 500
    rate_limiter.wait_for_tokens 500
    _(rate_limiter.bandwidth).must_equal 750
  end



end
