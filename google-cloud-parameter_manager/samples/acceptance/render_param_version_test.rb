# Copyright 2025 Google LLC
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

require_relative "helper"

describe "#render_param_version", :parameter_manager_snippet do
  before do
    # Create Parameter
    param = client.create_parameter parent: location_name, parameter_id: parameter_id, parameter: { format: format }

    # Create secret and secret version
    secret = secret_client.create_secret parent: project_name, secret_id: render_secret_id,
                                         secret: { replication: { automatic: {} } }
    secret_client.add_secret_version parent: secret_name, payload: { data: payload }

    # Get IAM Policy
    policy = secret_client.get_iam_policy resource: secret_name
    policy.bindings << Google::Iam::V1::Binding.new(
      members: [param.policy_member.iam_policy_uid_principal],
      role: "roles/secretmanager.secretAccessor"
    )

    # Update IAM policy
    secret_client.set_iam_policy resource: secret_name, policy: policy

    data = '{"username": "test-user", "password": ' \
           "\"__REF__(//secretmanager.googleapis.com/#{secret_name}/versions/latest)\"}"

    # Create Parameter Version
    client.create_parameter_version parent: parameter_name, parameter_version_id: version_id,
                                    parameter_version: { payload: { data: data } }
  end

  it "render a parameter version" do
    sample = SampleLoader.load "render_param_version.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, parameter_id: parameter_id, version_id: version_id
    end

    assert_equal "Rendered parameter version payload: {\"username\": \"test-user\", \"password\": \"test123\"}\n", out
  end
end
