# Copyright 2018 Google LLC
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

describe Google::Cloud::Firestore::FieldValue do
  describe :array_union do
    it "represents values to add to an array" do
      field_union = Google::Cloud::Firestore::FieldValue.array_union 1, 2, 3
      field_union.must_be_kind_of Google::Cloud::Firestore::FieldValue
      field_union.type.must_equal :array_union
      field_union.values.must_equal [1, 2, 3]
    end

    it "does not allow nested FieldValues" do
      field_delete = Google::Cloud::Firestore::FieldValue.array_delete 42
      err = assert_raises ArgumentError do
        Google::Cloud::Firestore::FieldValue.array_union 1, 2, 3, field_delete
      end
      err.message.must_equal "A value of type Google::Cloud::Firestore::FieldValue is not supported."
    end
  end

  describe :array_delete do
    it "represents values to remove from an array" do
      field_delete = Google::Cloud::Firestore::FieldValue.array_delete 7, 8, 9
      field_delete.must_be_kind_of Google::Cloud::Firestore::FieldValue
      field_delete.type.must_equal :array_delete
      field_delete.values.must_equal [7, 8, 9]
    end

    it "does not allow nested FieldValues" do
      field_union = Google::Cloud::Firestore::FieldValue.array_union 42
      err = assert_raises ArgumentError do
        Google::Cloud::Firestore::FieldValue.array_delete 7, 8, 9, field_union
      end
      err.message.must_equal "A value of type Google::Cloud::Firestore::FieldValue is not supported."
    end
  end
end
