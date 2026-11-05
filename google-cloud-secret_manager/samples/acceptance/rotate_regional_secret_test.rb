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

describe "#rotate_regional_secret", :regional_secret_manager_snippet do
  it "triggers a rotation, creating a new secret version" do
    enable_sample = SampleLoader.load "enable_regional_secret_managed_rotation.rb"
    rotate_sample = SampleLoader.load "rotate_regional_secret.rb"

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

      out, _err = capture_io do
        rotate_sample.run project_id: project_id, location_id: location_id, secret_id: secret_id
      end
      assert_match(/Rotated secret, created secret version: /, out)

      rotated_version = client.get_secret_version name: "#{secret_name}/versions/2"
      assert_equal :ENABLED, rotated_version.state
    ensure
      revoke_cloud_sql_role member
    end
  end
end
