# Copyright 2020 Google LLC
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

describe Google::Cloud::Storage::File::SignerV4, :escape_characters do
  let(:signer_v4) { Google::Cloud::Storage::File::SignerV4.new nil, nil, nil }

  it "escapes special unicode character é" do
    str = signer_v4.escape_characters "é"
    _(str).must_equal '\u00e9'
  end

  it "escapes a backslash" do
    str = signer_v4.escape_characters "\\"
    _(str).must_equal '\\'
  end

  it "escapes a backspace" do
    str = signer_v4.escape_characters "\b"
    _(str).must_equal '\b'
  end

  it "escapes a form feed" do
    str = signer_v4.escape_characters "\f"
    _(str).must_equal '\f'
  end

  it "escapes a new line" do
    str = signer_v4.escape_characters "\n"
    _(str).must_equal '\n'
  end

  it "escapes a carriage return" do
    str = signer_v4.escape_characters "\r"
    _(str).must_equal '\r'
  end

  it "escapes a horizontal tab" do
    str = signer_v4.escape_characters "\t"
    _(str).must_equal '\t'
  end

  it "escapes a vertical tab" do
    str = signer_v4.escape_characters "\v"
    _(str).must_equal '\v'
  end

  it "escapes a dollar symbol" do
    str = signer_v4.escape_characters "$"
    _(str).must_equal '$'
  end

  it "escapes only special characters in a string" do
    str = signer_v4.escape_characters "{\"x-goog-meta\":\"$test-object-é-meta\\data\b\f\n\r\t\v\"},"
    _(str).must_equal '{"x-goog-meta":"$test-object-\u00e9-meta\\data\b\f\n\r\t\v"},'
  end
end
