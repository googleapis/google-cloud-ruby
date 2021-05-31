# Copyright 2021 Google LLC
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

describe Google::Cloud::Firestore::ResourcePath do
  let(:project_id) { "my-project" }
  let(:database_id) { "my-database" }
  let(:doc_id_a) { "alice" }
  let(:doc_id_b) { "alice-" }
  let(:doc_id_c) { "bob" }
  let(:path_a) { "projects/#{project_id}/databases/(default)/documents/users/#{doc_id_a}/pets" }
  let(:path_b) { "projects/#{project_id}/databases/(default)/documents/users/#{doc_id_b}/pets" }
  let(:path_c) { "projects/#{project_id}/databases/(default)/documents/users/#{doc_id_c}/pets" }
  let(:path_d) { "projects/#{project_id}/databases/(default)/documents/users/#{doc_id_c}" }
  let(:resource_path_a) { Google::Cloud::Firestore::ResourcePath.from_path path_a }
  let(:resource_path_b) { Google::Cloud::Firestore::ResourcePath.from_path path_b }
  let(:resource_path_c) { Google::Cloud::Firestore::ResourcePath.from_path path_c }
  let(:resource_path_d) { Google::Cloud::Firestore::ResourcePath.from_path path_d }

  describe String, "<=>" do
    it "correctly compares isolated resource IDs" do
      # "alice" should come before "alice-"
      _(doc_id_a.<=>(doc_id_b)).must_equal -1
    end
    it "incorrectly compares the resource ID, because full paths are sorted dash before slash" do
      # "alice-" should not come before "alice"
      _(path_a.<=>(path_b)).must_equal 1
    end
  end

  it "parses project_id" do
    _(resource_path_a.project_id).must_equal project_id
  end

  it "parses default database_id" do
    _(resource_path_a.database_id).must_equal "(default)"
  end

  it "compares a dashed document ID reference" do
    _(resource_path_a.<=>(resource_path_b)).must_equal -1
  end

  it "compares a simple document ID reference" do
    _(resource_path_a.<=>(resource_path_c)).must_equal -1
  end
end
