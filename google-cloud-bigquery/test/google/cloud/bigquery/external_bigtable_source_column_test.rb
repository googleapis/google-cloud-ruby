# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::BigQuery::External::BigtableSource::Column, :mock_bigquery do
  it "raises if not given valid arguments" do
    expect { bigquery.external nil }.must_raise ArgumentError
  end

  it "creates a simple external table" do
    external = bigquery.external "gs://my-bucket/path/to/file.csv"
    external.must_be_kind_of Google::Cloud::BigQuery::External::CsvSource
    external.urls.must_equal ["gs://my-bucket/path/to/file.csv"]
    external.format.must_equal "CSV"
  end

  it "determines CSV from one URL" do
    external = bigquery.external "gs://my-bucket/path/to/file.csv"
    external.must_be_kind_of Google::Cloud::BigQuery::External::CsvSource
    external.urls.must_equal ["gs://my-bucket/path/to/file.csv"]
    external.format.must_equal "CSV"
  end

  it "determines CSV from multiple URL" do
    external = bigquery.external ["some url", "gs://my-bucket/path/to/file.csv"]
    external.must_be_kind_of Google::Cloud::BigQuery::External::CsvSource
    external.urls.must_equal ["some url", "gs://my-bucket/path/to/file.csv"]
    external.format.must_equal "CSV"
  end

  it "determines CSV from the format (:csv)" do
    external = bigquery.external "some url", format: :csv
    external.must_be_kind_of Google::Cloud::BigQuery::External::CsvSource
    external.urls.must_equal ["some url"]
    external.format.must_equal "CSV"
  end

  it "determines CSV from the format (csv)" do
    external = bigquery.external "some url", format: "csv"
    external.must_be_kind_of Google::Cloud::BigQuery::External::CsvSource
    external.urls.must_equal ["some url"]
    external.format.must_equal "CSV"
  end

  it "determines CSV from the format (:CSV)" do
    external = bigquery.external "some url", format: :CSV
    external.must_be_kind_of Google::Cloud::BigQuery::External::CsvSource
    external.urls.must_equal ["some url"]
    external.format.must_equal "CSV"
  end

  it "determines CSV from the format (CSV)" do
    external = bigquery.external "some url", format: "CSV"
    external.must_be_kind_of Google::Cloud::BigQuery::External::CsvSource
    external.urls.must_equal ["some url"]
    external.format.must_equal "CSV"
  end
end
