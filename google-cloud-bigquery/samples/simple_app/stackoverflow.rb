# Copyright 2020 Google LCC
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

# A short sample demonstrating how to make a BigQuery API request
def stackoverflow
  # [START bigquery_simple_app_all]
  # [START bigquery_simple_app_deps]
  require "google/cloud/bigquery"
  # [END bigquery_simple_app_deps]

  # [START bigquery_simple_app_client]
  # This uses Application Default Credentials to authenticate.
  # @see https://cloud.google.com/bigquery/docs/authentication/getting-started
  bigquery = Google::Cloud::Bigquery.new
  # [END bigquery_simple_app_client]

  # [START bigquery_simple_app_query]
  sql     = "SELECT " \
            "CONCAT('https://stackoverflow.com/questions/', " \
            "       CAST(id as STRING)) as url, view_count " \
            "FROM `bigquery-public-data.stackoverflow.posts_questions` " \
            "WHERE tags like '%google-bigquery%' " \
            "ORDER BY view_count DESC LIMIT 10"
  results = bigquery.query sql
  # [END bigquery_simple_app_query]

  # [START bigquery_simple_app_print]
  results.each do |row|
    puts "#{row[:url]}: #{row[:view_count]} views"
  end
  # [END bigquery_simple_app_print]
  # [END bigquery_simple_app_all]
end

stackoverflow if $PROGRAM_NAME == __FILE__
