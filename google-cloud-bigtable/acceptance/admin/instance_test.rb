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

require "bigtable_helper"

describe "Bigtable Instance #find", :bigtable do
  let(:instance_id) { "instance#{Time.now.to_i}" }
  let(:cluster_id) { "cluster#{Time.now.to_i}" }
  let(:zone) { config.location_path("us-central1-c") }
  let(:cluster) { Bigtable::Cluster.new(cluster_id: cluster_id, location: zone) }

  before do
    @created_instance = bigtable.instances.create! instance_id: instance_id,
                                                   display_name: "My Instance",
                                                   clusters: [cluster]
  end

  it "should find the created Instance" do
    instance = bigtable.instances.find instance_id

    assert_equal instance.name, @created_instance.name
  end

  it "should appear in the instance list" do
    instance = bigtable.instances.select { |ob| ob.name.end_with? instance_id }.first

    assert !instance.nil?
  end

  after do
    @created_instance.delete!
  end
end

describe "Bigtable Instance #create", :bigtable do
  let(:instance_id) { "instance#{Time.now.to_i}" }
  let(:cluster_id) { "cluster#{Time.now.to_i}" }
  let(:zone) { config.location_path("us-central1-c") }

  before do 
    @created_instances = []
  end

  it "should create a production instance with three nodes" do
    cluster = Bigtable::Cluster.new cluster_id: cluster_id, 
                                    location: zone,
                                    serve_nodes: 3
    instance = bigtable.instances.create! instance_id: instance_id,
                                          display_name: "My Instance",
                                          type: :PRODUCTION,
                                          clusters: [cluster]

    @created_instances << instance
  end

  it "should create a instance with labels" do
    key = "key#{Time.now.to_i}"
    value = "value#{Time.now.to_i}"

    cluster = Bigtable::Cluster.new cluster_id: cluster_id, 
                                    location: zone
    instance = bigtable.instances.create! instance_id: instance_id,
                                          display_name: "My Instance",
                                          labels: {key=>value},
                                          clusters: [cluster]
    assert_equal instance.labels[key], value
    @created_instances << instance
  end

  after do
    @created_instances.each &:delete!
  end
end

describe "Bigtable Instance #save", :bigtable do
  let(:instance_id) { "instance#{Time.now.to_i}" }
  let(:cluster_id) { "cluster#{Time.now.to_i}" }
  let(:zone) { config.location_path("us-central1-c") }
  let(:cluster) { Bigtable::Cluster.new(cluster_id: cluster_id, location: zone) }

  before do
    @created_instance = bigtable.instances.create! instance_id: instance_id,
                                                   display_name: "My Instance",
                                                   clusters: [cluster]
  end

  it "should allow changing the display_name" do
    assert_equal @created_instance.display_name, "My Instance"

    @created_instance.display_name = "My Cool Instance"
    @created_instance.save!

    instance = bigtable.instances.find instance_id
    assert_equal instance.display_name, "My Cool Instance"
  end

  it "should allow changing the type" do
    assert_equal @created_instance.type, :DEVELOPMENT

    @created_instance.type = :PRODUCTION
    @created_instance.save!

    instance = bigtable.instances.find instance_id
    assert_equal instance.type, :PRODUCTION
  end

  after do
    @created_instance.delete!
  end
end
