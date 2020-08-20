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
require "date"

def delete_doc project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_delete_doc]
  city_ref = firestore.doc "cities/DC"
  city_ref.delete
  # [END fs_delete_doc]
  puts "Deleted the DC document in the cities collection."
end

def delete_field project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_delete_field]
  city_ref = firestore.doc "cities/BJ"
  city_ref.update capital: firestore.field_delete
  # [END fs_delete_field]
  puts "Deleted the capital field from the BJ document in the cities collection."
end

def delete_collection project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_delete_collection]
  cities_ref = firestore.col "cities"
  query      = cities_ref

  query.get do |document_snapshot|
    puts "Deleting document #{document_snapshot.document_id}."
    document_ref = document_snapshot.ref
    document_ref.delete
  end
  # [END fs_delete_collection]
  puts "Finished deleting all documents from the collection."
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT_ID"]
  case ARGV.shift
  when "delete_doc"
    delete_doc project_id: project
  when "delete_field"
    delete_field project_id: project
  when "delete_collection"
    delete_collection project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby delete_data.rb [command]

      Commands:
        delete_doc         Delete a document.
        delete_field       Delete a field.
        delete_collection  Delete an entire collection.
    USAGE
  end
end
