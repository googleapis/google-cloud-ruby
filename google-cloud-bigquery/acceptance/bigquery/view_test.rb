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

describe Google::Cloud::Bigquery::Table, :view, :bigquery do
  let(:publicdata_query) { "SELECT url FROM `bigquery-public-data.samples.github_nested` LIMIT 100" }
  let(:publicdata_query_2) { "SELECT url FROM `bigquery-public-data.samples.github_nested` LIMIT 50" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:view_id) { "urls" }
  let(:view) do
    t = dataset.table view_id
    if t.nil?
      t = dataset.create_view view_id, publicdata_query
    end
    t
  end

  it "has the attributes of a view" do
    fresh = dataset.table view.table_id
    _(fresh).must_be_kind_of  Google::Cloud::Bigquery::Table

    _(fresh.project_id).must_equal bigquery.project
    _(fresh.id).must_equal "#{bigquery.project}:#{dataset.dataset_id}.#{view.table_id}"
    _(fresh.query_id).must_equal "`#{bigquery.project}.#{dataset.dataset_id}.#{view.table_id}`"
    _(fresh.etag).wont_be :nil?
    _(fresh.api_url).wont_be :nil?
    _(fresh.query_id).must_equal view.query_id
    _(fresh.created_at).must_be_kind_of Time
    _(fresh.expires_at).must_be :nil?
    _(fresh.modified_at).must_be_kind_of Time
    _(fresh.table?).must_equal false
    _(fresh.view?).must_equal true
    _(fresh.materialized_view?).must_equal false
    #fresh.location.must_equal "US"       TODO why nil? Set in dataset
    _(fresh.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(fresh.headers).must_equal [:url]
  end

  it "gets and sets attributes" do
    new_name = "New name!"
    new_desc = "New description!"

    view.name = new_name
    view.description = new_desc
    view.query = publicdata_query_2

    view.reload!
    _(view.table_id).must_equal view_id
    _(view.name).must_equal new_name
    _(view.description).must_equal new_desc
    _(view.query).must_equal publicdata_query_2
  end

  it "should fail to set metadata with stale etag" do
    fresh = dataset.table view.table_id
    _(fresh.etag).wont_be :nil?

    stale = dataset.table view_id
    _(stale.etag).wont_be :nil?
    _(stale.etag).must_equal fresh.etag

    # Modify on the server, which will change the etag
    fresh.description = "Description 1"
    _(stale.etag).wont_equal fresh.etag
    err = expect { stale.description = "Description 2" }.must_raise Google::Cloud::FailedPreconditionError
    _(err.message).must_match(/^(failedPrecondition|FAILED_PRECONDITION): Precondition check failed\.$/)
  end
end
