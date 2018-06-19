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


require "helper"

describe Google::Cloud::Bigtable::Project, :clusters, :mock_bigtable do
  let(:first_page) do
    h = clusters_hash
    h[:next_page_token] = "next_page_token"
    h[:failed_locations] = []
    Google::Bigtable::Admin::V2::ListClustersResponse.new(h)
  end
  let(:second_page) do
    h = clusters_hash(start_id: 10)
    h[:next_page_token] = "second_page_token"
    h[:failed_locations] = []
    Google::Bigtable::Admin::V2::ListClustersResponse.new(h)
  end

  let(:last_page) do
    h = clusters_hash(start_id: 20)
    h[:clusters].pop
    h[:failed_locations] = []
    Google::Bigtable::Admin::V2::ListClustersResponse.new(h)
  end

  it "list all clusters in project" do
    mock = Minitest::Mock.new
    mock.expect :list_clusters, first_page, [instance_path("-"), page_token: nil ]
    bigtable.service.mocked_instances = mock

    clusters = bigtable.clusters

    mock.verify

    clusters.size.must_equal 3
  end

  it "paginates all clusters in project" do
    mock = Minitest::Mock.new
    mock.expect :list_clusters, first_page, [instance_path("-"), page_token: nil]
    mock.expect :list_clusters, last_page, [instance_path("-"), page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    first_clusters = bigtable.clusters
    second_clusters = bigtable.clusters(token: first_page.next_page_token)

    mock.verify

    first_clusters.size.must_equal 3
    token = first_clusters.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    second_clusters.size.must_equal 2
    second_clusters.token.must_be :nil?
  end

  it "paginates all clusters in project with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_clusters, first_page, [instance_path("-"), page_token: nil]
    mock.expect :list_clusters, last_page, [instance_path("-"), page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    first_clusters = bigtable.clusters
    second_clusters = first_clusters.next

    mock.verify

    first_clusters.size.must_equal 3
    first_clusters.next?.must_equal true

    second_clusters.size.must_equal 2
    second_clusters.next?.must_equal false
  end

  it "paginates all clusters in project with all" do
    mock = Minitest::Mock.new
    mock.expect :list_clusters, first_page, [instance_path("-"), page_token: nil]
    mock.expect :list_clusters, last_page, [instance_path("-"), page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    clusters = bigtable.clusters.all.to_a

    mock.verify

    clusters.size.must_equal 5
  end

  it "iterates all clusters in project with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_clusters, first_page, [instance_path("-"), page_token: nil]
    mock.expect :list_clusters, last_page, [instance_path("-"), page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    clusters = bigtable.clusters.all.take(5)

    mock.verify

    clusters.size.must_equal 5
  end
end
