# Copyright 2014 Google Inc. All rights reserved.
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

require "helper"
require "gcloud/datastore/entity"
require "gcloud/datastore/key"

##
# These tests are not part of the public API.
# These tests are testing the implementation.
# Similar to testing private methods.

describe "Proto Cursor methods" do
  let(:raw_cursor) {
      "\x13\xE0\x01\x00\xEB".force_encoding Encoding::ASCII_8BIT }
  let(:encoded_cursor) { "E+ABAOs=" }

  it "encodes the bytestream" do
    encoded_cursor.must_equal Gcloud::Datastore::Proto.encode_cursor(raw_cursor)
  end

  it "decodes the bytestream" do
    raw_cursor.must_equal Gcloud::Datastore::Proto.decode_cursor(encoded_cursor)
  end
end
