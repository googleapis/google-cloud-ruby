# Copyright 2018 Google, Inc
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
require "date"

def set_document project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_set_document]
  city_ref = firestore.doc "cities/LA"

  data = {
    name:    "Los Angeles",
    state:   "CA",
    country: "USA"
  }

  city_ref.set data
  # [END fs_set_document]
  puts "Set data for the LA document in the cities collection."
end

def update_create_if_missing project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_update_create_if_missing]
  city_ref = firestore.doc "cities/LA"
  city_ref.set({ capital: false }, merge: true)
  # [END fs_update_create_if_missing]
  puts "Merged data into the LA document in the cities collection."
end

def set_document_data_types project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_set_document_data_types]
  doc_ref = firestore.doc "data/one"

  data = {
    stringExample:  "Hello, World!",
    booleanExample: true,
    numberExample:  3.14159265,
    dateExample:    DateTime.now,
    arrayExample:   [5, true, "hello"],
    nullExample:    nil,
    objectExample:  {
      a: 5,
      b: true
    }
  }

  doc_ref.set data
  # [END fs_set_document_data_types]
  puts "Set multiple data-type data for the one document in the data collection."
end

def set_requires_id project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  data = {
    name:    "Phuket",
    country: "Thailand"
  }
  # [START fs_set_requires_id]
  city_ref = firestore.doc "cities/new-city-id"
  city_ref.set data
  # [END fs_set_requires_id]
  puts "Added document with ID: new-city-id."
end

def add_doc_data_with_auto_id project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_add_doc_data_with_auto_id]
  data = {
    name:    "Tokyo",
    country: "Japan"
  }

  cities_ref = firestore.col "cities"

  added_doc_ref = cities_ref.add data
  puts "Added document with ID: #{added_doc_ref.document_id}."
  # [END fs_add_doc_data_with_auto_id]
end

def add_doc_data_after_auto_id project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  data = {
    name:    "Moscow",
    country: "Russia"
  }
  # [START fs_add_doc_data_after_auto_id]
  cities_ref = firestore.col "cities"

  added_doc_ref = cities_ref.doc
  puts "Added document with ID: #{added_doc_ref.document_id}."

  added_doc_ref.set data
  # [END fs_add_doc_data_after_auto_id]
  puts "Added data to the #{added_doc_ref.document_id} document in the cities collection."
end

def update_doc project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  doc_ref = firestore.doc "cities/DC"

  data = {
    name:    "Washington D.C.",
    country: "USA"
  }
  doc_ref.set data
  # [START fs_update_doc]
  city_ref = firestore.doc "cities/DC"
  city_ref.update capital: true
  # [END fs_update_doc]
  puts "Updated the capital field of the DC document in the cities collection."
end

def update_nested_fields project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_update_nested_fields]
  # Create an initial document to update
  frank_ref = firestore.doc "users/frank"
  frank_ref.set(
    name:      "Frank",
    favorites: {
      food:    "Pizza",
      color:   "Blue",
      subject: "Recess"
    },
    age:       12
  )

  # Update age and favorite color
  frank_ref.update age: 13, "favorites.color": "Red"
  # [END fs_update_nested_fields]
  puts "Updated the age and favorite color fields of the frank document in the users collection."
end

def update_server_timestamp project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  firestore.doc("cities/new-city-id").set(
    name:       "new city",
    state:      nil,
    country:    "country",
    capital:    false,
    population: 85
  )
  # [START fs_update_server_timestamp]
  city_ref = firestore.doc "cities/new-city-id"
  city_ref.update timestamp: firestore.field_server_time
  # [END fs_update_server_timestamp]
  puts "Updated the timestamp field of the new-city-id document in the cities collection."
end

def update_document_increment project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  firestore.doc("cities/DC").set(
    name:       "Washington D.C.",
    state:      nil,
    country:    "USA",
    capital:    true,
    population: 680_000
  )
  # [START fs_update_document_increment]
  city_ref = firestore.doc "cities/DC"
  city_ref.update population: firestore.field_increment(50)
  # [END fs_update_document_increment]
  puts "Updated the population of the DC document in the cities collection."
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT_ID"]
  case ARGV.shift
  when "set_document"
    set_document project_id: project
  when "update_create_if_missing"
    update_create_if_missing project_id: project
  when "set_document_data_types"
    set_document_data_types project_id: project
  when "set_requires_id"
    set_requires_id project_id: project
  when "add_doc_data_with_auto_id"
    add_doc_data_with_auto_id project_id: project
  when "add_doc_data_after_auto_id"
    add_doc_data_after_auto_id project_id: project
  when "update_doc"
    update_doc project_id: project
  when "update_nested_fields"
    update_nested_fields project_id: project
  when "update_server_timestamp"
    update_server_timestamp project_id: project
  when "update_document_increment"
    update_document_increment project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby add_data.rb [command]

      Commands:
        set_document                Set document data.
        update_create_if_missing    Update a document - create it if it's missing.
        set_document_data_types     Set document data with multiple data types.
        set_requires_id             Set document data with a given document id.
        add_doc_data_with_auto_id   Add document data with autogenerated id.
        add_doc_data_after_auto_id  Generate id, then add document data.
        update_doc                  Update a document.
        update_nested_fields        Update fields in nested data.
        update_server_timestamp     Update field with server timestamp.
        update_document_increment   Update a document number field using Increment.
    USAGE
  end
end
