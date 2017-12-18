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
require "google/cloud/configuration"

describe Google::Cloud do
  describe ".configure" do
    it "allows the config options" do
      config = Google::Cloud.configure

      config.opt1.must_be_nil
      config.opt1 = "value"
      config.opt1.must_equal "value"
    end

    it "returns same object between calls" do
      config = Google::Cloud.configure

      Google::Cloud.configure.object_id.must_equal config.object_id
    end

    it "yields same object as return object" do
      return_config = Google::Cloud.configure

      Google::Cloud.configure do |config|
        return_config.object_id.must_equal config.object_id
      end
    end
  end
end
