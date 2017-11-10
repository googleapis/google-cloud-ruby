# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Language, :default_encoding, :mock_language do
  it "detects the default encoding" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT)
    features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
      extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
    grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json

    mock = Minitest::Mock.new
    mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

    language.service.mocked_service = mock
    annotation = language.annotate text_content
    mock.verify

    annotation.must_be_kind_of Google::Cloud::Language::Annotation
  end

  it "uses UTF8 when the internal encoding is nil" do
    Encoding.stub :default_internal, nil do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate text_content
      mock.verify

      annotation.must_be_kind_of Google::Cloud::Language::Annotation
    end
  end

  it "uses UTF8 when the internal encoding is ISO-8859-1" do
    Encoding.stub :default_internal, Encoding::ISO_8859_1 do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate text_content
      mock.verify

      annotation.must_be_kind_of Google::Cloud::Language::Annotation
    end
  end

  it "uses UTF8 when the internal encoding is US-ASCII" do
    Encoding.stub :default_internal, Encoding::US_ASCII do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate text_content
      mock.verify

      annotation.must_be_kind_of Google::Cloud::Language::Annotation
    end
  end

  it "uses UTF8 when the internal encoding is UTF-8" do
    Encoding.stub :default_internal, Encoding::UTF_8 do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate text_content
      mock.verify

      annotation.must_be_kind_of Google::Cloud::Language::Annotation
    end
  end

  it "uses UTF16 when the internal encoding is UTF-16" do
    Encoding.stub :default_internal, Encoding::UTF_16 do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF16, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate text_content
      mock.verify

      annotation.must_be_kind_of Google::Cloud::Language::Annotation
    end
  end

  it "uses UTF32 when the internal encoding is UTF-32" do
    Encoding.stub :default_internal, Encoding::UTF_32 do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF32, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate text_content
      mock.verify

      annotation.must_be_kind_of Google::Cloud::Language::Annotation
    end
  end

end
