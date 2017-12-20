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

describe Google::Cloud::BigQuery::Service::Backoff, :delay do
  class BackoffVerifier
    def initialize
      @mock = Minitest::Mock.new
    end

    def expect meth, ret, args
      @mock.expect meth, ret, args
    end

    def verify
      @mock.verify
    end

    def sleep num
      @mock.sleep num
    end

    # Use the lambda, but give it a new binding context that will use the sleep mock.
    define_method :backoff, &Google::Cloud::BigQuery::Service::Backoff.backoff
  end

  it "has a lambda that calls sleep with the delay given 0" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [1]
    b.backoff 0
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 1" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [2]
    b.backoff 1
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 2" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [4]
    b.backoff 2
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 3" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [8]
    b.backoff 3
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 4" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [16]
    b.backoff 4
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 5" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [32]
    b.backoff 5
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 6" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [32]
    b.backoff 6
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 7" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [32]
    b.backoff 7
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 8" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [32]
    b.backoff 8
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 9" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [32]
    b.backoff 9
    b.verify
  end

  it "has a lambda that calls sleep with the delay given 10" do
    b = BackoffVerifier.new
    b.expect :sleep, nil, [32]
    b.backoff 10
    b.verify
  end
end
