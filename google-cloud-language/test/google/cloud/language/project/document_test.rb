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

describe Google::Cloud::Language::Project, :document, :mock_language do
  it "builds a document from content" do
    doc = language.document "Hello world!"
    doc.must_be_kind_of Google::Cloud::Language::Document
    doc.must_be :content? # private method
    doc.wont_be :url? # private method
    doc.must_be :text? # private method
    doc.wont_be :html? # private method
    doc.source.must_equal "Hello world!" # private method
  end

  it "builds a document from URL" do
    doc = language.document "gs://bucket/path.txt"
    doc.must_be_kind_of Google::Cloud::Language::Document
    doc.must_be :url? # private method
    doc.wont_be :content? # private method
    doc.must_be :text? # private method
    doc.wont_be :html? # private method
    doc.source.must_equal "gs://bucket/path.txt" # private method
  end

  it "builds a document from Storage File object" do
    fake = OpenStruct.new to_gs_url: "gs://bucket/path.txt"
    doc = language.document fake
    doc.must_be_kind_of Google::Cloud::Language::Document
    doc.must_be :url? # private method
    doc.wont_be :content? # private method
    doc.must_be :text? # private method
    doc.wont_be :html? # private method
    doc.source.must_equal "gs://bucket/path.txt" # private method
  end

  it "sets the format of the URL when provided" do
    doc = language.document "gs://bucket/path.ext", format: :html
    doc.must_be_kind_of Google::Cloud::Language::Document
    doc.must_be :url? # private method
    doc.wont_be :content? # private method
    doc.must_be :html? # private method
    doc.wont_be :text? # private method
    doc.source.must_equal "gs://bucket/path.ext" # private method
  end

  it "derives HTML format if the URL ends in .html" do
    doc = language.document "gs://bucket/path.html"
    doc.must_be_kind_of Google::Cloud::Language::Document
    doc.must_be :url? # private method
    doc.wont_be :content? # private method
    doc.must_be :html? # private method
    doc.wont_be :text? # private method
    doc.source.must_equal "gs://bucket/path.html" # private method
  end

  it "builds a document from another document, while maintaining formats" do
    doc1 = language.document "<b>Hello world!</b>", format: :html
    doc1.must_be_kind_of Google::Cloud::Language::Document
    doc1.must_be :html?
    doc1.source.must_equal "<b>Hello world!</b>" # private method

    doc2 = language.document doc1
    doc2.must_be_kind_of Google::Cloud::Language::Document
    doc2.must_be :html?
    doc2.source.must_equal "<b>Hello world!</b>" # private method
  end

  it "builds a document from another document, while switching formats" do
    doc1 = language.document "<b>Hello world!</b>", format: :text
    doc1.must_be_kind_of Google::Cloud::Language::Document
    doc1.must_be :text?
    doc1.source.must_equal "<b>Hello world!</b>" # private method

    doc2 = language.document doc1, format: :html
    doc2.must_be_kind_of Google::Cloud::Language::Document
    doc2.must_be :html?
    doc2.source.must_equal "<b>Hello world!</b>" # private method
  end

  it "builds a document from another document, while maintaining language" do
    doc1 = language.document "Hello world!", language: :en
    doc1.must_be_kind_of Google::Cloud::Language::Document
    doc1.language.must_equal "en"

    doc2 = language.document doc1
    doc2.must_be_kind_of Google::Cloud::Language::Document
    doc2.language.must_equal "en"
  end

  it "builds a document from another document, while switching languages" do
    doc1 = language.document "Hello world!", language: :en
    doc1.must_be_kind_of Google::Cloud::Language::Document
    doc1.language.must_equal "en"

    doc2 = language.document doc1, language: :jp
    doc2.must_be_kind_of Google::Cloud::Language::Document
    doc2.language.must_equal "jp"
  end
end
