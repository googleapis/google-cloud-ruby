# Copyright 2021 Google LLC
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

# [START bigquery_insert_geography_wkt]
require "google/cloud/bigquery"
require "rgeo"

def insert_geography_wkt dataset_id = "your_dataset_id", table_id = "your_table_id"
  bigquery = Google::Cloud::Bigquery.new
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  # Use the RGeo library to generate WKT of a line from LAX to
  # JFK airports. Alternatively, you may define WKT data directly.
  factory = RGeo::Geographic.spherical_factory
  my_line = factory.line_string([factory.point(-118.4085, 33.9416), factory.point(-73.7781, 40.6413)])
  row_data = [
    # Convert data into a WKT string: "LINESTRING (-118.4085 33.9416, -73.7781 40.6413)"
    { geo: my_line.as_text }
  ]

  # Table already exists and has a column named "geo" with data type GEOGRAPHY.
  response = table.insert row_data

  if response.success?
    puts "Inserted GEOGRAPHY WKT row successfully"
  else
    puts "GEOGRAPHY WKT row insert failed: #{response.error_rows.first&.errors}"
  end
end
# [END bigquery_insert_geography_wkt]
