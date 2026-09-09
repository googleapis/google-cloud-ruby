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

def run_simple_transaction project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_transaction_document_update]
  city_ref = firestore.doc "#{collection_path}/SF"

  firestore.transaction do |tx|
    new_population = tx.get(city_ref).data[:population] + 1
    puts "New population is #{new_population}."
    tx.update city_ref, { population: new_population }
  end
  # [END firestore_transaction_document_update]
  puts "Ran a simple transaction to update the population field in the SF document in the cities collection."
end

def return_info_transaction project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_transaction_document_update_conditional]
  city_ref = firestore.doc "#{collection_path}/SF"

  updated = firestore.transaction do |tx|
    new_population = tx.get(city_ref).data[:population] + 1
    if new_population < 1_000_000
      tx.update city_ref, { population: new_population }
      true
    end
  end

  if updated
    puts "Population updated!"
  else
    puts "Sorry! Population is too big."
  end
  # [END firestore_transaction_document_update_conditional]
end

def batch_write project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_data_batch_writes]
  firestore.batch do |b|
    # Set the data for NYC
    b.set "#{collection_path}/NYC", { name: "New York City" }

    # Update the population for SF
    b.update "#{collection_path}/SF", { population: 1_000_000 }

    # Delete LA
    b.delete "#{collection_path}/LA"
  end
  # [END firestore_data_batch_writes]
  puts "Batch write successfully completed."
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT"]
  case ARGV.shift
  when "run_simple_transaction"
    run_simple_transaction project_id: project
  when "return_info_transaction"
    return_info_transaction project_id: project
  when "batch_write"
    batch_write project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby transactions_and_batched_writes.rb [command]

      Commands:
        run_simple_transaction   Run a simple transaction.
        return_info_transaction  Run a transaction and get information returned.
        batch_write              Perform a batch write.
    USAGE
  end
end
