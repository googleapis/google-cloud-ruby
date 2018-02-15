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

describe Google::Cloud::Firestore::Convert, :write_for_delete do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  let(:document_path) { "projects/projectID/databases/(default)/documents/C/d" }

  it "delete with exists precondition" do
    expected_write = Google::Firestore::V1beta1::Write.new(
      delete: document_path,
      current_document: Google::Firestore::V1beta1::Precondition.new(exists: true)
    )

    actual_write = Google::Cloud::Firestore::Convert.write_for_delete document_path, exists: true

    actual_write.must_equal expected_write
  end

  it "delete without precondition" do
    expected_write = Google::Firestore::V1beta1::Write.new(
      delete: document_path
    )

    actual_write = Google::Cloud::Firestore::Convert.write_for_delete document_path

    actual_write.must_equal expected_write
  end

  it "delete with last-update-time precondition" do
    delete_time = Time.now - 42 #42 seconds ago

    expected_write = Google::Firestore::V1beta1::Write.new(
      delete: document_path,
      current_document: Google::Firestore::V1beta1::Precondition.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(delete_time))
    )

    actual_write = Google::Cloud::Firestore::Convert.write_for_delete document_path, update_time: delete_time
  end
end
