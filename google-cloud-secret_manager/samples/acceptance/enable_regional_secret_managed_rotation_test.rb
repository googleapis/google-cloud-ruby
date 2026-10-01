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

describe "#enable_regional_secret_managed_rotation", :regional_secret_manager_snippet do
  it "enables managed rotation and creates the first secret version" do
    sample = SampleLoader.load "enable_regional_secret_managed_rotation.rb"

    # enable_managed_rotation needs the secret's own built-in identity
    # granted Cloud SQL IAM permissions first -- there's no broader grant
    # that covers a secret before it exists, so every secret used here
    # needs its own grant/revoke around the test that uses it.
    member = cloud_sql_credentials_secret.policy_member.iam_policy_uid_principal
    grant_cloud_sql_role member

    begin
      out, _err = capture_io do
        sample.run project_id:    project_id,
                   location_id:  location_id,
                   secret_id:    secret_id,
                   instance_id:  cloud_sql_instance_id,
                   username:     cloud_sql_username
      end
      assert_match(/Enabled managed rotation, created secret version: /, out)

      version = client.get_secret_version name: "#{secret_name}/versions/1"
      assert_equal :ENABLED, version.state
    ensure
      revoke_cloud_sql_role member
    end
  end
end
