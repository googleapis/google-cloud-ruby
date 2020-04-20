 # Copyright 2016 Google LLC
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

describe Google::Cloud::PubSub::Policy, :mock_pubsub do
  let(:etag)       { "etag-1" }
  let(:roles) { { "roles/viewer" => ["allUsers"] } }
  let(:policy)    { Google::Cloud::PubSub::Policy.new etag, roles }

  it "knows its etag" do
    _(policy.roles).must_equal roles
  end

  it "knows its roles" do
    _(policy.roles.keys.sort).must_equal   roles.keys.sort
    _(policy.roles.values.sort).must_equal roles.values.sort
  end

  it "returns an empty array for missing role" do
    role = policy.role "roles/does-not-exist"
    _(role).must_be_kind_of Array
    _(role).must_be :empty?
    _(role.frozen?).must_equal false
  end
end
