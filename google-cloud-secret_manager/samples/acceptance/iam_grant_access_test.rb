# Copyright 2022 Google, Inc
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

require_relative "helper"

describe "#iam_grant_access", :secret_manager_snippet do
  it "grants access to the secret" do
    sample = SampleLoader.load "iam_grant_access.rb"

    refute_nil secret

    assert_output(/Updated IAM policy/) do
      sample.run project_id: project_id, secret_id: secret_id, member: iam_user
    end

    name = client.secret_path project: project_id, secret: secret_id
    n_policy = client.get_iam_policy resource: name
    refute_nil n_policy

    bind = n_policy.bindings.find do |b|
      b.role == "roles/secretmanager.secretAccessor"
    end
    refute_nil bind
    assert_includes bind.members, iam_user
  end
end
