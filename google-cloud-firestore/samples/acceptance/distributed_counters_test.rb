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
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    create_counter project_id: @firestore_project, num_shards: 5
  end

  after do
    delete_collection_test collection_name: "shards", project_id: ENV["FIRESTORE_PROJECT_ID"]
  end

  it "create_counter" do
    out, _err = capture_io do
      create_counter project_id: @firestore_project, num_shards: 5
    end
    assert_includes out, "Distributed counter shards collection created."
  end

  it "get_document" do
    create_counter project_id: @firestore_project, num_shards: 5
    out, _err = capture_io do
      increment_counter project_id: @firestore_project, num_shards: 5
    end
    assert_includes out, "Counter incremented."
  end

  it "get_count" do
    create_counter project_id: @firestore_project, num_shards: 5
    increment_counter project_id: @firestore_project, num_shards: 5
    increment_counter project_id: @firestore_project, num_shards: 5

    out, _err = capture_io do
      get_count project_id: @firestore_project
    end
    assert_includes out, "Count value is 2."
  end
end
