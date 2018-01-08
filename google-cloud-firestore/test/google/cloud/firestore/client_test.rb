# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Firestore::Client, :mock_firestore do
  it "knows the project and database identifiers" do
    firestore.must_be_kind_of Google::Cloud::Firestore::Client
    firestore.project_id.must_equal project
    firestore.database_id.must_equal "(default)"
    firestore.path.must_equal "projects/projectID/databases/(default)"
  end
end
