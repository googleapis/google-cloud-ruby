# Copyright 2016 Google Inc. All rights reserved.
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

describe Google::Cloud::Language::Document, :mock_language do
  it "can change formats" do
    doc = language.document "Hello world!"
    doc.must_be_kind_of Google::Cloud::Language::Document

    # It knows it is plain text and not HTML
    doc.must_be :text?
    doc.wont_be :html?
    doc.format.must_equal :text

    # It can change format to HTML
    doc.format = "html"
    doc.must_be :html?
    doc.wont_be :text?
    doc.format.must_equal :html

    # It can change back to plain text
    doc.format = :text
    doc.must_be :text?
    doc.wont_be :html?
    doc.format.must_equal :text

    # It can change format to HTML using the helper
    doc.html!
    doc.must_be :html?
    doc.wont_be :text?
    doc.format.must_equal :html

    # It can change back to plain text using the helper
    doc.text!
    doc.must_be :text?
    doc.wont_be :html?
    doc.format.must_equal :text
  end

  it "knows if it is content vs. GCS URL" do
    doc = language.document "Hello world!"
    doc.must_be_kind_of Google::Cloud::Language::Document

    # These are private methods
    doc.must_be :content?
    doc.wont_be :url?
    doc.must_be :text?
    doc.wont_be :html?
  end

  it "knows if it is a GCS URL vs. content" do
    doc = language.document "gs://bucket/path.ext"
    doc.must_be_kind_of Google::Cloud::Language::Document

    # These are private methods
    doc.must_be :url?
    doc.wont_be :content?
    doc.must_be :text?
    doc.wont_be :html?
  end

  it "can set the HTML format for a GCS URL" do
    doc = language.document "gs://bucket/path.ext", format: :html
    doc.must_be_kind_of Google::Cloud::Language::Document

    # These are private methods
    doc.must_be :url?
    doc.wont_be :content?
    doc.must_be :html?
    doc.wont_be :text?
  end

  it "can derrive the HTML format from a GCS URL ending in .html" do
    doc = language.document "gs://bucket/path.html"
    doc.must_be_kind_of Google::Cloud::Language::Document

    # These are private methods
    doc.must_be :url?
    doc.wont_be :content?
    doc.must_be :html?
    doc.wont_be :text?
  end

  it "can change languages" do
    doc = language.document "Hello world!"
    doc.must_be_kind_of Google::Cloud::Language::Document

    # The default language is an empty string
    doc.language.must_equal ""

    # It can set language as a symbol
    doc.language = :en
    doc.language.must_equal "en"

    # It can set language as a string
    doc.language = "jp"
    doc.language.must_equal "jp"

    # It can set language to nil
    doc.language = nil
    doc.language.must_equal ""
  end
end
