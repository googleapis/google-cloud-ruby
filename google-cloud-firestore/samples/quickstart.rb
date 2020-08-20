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

def initialize_firestore_client project_id:
  # [START fs_initialize]
  require "google/cloud/firestore"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  puts "Created Cloud Firestore client with given project ID."
  # [END fs_initialize]
end

def add_data_1 project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_add_data_1]
  doc_ref = firestore.doc "users/alovelace"

  doc_ref.set(
    first: "Ada",
    last:  "Lovelace",
    born:  1815
  )

  puts "Added data to the alovelace document in the users collection."
  # [END fs_add_data_1]
end

def add_data_2 project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_add_data_2]
  doc_ref = firestore.doc "users/aturing"

  doc_ref.set(
    first:  "Alan",
    middle: "Mathison",
    last:   "Turing",
    born:   1912
  )

  puts "Added data to the aturing document in the users collection."
  # [END fs_add_data_2]
end

def get_all project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_get_all]
  users_ref = firestore.col "users"
  users_ref.get do |user|
    puts "#{user.document_id} data: #{user.data}."
  end
  # [END fs_get_all]
end


if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT_ID"]
  case ARGV.shift
  when "initialize"
    initialize_firestore_client project_id: project
  when "add_data_1"
    add_data_1 project_id: project
  when "add_data_2"
    add_data_2 project_id: project
  when "get_all"
    get_all project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby quickstart.rb [command]

      Commands:
        initialize  Initialize a Cloud Firestore client.
        add_data_1  Add a sample document to a collection.
        add_data_2  Add a sample document.
        get_all     Retrieve all documents from a collection.
    USAGE
  end
end
