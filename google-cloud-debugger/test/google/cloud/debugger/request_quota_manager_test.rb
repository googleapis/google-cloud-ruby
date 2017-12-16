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

describe Google::Cloud::Debugger::RequestQuotaManager, :mock_debugger do
  let(:quota_manager) { Google::Cloud::Debugger::RequestQuotaManager.new }

  describe "#more?" do
    it "returns false when all the time quota is used up" do
      quota_manager.more?.must_equal true

      quota_manager.consume time: (quota_manager.time_quota + 1)

      quota_manager.more?.must_equal false
    end

    it "returns false when all the count quota is used up" do
      quota_manager.more?.must_equal true

      quota_manager.count_quota.times do
        quota_manager.consume
      end

      quota_manager.more?.must_equal false
    end
  end

  describe "#reset" do
    it "resets time quota" do
      quota_manager.more?.must_equal true

      quota_manager.consume time: (quota_manager.time_quota + 1)

      quota_manager.more?.must_equal false

      quota_manager.reset

      quota_manager.more?.must_equal true
    end

    it "resets count quota" do
      quota_manager.more?.must_equal true

      quota_manager.count_quota.times do
        quota_manager.consume
      end

      quota_manager.more?.must_equal false

      quota_manager.reset

      quota_manager.more?.must_equal true
    end
  end
end
