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


describe Google::Cloud::Debugger::Backoff do
  let(:backoff) { Google::Cloud::Debugger::Backoff.new }

  describe "#succeeded" do
    it "resets the backoff session" do
      backoff.failed
      backoff.backing_off?.must_equal true

      backoff.succeeded
      backoff.backing_off?.must_equal false
    end
  end

  describe "#failed" do
    it "initializes the backoff session" do
      backoff.backing_off?.must_equal false
      backoff.failed
      backoff.backing_off?.must_equal true
    end

    it "increases the backoff counter with each call" do
      backoff.failed
      interval1 = backoff.interval

      backoff.failed
      interval2 = backoff.interval

      (interval2 > interval1).must_equal true
    end
  end
end
