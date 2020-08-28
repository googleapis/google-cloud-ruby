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
require_relative "../distributed_counters.rb"

describe "Google Cloud Firestore API samples - Distributed Counter" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT"]
    @collection_path = random_name "shards"
  end

  after do
    delete_collection_test collection_name: @collection_path, project_id: ENV["FIRESTORE_PROJECT"]
  end

  it "create_counter, get_document, get_count" do
    out, _err = capture_io do
      create_counter project_id: @firestore_project, num_shards: 5, collection_path: @collection_path
    end
    assert_includes out, "Distributed counter shards collection created."

    out, _err = capture_io do
      increment_counter project_id: @firestore_project, num_shards: 5, collection_path: @collection_path
    end
    assert_includes out, "Counter incremented."

    out, _err = capture_io do
      increment_counter project_id: @firestore_project, num_shards: 5, collection_path: @collection_path
    end
    assert_includes out, "Counter incremented."

    out, _err = capture_io do
      get_count project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Count value is 2."
  end
end
