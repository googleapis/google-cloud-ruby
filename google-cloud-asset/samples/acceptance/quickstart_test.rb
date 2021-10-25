# Copyright 2020 Google, LLC
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

require "google/cloud/pubsub"

require_relative "helper"
require_relative "../quickstart"

describe "Asset Quickstart" do
  parallelize_me!

  let(:dump_file_name) { "ruby-assets-samples-test.txt" }
  let(:feed_id)        { "ruby_asset_samples_#{SecureRandom.hex}" }
  let :project_id do
    Google::Cloud::Storage.new.project
  end
  let :bucket do
    create_bucket_helper "ruby_asset_sample_#{SecureRandom.hex}"
  end
  let :dump_file_path do
    "gs://#{bucket.name}/#{dump_file_name}"
  end
  let :pubsub do
    require "google/cloud/pubsub"

    Google::Cloud::Pubsub.new
  end
  let :topic do
    topic = pubsub.create_topic "ruby_asset_samples_#{SecureRandom.hex}"
    topic
  end
  let :asset_names do
    asset_name_list = ["//storage.googleapis.com/#{bucket.name}"]
    # ensure read_time_window is after bucket creation
    sleep 3
    asset_name_list
  end
  let :dataset do
    create_dataset_helper "ruby_asset_sample_#{SecureRandom.hex}"
  end
  let :dataset_name do
    dataset_name = "/datasets/#{dataset.dataset_id}"
    # ensure read_time_window is after dataset creation
    sleep 3
    dataset_name
  end

  after do
    delete_bucket_helper bucket.name
  end

  describe "export_assets" do
    it "exports assets to a cloud storage file" do
      assert_nil bucket.file(dump_file_name)
      out, _err = capture_io do
        export_assets project_id: project_id, dump_file_path: dump_file_path
      end
      match = out.match(/Exported assets to: (.*)\n/)
      assert_equal match[1], dump_file_path
      refute_nil bucket.file(dump_file_name)
    end
  end

  describe "batch_get_history" do
    it "puts asset history" do
      out, _err = capture_io do
        batch_get_history project_id: project_id, asset_names: asset_names
      end
      assert out.size.positive?
    end
  end

  describe "list_assets" do
    it "lists asset" do
      out, _err = capture_io do
        list_assets project_id: project_id
      end
      assert out.size.positive?
    end
  end

  describe "create_feed" do
    after do
      topic.delete
    end
    it "creates a feed for a set of assets" do
      asset_names = ["//storage.googleapis.com/#{bucket.name}"]
      out, _err = capture_io do
        create_feed(
          project_id:   project_id,
          feed_id:      feed_id,
          pubsub_topic: topic.name,
          asset_names:  asset_names
        )
      end
      asset_service = Google::Cloud::Asset.asset_service
      match = out.match(/Created feed: (.*)\n/)
      assert match
      asset_service.get_feed name: match[1]
      asset_service.delete_feed name: match[1]
    end
  end

  describe "search_all_resources" do
    after do
      delete_dataset_helper dataset.dataset_id
    end
    it "searches all datasets with the given name" do
      project = ENV["GOOGLE_CLOUD_PROJECT"]
      out, _err = capture_io do
        search_all_resources(
          scope: "projects/#{project}",
          query: "name:#{dataset_name}"
        )
      end
      assert_match(/#{dataset_name}/, out)
    end
  end

  describe "search_all_iam_policies" do
    it "searches all policies bound to the owner" do
      project = ENV["GOOGLE_CLOUD_PROJECT"]
      role = "roles/owner"
      out, _err = capture_io do
        search_all_iam_policies(
          scope: "projects/#{project}",
          query: "policy:#{role}"
        )
      end
      assert_match(/#{role}/, out)
    end
  end

  describe "analyze_iam_policy" do
    it "analyzes who has what acccess to the resource" do
      project = ENV["GOOGLE_CLOUD_PROJECT"]
      full_resource_name = "//cloudresourcemanager.googleapis.com/projects/#{project}"
      out, _err = capture_io do
        analyze_iam_policy(
          scope:              "projects/#{project}",
          full_resource_name: full_resource_name
        )
      end
      assert_match(/#{full_resource_name}/, out)
    end
  end

  describe "analyze_iam_policy_longrunning_gcs" do
    it "analyzes who has what acccess to the resource and writes results to gcs" do
      project = ENV["GOOGLE_CLOUD_PROJECT"]
      full_resource_name = "//cloudresourcemanager.googleapis.com/projects/#{project}"
      object_name = "ruby-analysis-samples.json"
      uri = "gs://#{bucket.name}/#{object_name}"
      assert_nil bucket.file(uri)
      out, _err = capture_io do
        analyze_iam_policy_longrunning_gcs(
          scope:              "projects/#{project}",
          full_resource_name: full_resource_name,
          uri:                uri
        )
      end
      assert_match(/#{uri}/, out)
      refute_nil bucket.file(object_name)
    end
  end

  describe "analyze_iam_policy_longrunning_bigquery" do
    after do
      delete_dataset_helper dataset.dataset_id
    end
    it "analyzes who has what acccess to the resource and writes results to bigquery" do
      project = ENV["GOOGLE_CLOUD_PROJECT"]
      full_resource_name = "//cloudresourcemanager.googleapis.com/projects/#{project}"
      dataset_relative_name = "projects/#{project}/datasets/#{dataset.dataset_id}"
      table_prefix = "ruby-analysis-samples"
      out, _err = capture_io do
        analyze_iam_policy_longrunning_bigquery(
          scope:              "projects/#{project}",
          full_resource_name: full_resource_name,
          dataset:            dataset_relative_name,
          table_prefix:       table_prefix
        )
      end
      assert_match(/#{dataset_relative_name}/, out)
    end
  end
end
