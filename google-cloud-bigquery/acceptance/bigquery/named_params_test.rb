# Copyright 2016 Google Inc. All rights reserved.
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

describe Google::Cloud::Bigquery, :positional_params, :bigquery do
  it "queries the data with a string parameter" do
    rows = bigquery.query "SELECT repository.name, public FROM `publicdata.samples.github_nested` WHERE repository.owner = @owner LIMIT 1", params: { owner: "blowmage" }

    rows.class.must_equal Google::Cloud::Bigquery::QueryData
    rows.count.must_equal 1
  end

  it "queries the data with an integer parameter" do
    rows = bigquery.query "SELECT repository.name, repository.forks FROM `publicdata.samples.github_nested` WHERE repository.owner = @owner AND repository.forks > @forks LIMIT 5", params: { owner: "blowmage", forks: 10 }

    rows.class.must_equal Google::Cloud::Bigquery::QueryData
    rows.count.must_equal 5
  end

  it "queries the data with a float parameter" do
    rows = bigquery.query "SELECT station_number, year, month, day, snow_depth FROM `publicdata.samples.gsod` WHERE snow_depth >= @depth LIMIT 5", params: { depth: 12.0 }

    rows.class.must_equal Google::Cloud::Bigquery::QueryData
    rows.count.must_equal 5
  end

  it "queries the data with a boolean parameter" do
    rows = bigquery.query "SELECT repository.name, public FROM `publicdata.samples.github_nested` WHERE repository.owner = @owner AND public = @public LIMIT 1", params: { owner: "blowmage", public: true }

    rows.class.must_equal Google::Cloud::Bigquery::QueryData
    rows.count.must_equal 1
  end

  it "queries the data with a date parameter" do
    skip "Don't know of any sample data that uses DATE values"
  end

  it "queries the data with a time parameter" do
    rows = bigquery.query "SELECT subject FROM `bigquery-public-data.github_repos.commits` WHERE author.name = @author AND author.date < @date LIMIT 1", params: { author: "blowmage", date: Time.now }

    rows.class.must_equal Google::Cloud::Bigquery::QueryData
    rows.count.must_equal 1
  end

  it "queries the data with an array parameter" do
    rows = bigquery.query "SELECT * FROM UNNEST (@list)", params: { list: [25,26,27,28,29] }

    rows.class.must_equal Google::Cloud::Bigquery::QueryData
    rows.count.must_equal 5
  end

  it "queries the data with a struct parameter" do
    skip "Don't know how to query with struct parameters"
  end
end
