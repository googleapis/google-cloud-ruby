# Copyright 2020 Google LLC
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
# [START bigquery_query]
require "google/cloud/bigquery"

def query
  bigquery = Google::Cloud::Bigquery.new
  sql = "SELECT name FROM `bigquery-public-data.usa_names.usa_1910_2013` " \
        "WHERE state = 'TX' " \
        "LIMIT 100"

  # Location must match that of the dataset(s) referenced in the query.
  results = bigquery.query sql do |config|
    config.location = "US"
  end

  results.each do |row|
    puts row.inspect
  end
end
# [END bigquery_query]
