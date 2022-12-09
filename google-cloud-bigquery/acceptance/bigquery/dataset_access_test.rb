# Copyright 2015 Google LLC
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

require "bigquery_helper"

describe Google::Cloud::Bigquery::Dataset, :access, :bigquery do
  let(:publicdata_query) { "SELECT url FROM `bigquery-public-data.samples.github_nested` LIMIT 100" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:dataset_access_id) { "#{prefix}_dataset_access" }
  let(:dataset_access) do
    d = bigquery.dataset dataset_access_id
    if d.nil?
      d = bigquery.create_dataset dataset_access_id
    end
    d
  end
  let(:user_val) { "blowmage@gmail.com" }
  let(:view_id) { "dataset_access_view" }
  let(:view) do
    t = dataset_access.table view_id
    if t.nil?
      t = dataset_access.create_view view_id, publicdata_query
    end
    t
  end
  let(:target_types) { ["VIEWS"] }


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
    _(dataset.access).wont_be :empty?
    _(dataset.access.to_a).must_be_kind_of Array
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

  it "adds and removes an access entry with specifying dataset object" do
    dataset_access_entry = dataset_access.build_access_entry target_types: target_types

    refute dataset.access.reader_dataset? dataset_access_entry
    dataset.access do |acl|
      acl.add_reader_dataset dataset_access_entry
    end
    dataset.reload!
    assert dataset.access.reader_dataset? dataset_access_entry

    dataset.access do |acl|
      acl.remove_reader_dataset dataset_access_entry
    end
    dataset.reload!
    refute dataset.access.reader_dataset? dataset_access_entry
  end

  it "adds and removes an access entry with specifying dataset hash" do
    dataset_access_entry = {
      project_id: dataset_access.project_id,
      dataset_id: dataset_access.dataset_id,
      target_types: target_types
    }

    refute dataset.access.reader_dataset? dataset_access_entry
    dataset.access do |acl|
      acl.add_reader_dataset dataset_access_entry
    end
    dataset.reload!
    assert dataset.access.reader_dataset? dataset_access_entry

    dataset.access do |acl|
      acl.remove_reader_dataset dataset_access_entry
    end
    dataset.reload!
    refute dataset.access.reader_dataset? dataset_access_entry
  end

  describe :routine do
    let(:routine_id) { "routine_#{SecureRandom.hex(4)}" }
    let :routine_sql do
      routine_sql = <<~SQL
      CREATE FUNCTION `#{routine_id}`(
          arr ARRAY<STRUCT<name STRING, val INT64>>
      ) AS (
          (SELECT SUM(IF(elem.name = "foo",elem.val,null)) FROM UNNEST(arr) AS elem)
      )
      SQL
    end

    it "adds an access entry with specifying routine scope" do
      job = dataset_access.query_job routine_sql
      job.wait_until_done!
      _(job).wont_be :failed?
      routine = job.ddl_target_routine

      refute dataset.access.reader_routine? routine
      dataset.access do |acl|
        acl.add_reader_routine routine
      end
      dataset = bigquery.dataset dataset_id
      routine = dataset_access.routine routine.routine_id
      assert dataset.access.reader_routine? routine

      dataset.access do |acl|
        acl.remove_reader_routine routine
      end
      dataset = bigquery.dataset dataset_access_id, skip_lookup: true
      routine = dataset_access.routine routine.routine_id, skip_lookup: true
      refute dataset.access.reader_routine? routine
    end
  end
end
