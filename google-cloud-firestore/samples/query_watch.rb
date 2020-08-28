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

def listen_document project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_listen_document]

  # Create an Event for notifying main thread.
  require "concurrent"
  event = Concurrent::Event.new

  doc_ref = firestore.col(collection_path).doc "SF"

  # Watch the document.
  listener = doc_ref.listen do |snapshot|
    puts "Received document snapshot: #{snapshot.document_id}"
    event.set
  end
  # [END fs_listen_document]

  # Create the document.
  doc_ref.set(
    name:       "San Francisco",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 860_000
  )
  # Wait for the callback.
  event.wait 60

  # [START fs_detach_listener]
  listener.stop
  # [END fs_detach_listener]
end

def listen_changes project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_listen_changes]

  # Create an Event for notifying main thread.
  require "concurrent"
  event = Concurrent::Event.new

  query = firestore.col(collection_path).where :state, :==, "CA"

  # Watch the collection query.
  listener = query.listen do |snapshot|
    puts "Callback received query snapshot."
    puts "Current cities in California:"
    snapshot.changes.each do |change|
      if change.added?
        puts "New city: #{change.doc.document_id}"
      elsif change.modified?
        puts "Modified city: #{change.doc.document_id}"
      elsif change.removed?
        puts "Removed city: #{change.doc.document_id}"
        event.set
      end
    end
  end
  # [END fs_listen_changes]

  mtv_doc = firestore.col(collection_path).doc("MTV")

  # Create the document.
  mtv_doc.set(
    name:       "Mountain View",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 80_000
  )

  sleep 1

  # Update the document.
  mtv_doc.update(
    name:       "Mountain View",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 90_000
  )

  sleep 1

  # Delete the document.
  mtv_doc.delete exists: true

  # Wait for the callback that captures the deletion.
  event.wait 60
  listener.stop
end

def listen_multiple project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START fs_listen_multiple]

  # Create an Event for notifying main thread.
  require "concurrent"
  event = Concurrent::Event.new

  query = firestore.col(collection_path).where :state, :==, "CA"

  # Watch the collection query.
  listener = query.listen do |snapshot|
    puts "Callback received query snapshot."
    puts "Current cities in California:"
    snapshot.docs.each do |doc|
      puts doc.document_id
      event.set
    end
  end
  # [END fs_listen_multiple]

  # Create the document.
  firestore.col(collection_path).doc("SF").set(
    name:       "San Francisco",
    state:      "CA",
    country:    "USA",
    capital:    false,
    population: 860_000
  )
  # Wait for the callback.
  event.wait 60
  listener.stop
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
