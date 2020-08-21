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

def document_ref project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_document_ref]
  document_ref = firestore.col("users").doc("alovelace")
  # [END fs_document_ref]
end

def collection_ref project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_collection_ref]
  collection_ref = firestore.col "users"
  # [END fs_collection_ref]
end

def document_path_ref project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_document_path_ref]
  document_path_ref = firestore.doc "users/alovelace"
  # [END fs_document_path_ref]
end

def subcollection_ref project_id:
  # project_id = "Your Google Cloud Project ID"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_subcollection_ref]
  message_ref = firestore.col("rooms").doc("roomA").col("messages").doc("message1")
  # [END fs_subcollection_ref]
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT"]
  case ARGV.shift
  when "document_ref"
    document_ref project_id: project
  when "collection_ref"
    collection_ref project_id: project
  when "document_path_ref"
    document_path_ref project_id: project
  when "subcollection_ref"
    subcollection_ref project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby data_model.rb [command]

      Commands:
        document_ref       Create a document reference.
        collection_ref     Create a collection reference.
        document_path_ref  Create a document path reference.
        subcollection_ref  Create a subcollection reference.
    USAGE
  end
end
