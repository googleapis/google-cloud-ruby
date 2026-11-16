# frozen_string_literal: true

# Copyright 2019 Google LLC
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


require "bigtable_helper"

describe Google::Cloud::Bigtable::Project, :bigtable do
  let(:instance_id) { "ruby-test-#{random_str}" }
  let(:cluster_id) { "ruby-clstr-#{random_str}" }
  let(:cluster_location) { "us-east1-b" }

  after do
    instance = bigtable.instance instance_id
    instance&.delete
  end

  it "creates an instance with type production" do
    job = bigtable.create_instance(
      instance_id,
      display_name: "Ruby Acceptance Test",
      type: :PRODUCTION,
      labels: { env: "test" }
    ) do |clusters|
      clusters.add cluster_id, cluster_location, nodes: 1
    end

    job.wait_until_done!

    raise GRPC::BadStatus.new(job.error.code, job.error.message) if job.error?

    instance = job.instance
    _(instance).must_be_kind_of Google::Cloud::Bigtable::Instance
    _(instance.production?).must_equal true
    _(instance.clusters.count).must_equal 1
    cluster = instance.clusters.first

    _(cluster.nodes).must_equal 1
    _(cluster.kms_key).must_be :nil?
  end
end
