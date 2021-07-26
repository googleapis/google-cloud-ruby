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

describe Google::Cloud::Firestore::FieldPath do
  describe :quote_field_path do
    it "does not quote simple characters" do
      field_path = Google::Cloud::Firestore::FieldPath.new "bakt1k_"
      _(field_path.formatted_string).must_equal "bakt1k_"
    end

    it "does not quote a heading _ (underbar)" do
      field_path = Google::Cloud::Firestore::FieldPath.new "_baktik"
      _(field_path.formatted_string).must_equal "_baktik"
    end

    it "does not quote a heading upper case letter" do
      field_path = Google::Cloud::Firestore::FieldPath.new "Baktik"
      _(field_path.formatted_string).must_equal "Baktik"
    end

    it "quotes a heading number character" do
      field_path = Google::Cloud::Firestore::FieldPath.new "0baktik"
      _(field_path.formatted_string).must_equal "`0baktik`"
    end

    it "escapes a backquote and a backslash" do
      field_path = Google::Cloud::Firestore::FieldPath.new "bak`tik\\"
      _(field_path.formatted_string).must_equal "`bak\\`tik\\\\`"
    end

    it "quotes non-simple characters" do
      field_path = Google::Cloud::Firestore::FieldPath.new "bak-tik~"
      _(field_path.formatted_string).must_equal "`bak-tik~`"
    end
  end
end
