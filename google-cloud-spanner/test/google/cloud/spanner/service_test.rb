# Copyright 2022 Google LLC
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

describe Google::Cloud::Spanner::Service do
    describe ".new" do
        it "sets quota_project with given value" do
            expected_quota_project = "test_quota_project"
            service = Google::Cloud::Spanner::Service.new(
                "test_project", nil, quota_project: expected_quota_project
              )
            assert_equal expected_quota_project, service.quota_project
        end

        it "sets quota_project from credentials if not given from config" do 
            expected_quota_project = "test_quota_project"
            service = Google::Cloud::Spanner::Service.new(
                "test_project", OpenStruct.new(quota_project_id: expected_quota_project)
              )
            assert_equal expected_quota_project, service.quota_project
        end
    end
end