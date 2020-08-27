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

def retrieve_create_examples project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_retrieve_create_examples]
  cities_ref = firestore.col collection_path
  cities_ref.doc("SF").set(
    name:       "San Francisco",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 860_000
  )
  cities_ref.doc("LA").set(
    name:       "Los Angeles",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 3_900_000
  )
  cities_ref.doc("DC").set(
    name:       "Washington D.C.",
    state:      nil,
    country:    "USA",
    capital:    true,
    population: 680_000
  )
  cities_ref.doc("TOK").set(
    name:       "Tokyo",
    state:      nil,
    country:    "Japan",
    capital:    true,
    population: 9_000_000
  )
  cities_ref.doc("BJ").set(
    name:       "Beijing",
    state:      nil,
    country:    "China",
    capital:    true,
    population: 21_500_000
  )
  # [END fs_retrieve_create_examples]
  puts "Added example cities data to the cities collection."
end

def get_document project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  # [START fs_get_document]
  doc_ref  = firestore.doc "#{collection_path}/SF"
  snapshot = doc_ref.get
  if snapshot.exists?
    puts "#{snapshot.document_id} data: #{snapshot.data}."
  else
    puts "Document #{snapshot.document_id} does not exist!"
  end
  # [END fs_get_document]
end

def get_multiple_docs project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_get_multiple_docs]
  cities_ref = firestore.col collection_path

  query = cities_ref.where "capital", "=", true

  query.get do |city|
    puts "#{city.document_id} data: #{city.data}."
  end
  # [END fs_get_multiple_docs]
end

def get_all_docs project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_get_all_docs]
  cities_ref = firestore.col collection_path
  cities_ref.get do |city|
    puts "#{city.document_id} data: #{city.data}."
  end
  # [END fs_get_all_docs]
end

def add_subcollection project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_add_subcollection]
  city_ref = firestore.doc "#{collection_path}/SF"

  subcollection_ref = city_ref.col "neighborhoods"

  added_doc_ref = subcollection_ref.add name: "Marina"
  puts "Added document with ID: #{added_doc_ref.document_id}."
  # [END fs_add_subcollection]
end

def list_subcollections project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_list_subcollections]
  city_ref = firestore.doc "#{collection_path}/SF"
  city_ref.cols do |col|
    puts col.collection_id
  end
  # [END fs_list_subcollections]
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT"]
  case ARGV.shift
  when "retrieve_create_examples"
    retrieve_create_examples project_id: project
  when "get_document"
    get_document project_id: project
  when "get_multiple_docs"
    get_multiple_docs project_id: project
  when "get_all_docs"
    get_all_docs project_id: project
  when "add_subcollection"
    add_subcollection project_id: project
  when "list_subcollections"
    list_subcollections project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby get_data.rb [command]

      Commands:
        retrieve_create_examples  Create an example collection of documents.
        get_document              Get a document.
        get_multiple_docs         Get multiple documents from a collection.
        get_all_docs              Get all documents from a collection.
        add_subcollection         Add a document to a subcollection.
        list_subcollections       List subcollections of a document.
    USAGE
  end
end
