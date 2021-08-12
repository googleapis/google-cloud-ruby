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

# [START bigquery_insert_geojson]
require "google/cloud/bigquery"
require "rgeo"
require "rgeo/geo_json"

def insert_geojson dataset_id = "your_dataset_id", table_id = "your_table_id"
  bigquery = Google::Cloud::Bigquery.new
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  # Use the RGeo library to generate GeoJSON of a line from LAX to
  # JFK airports. Alternatively, you may define GeoJSON data directly, but it
  # must be converted to a string before loading it into BigQuery.
  factory = RGeo::Geographic.spherical_factory
  my_line = factory.line_string([factory.point(-118.4085, 33.9416), factory.point(-73.7781, 40.6413)])
  row_data = [
    # Convert GeoJSON data into a string.
    { geo: RGeo::GeoJSON.encode(my_line).to_json }
  ]

  # Table already exists and has a column named "geo" with data type GEOGRAPHY.
  response = table.insert row_data

  if response.success?
    puts "Inserted GeoJSON row successfully"
  else
    puts "GeoJSON row insert failed: #{response.error_rows.first&.errors}"
  end
end
# [END bigquery_insert_geojson]
