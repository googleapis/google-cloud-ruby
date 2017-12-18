# Copyright 2015 Google Inc. All rights reserved.
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

require "bigquery_helper"

describe Google::Cloud::BigQuery::Dataset, :access, :bigquery do
  let(:publicdata_query) { "SELECT url FROM `publicdata.samples.github_nested` LIMIT 100" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:dataset_view_id) { "#{prefix}_dataset_view" }
  let(:dataset_view) do
    d = bigquery.dataset dataset_view_id
    if d.nil?
      d = bigquery.create_dataset dataset_view_id
    end
    d
  end
  let(:user_val) { "blowmage@gmail.com" }
  let(:view_id) { "dataset_access_view" }
  let(:view) do
    t = dataset_view.table view_id
    if t.nil?
      t = dataset_view.create_view view_id, publicdata_query
    end
    t
  end

  it "adds an access entry with specifying user scope" do
    dataset.access do |acl|
      acl.add_reader_user user_val
    end
    dataset = bigquery.dataset dataset_id
    assert dataset.access.reader_user? user_val

    dataset.access do |acl|
      acl.remove_reader_user user_val
    end
    dataset = bigquery.dataset dataset_id
    refute dataset.access.reader_user? user_val
  end

  it "adds an access entry with specifying special scope" do
    dataset.access do |acl|
      acl.add_reader_special :all
    end
    dataset = bigquery.dataset dataset_id
    dataset.access.wont_be :empty?
    dataset.access.to_a.must_be_kind_of Array
    assert dataset.access.reader_special? :all

    dataset.access do |acl|
      acl.remove_reader_special :all
    end
    dataset = bigquery.dataset dataset_id
    refute dataset.access.reader_special? :all
  end

  it "adds an access entry with specifying view scope" do
    refute dataset.access.reader_view? view
    dataset.access do |acl|
      acl.add_reader_view view
    end
    dataset = bigquery.dataset dataset_id
    assert dataset.access.reader_view? view

    dataset.access do |acl|
      acl.remove_reader_view view
    end
    dataset = bigquery.dataset dataset_id
    refute dataset.access.reader_view? view
  end
end
