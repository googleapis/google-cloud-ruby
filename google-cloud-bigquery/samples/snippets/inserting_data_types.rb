# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START bigquery_inserting_data_types]
require "google/cloud/bigquery"
require "base64"

##
# Inserts a row with various data types into a table.
#
# @param dataset_id [String] The ID of the dataset to create the table in.
# @param table_id   [String] The ID of the table to create.
def inserting_data_types dataset_id, table_id
  bigquery = Google::Cloud::Bigquery.new
  dataset = bigquery.dataset dataset_id
  table = dataset.table table_id

  # Create the table if it doesn't exist.
  unless table
    dataset.create_table table_id do |t|
      t.string "name"
      t.integer "age"
      t.bytes "school"
      t.geography "location"
      t.float "measurements", mode: :repeated
      t.record "datesTime" do |s|
        s.date "day"
        s.datetime "firstTime"
        s.time "secondTime"
        s.timestamp "thirdTime"
      end
    end
    table = dataset.table table_id
  end

  dates_time_content = {
    "day"        => "2019-1-12",
    "firstTime"  => "2019-02-17 11:24:00.000",
    "secondTime" => "14:00:00",
    "thirdTime"  => "2020-04-27T18:07:25.356Z"
  }

  row_content = {
    "name"         => "Tom",
    "age"          => 30,
    "school"       => Base64.strict_encode64("Test University"),
    "location"     => "POINT(1 2)",
    "measurements" => [50.05, 100.5],
    "datesTime"    => dates_time_content
  }

  response = table.insert [row_content]

  if response.success?
    puts "Rows successfully inserted into table"
  else
    puts "Insert operation not performed"
    response.insert_errors.each do |error|
      puts "Error: #{error.errors}"
    end
  end
end
# [END bigquery_inserting_data_types]
