# Copyright 2018 Google LLC
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

describe Google::Cloud::Bigtable::Instance, :mock_bigtable do
  let(:instance_id) { "test-instance-id" }
  let(:display_name) { "Test instance" }

  it "knows the identifiers" do
    instance_grpc = Google::Bigtable::Admin::V2::Instance.new(
      instance_hash(
      name: instance_id,
      display_name: display_name,
      state: :READY,
      type: :PRODUCTION
    ))

    instance = Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
    instance.must_be_kind_of Google::Cloud::Bigtable::Instance
    instance.project_id.must_equal project_id
    instance.instance_id.must_equal instance_id
    instance.display_name.must_equal display_name

    instance.state.must_equal :READY
    instance.must_be :ready?
    instance.wont_be :creating?

    instance.type.must_equal :PRODUCTION
    instance.must_be :production?
    instance.wont_be :development?
  end

  describe "#labels=" do
    let(:instance){
      Google::Cloud::Bigtable::Instance.from_grpc(
        Google::Bigtable::Admin::V2::Instance.new(name: instance_id),
        bigtable.service
      )
    }

    it "set lables using hash" do
      instance.labels = { "env" => "test1" }
      instance.labels.must_equal({"env" => "test1"})

      instance.labels = { :env => "test2" }
      instance.labels.must_equal({"env" => "test2"})

      instance.labels = { data: "users", appprofile: 12345 }
      instance.labels.must_equal({ "data" => "users", "appprofile" => "12345" })
    end

    it "lables can not be nil or other types then hash" do
      proc {
        instance.labels = nil
      }.must_raise Google::Cloud::InvalidArgumentError

      proc {
        instance.labels = 1
      }.must_raise Google::Cloud::InvalidArgumentError
    end
  end
end
