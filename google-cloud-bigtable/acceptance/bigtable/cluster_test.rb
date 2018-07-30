# frozen_string_literal: true

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


require "bigtable_helper"

describe "Instance Clusters", :bigtable do
  let(:instance) { bigtable_instance }

  it "lists and get cluster" do
    clusters = instance.clusters.to_a
    clusters.wont_be :empty?
    clusters.each do |cluster|
      cluster.must_be_kind_of Google::Cloud::Bigtable::Cluster
    end

    cluster_id = clusters.first.cluster_id
    first_cluster = instance.cluster(cluster_id)
    first_cluster.must_be_kind_of Google::Cloud::Bigtable::Cluster
  end

  it "create cluster, update and delete" do
    cluster_id = "#{$bigtable_cluster_id}2"
    location = $bigtable_cluster_location_2

    job = instance.create_cluster(cluster_id, location, nodes: 3)
    job.wait_until_done!

    clusters = instance.clusters.to_a
    clusters.length.must_equal 2

    cluster = job.cluster
    cluster.must_be_kind_of Google::Cloud::Bigtable::Cluster
    instance.cluster(cluster_id).wont_be :nil?

    cluster.nodes = 5
    job = cluster.save
    job.wait_until_done!

    cluster = instance.cluster(cluster_id)
    cluster.nodes.must_equal 5

    cluster.delete
    instance.cluster(cluster_id).must_be :nil?
  end if ENV["BIGTABLE_ALL_ACCEPTANCE_TESTS"]
end
