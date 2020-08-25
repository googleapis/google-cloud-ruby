# Copyright 2020 Google LLC
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

require_relative "helper.rb"
require_relative "../query_data.rb"
require_relative "../transactions_and_batched_writes.rb"

describe "Google Cloud Firestore API samples - Transactions and Batched Writes" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT"]
    @collection_path = random_name "cities"
    # setup for each test
    query_create_examples project_id: @firestore_project, collection_path: @collection_path
  end

  after do # teardown after each test
    delete_collection_test collection_name: @collection_path, project_id: ENV["FIRESTORE_PROJECT"]
  end

  it "run_simple_transaction" do
    out, _err = capture_io do
      run_simple_transaction project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "New population is 860001."
    assert_includes out, "Ran a simple transaction to update the population field in the SF document in the cities " \
                         "collection."
  end

  it "return_info_transaction" do
    out, _err = capture_io do
      return_info_transaction project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Population updated!"
  end

  it "batch_write" do
    out, _err = capture_io do
      batch_write project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Batch write successfully completed."
  end
end
