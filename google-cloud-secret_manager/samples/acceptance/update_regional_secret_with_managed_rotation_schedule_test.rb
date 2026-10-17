# Copyright 2026 Google, Inc
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

require "uri"

require_relative "regional_helper"

describe "#update_regional_secret_with_managed_rotation_schedule", :regional_secret_manager_snippet do
  it "reconfigures the recurring rotation schedule" do
    enable_sample = SampleLoader.load "enable_regional_secret_managed_rotation.rb"
    update_sample = SampleLoader.load "update_regional_secret_with_managed_rotation_schedule.rb"

    member = cloud_sql_credentials_secret.policy_member.iam_policy_uid_principal
    grant_cloud_sql_role member

    begin
      capture_io do
        enable_sample.run project_id:   project_id,
                          location_id: location_id,
                          secret_id:   secret_id,
                          instance_id: cloud_sql_instance_id,
                          username:    cloud_sql_username
      end

      before = Time.now.to_i
      rotation_period_seconds = 3600

      out, _err = capture_io do
        update_sample.run project_id:              project_id,
                          location_id:             location_id,
                          secret_id:               secret_id,
                          rotation_period_seconds: rotation_period_seconds
      end
      assert_match(/Updated regional secret rotation schedule: /, out)

      fetched_secret = client.get_secret name: secret_name
      assert fetched_secret.rotation.next_rotation_time.to_time.to_i >= before + rotation_period_seconds
      assert_equal rotation_period_seconds, fetched_secret.rotation.rotation_period.seconds
    ensure
      revoke_cloud_sql_role member
    end
  end
end
