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

def listen_document project_id:, collection_path: "cities", document_path: "SF"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"
  # document_path = "SF"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_listen_document]
  doc_ref = firestore.col(collection_path).doc document_path
  snapshots = []

  # Watch the document.
  listener = doc_ref.listen do |snapshot|
    puts "Received document snapshot: #{snapshot.document_id}"
    snapshots << snapshot
  end
  # [END firestore_listen_document]

  # Create the document.
  doc_ref.set(
    {
      name:       "San Francisco",
      state:      "CA",
      country:    "USA",
      capital:    false,
      population: 860_000
    }
  )

  # Wait for the callback.
  wait_until { !snapshots.empty? }

  # [START firestore_listen_detach]
  listener.stop
  # [END firestore_listen_detach]
end

def listen_changes project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_listen_query_changes]
  query = firestore.col(collection_path).where :state, :==, "CA"
  added = []
  modified = []
  removed = []

  # Watch the collection query.
  listener = query.listen do |snapshot|
    puts "Callback received query snapshot."
    puts "Current cities in California:"
    snapshot.changes.each do |change|
      if change.added?
        puts "New city: #{change.doc.document_id}"
        added << snapshot
      elsif change.modified?
        puts "Modified city: #{change.doc.document_id}"
        modified << snapshot
      elsif change.removed?
        puts "Removed city: #{change.doc.document_id}"
        removed << snapshot
      end
    end
  end
  # [END firestore_listen_query_changes]

  mtv_doc = firestore.col(collection_path).doc("MTV")

  # Create the document.
  mtv_doc.set(
    {
      name:       "Mountain View",
      state:      "CA",
      country:    "USA",
      capital:    false,
      population: 80_000
    }
  )

  wait_until { !added.empty? }

  # Update the document.
  mtv_doc.update(
    {
      name:       "Mountain View",
      state:      "CA",
      country:    "USA",
      capital:    false,
      population: 90_000
    }
  )

  wait_until { !modified.empty? }

  # Delete the document.
  mtv_doc.delete exists: true

  wait_until { !removed.empty? }

  listener.stop
end

def listen_errors project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_listen_handle_error]
  listener = firestore.col(collection_path).listen do |snapshot|
    snapshot.changes.each do |change|
      puts "New city: #{change.doc.document_id}" if change.added?
    end
  end

  # Register to be notified when unhandled errors occur.
  listener.on_error do |error|
    puts "Listen failed: #{error.message}"
  end
  # [END firestore_listen_handle_error]

  listener.stop
end

def listen_multiple project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_listen_query_snapshots]
  query = firestore.col(collection_path).where :state, :==, "CA"
  docs = []

  # Watch the collection query.
  listener = query.listen do |snapshot|
    puts "Callback received query snapshot."
    puts "Current cities in California:"
    snapshot.docs.each do |doc|
      puts doc.document_id
      docs << doc
    end
  end
  # [END firestore_listen_query_snapshots]

  # Create the document.
  firestore.col(collection_path).doc("SF").set(
    {
      name:       "San Francisco",
      state:      "CA",
      country:    "USA",
      capital:    false,
      population: 860_000
    }
  )

  # Wait for the callback.
  wait_until { !docs.empty? }

  listener.stop
end

def wait_until &block
  wait_count = 0
  until block.call
    raise "wait_until criteria was not met." if wait_count > 6
    wait_count += 1
    sleep (2**wait_count) + rand(0..wait_count)
  end
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT"]
  case ARGV.shift
  when "listen_document"
    listen_document project_id: project
  when "listen_changes"
    listen_changes project_id: project
  when "listen_multiple"
    listen_multiple project_id: project
  when "listen_errors"
    listen_errors project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby query_data.rb [command]

      Commands:
        listen_document  Listen for changes to a document.
        listen_changes   Listen for changes to a query.
        listen_multiple  Listen for changes to a query, returning the names of all cities for a state.
        listen_errors    Handle listening errors.
    USAGE
  end
end
