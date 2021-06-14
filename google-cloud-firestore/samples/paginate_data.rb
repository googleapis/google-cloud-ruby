# Copyright 2020 Google, Inc
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

require "google/cloud/firestore"

def start_at_field_query_cursor project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START firestore_query_cursor_start_at_field_value_single]
  query = cities_ref.order("population").start_at(1_000_000)
  # [END firestore_query_cursor_start_at_field_value_single]
  query.get do |city|
    puts "Document #{city.document_id} returned by start at population 1000000 field query cursor."
  end
end

def end_at_field_query_cursor project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START firestore_query_cursor_end_at_field_value_single]
  query = cities_ref.order("population").end_at(1_000_000)
  # [END firestore_query_cursor_end_at_field_value_single]
  query.get do |city|
    puts "Document #{city.document_id} returned by end at population 1000000 field query cursor."
  end
end

def paginated_query_cursor project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  # [START firestore_query_cursor_pagination]
  cities_ref  = firestore.col collection_path
  first_query = cities_ref.order("population").limit(3)

  # Get the last document from the results.
  last_population = 0
  first_query.get do |city|
    last_population = city.data[:population]
  end

  # Construct a new query starting at this document.
  # Note: this will not have the desired effect if multiple cities have the exact same population value.
  second_query = cities_ref.order("population").start_after(last_population)
  second_query.get do |city|
    puts "Document #{city.document_id} returned by paginated query cursor."
  end
  # [END firestore_query_cursor_pagination]
end

def multiple_cursor_conditions project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START firestore_query_cursor_start_at_field_value_multi]
  # Will return all Springfields
  query1 = firestore.col(collection_path).order("name").order("state").start_at("Springfield")

  # Will return "Springfield, Missouri" and "Springfield, Wisconsin"
  query2 = firestore.col(collection_path).order("name").order("state").start_at(["Springfield", "Missouri"])
  # [END firestore_query_cursor_start_at_field_value_multi]
  query1.get do |city|
    puts "Document #{city.document_id} returned by start at Springfield query."
  end
  query2.get do |city|
    puts "Document #{city.document_id} returned by start at Springfield, Missouri query."
  end
end

def start_at_snapshot_query_cursor project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START firestore_query_cursor_start_at_document]
  doc_ref = firestore.doc "#{collection_path}/SF"
  snapshot = doc_ref.get
  query = cities_ref.order("population").start_at(snapshot)
  # [END firestore_query_cursor_start_at_document]
  query.get do |city|
    puts "Document #{city.document_id} returned by start at document snapshot query cursor."
  end
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT"]
  case ARGV.shift
  when "start_at_field_query_cursor"
    start_at_field_query_cursor project_id: project
  when "end_at_field_query_cursor"
    end_at_field_query_cursor project_id: project
  when "paginated_query_cursor"
    paginated_query_cursor project_id: project
  when "multiple_cursor_conditions"
    multiple_cursor_conditions project_id: project
  when "start_at_snapshot_query_cursor"
    start_at_snapshot_query_cursor project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby paginate_data.rb [command]

      Commands:
        start_at_field_query_cursor  Define field start point for a query.
        end_at_field_query_cursor    Define field end point for a query.
        paginated_query_cursor       Paginate using query cursors.
        multiple_cursor_conditions   Set multiple cursor conditions.
        start_at_snapshot_query_cursor  Define document snapshot start point for a query.
    USAGE
  end
end
