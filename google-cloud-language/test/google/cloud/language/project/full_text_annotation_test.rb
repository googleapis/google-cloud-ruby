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

describe Google::Cloud::Language::Project, :full_text_annotation, :mock_language do
  describe "inline content" do
    it "runs full annotation with content and empty options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate text_content
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and TEXT format options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate text_content, format: :text
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and TEXT format and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate text_content, format: :text, language: :en
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate text_content, language: :en
      mock.verify

      assert_text_annotation annotation
    end
  end

  describe "document object" do
    it "runs full annotation with document object using empty options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document text_content
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using TEXT format options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document text_content, format: :text
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using TEXT format and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document text_content, format: :text, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        content: text_content, type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document text_content, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    describe "using #text helper" do
      it "runs full annotation using empty options" do
        grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
          content: text_content, type: :PLAIN_TEXT)
        features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

        language.service.mocked_service = mock
        doc = language.text text_content
        annotation = language.annotate doc
        mock.verify

        assert_text_annotation annotation
      end

      it "runs full annotation using en language options" do
        grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
          content: text_content, type: :PLAIN_TEXT, language: "en")
        features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

        language.service.mocked_service = mock
        doc = language.text text_content, language: :en
        annotation = language.annotate doc
        mock.verify

        assert_text_annotation annotation
      end
    end
  end

  describe "inline URL" do
    it "runs full annotation with content and empty options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate "gs://bucket/path.ext"
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and TEXT format options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate "gs://bucket/path.ext", format: :text
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and TEXT format and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate "gs://bucket/path.ext", format: :text, language: :en
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      annotation = language.annotate "gs://bucket/path.ext", language: :en
      mock.verify

      assert_text_annotation annotation
    end
  end

  describe "document URL object" do
    it "runs full annotation with document object using empty options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document "gs://bucket/path.ext"
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using TEXT format options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document "gs://bucket/path.ext", format: :text
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using TEXT format and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document "gs://bucket/path.ext", format: :text, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      doc = language.document "gs://bucket/path.ext", language: :en
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    describe "using #text helper" do
      it "runs full annotation using empty options" do
        grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
        features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

        language.service.mocked_service = mock
        doc = language.text "gs://bucket/path.ext"
        annotation = language.annotate doc
        mock.verify

        assert_text_annotation annotation
      end

      it "runs full annotation using en language options" do
        grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
        features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

        language.service.mocked_service = mock
        doc = language.text "gs://bucket/path.ext", language: :en
        annotation = language.annotate doc
        mock.verify

        assert_text_annotation annotation
      end
    end
  end

  describe "inline GCS object" do
    it "runs full annotation with content and empty options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      annotation = language.annotate gcs_fake
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and TEXT format options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      annotation = language.annotate gcs_fake, format: :text
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and TEXT format and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      annotation = language.annotate gcs_fake, format: :text, language: :en
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with content and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      annotation = language.annotate gcs_fake, language: :en
      mock.verify

      assert_text_annotation annotation
    end
  end

  describe "document GSC object" do
    it "runs full annotation with document object using empty options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      doc = language.document gcs_fake
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using TEXT format options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      doc = language.document gcs_fake, format: :text
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using TEXT format and en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      doc = language.document gcs_fake, format: :text, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    it "runs full annotation with document object using en language options" do
      grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
      features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      doc = language.document gcs_fake, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_text_annotation annotation
    end

    describe "using #text helper" do
      it "runs full annotation using empty options" do
        grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT)
        features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

        language.service.mocked_service = mock
        gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
        doc = language.document gcs_fake
        annotation = language.annotate doc
        mock.verify

        assert_text_annotation annotation
      end

      it "runs full annotation using en language options" do
        grpc_doc = Google::Cloud::Language::V1beta1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :PLAIN_TEXT, language: "en")
        features = Google::Cloud::Language::V1beta1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1beta1::AnnotateTextResponse.decode_json text_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, :UTF8]

        language.service.mocked_service = mock
        gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
        doc = language.document gcs_fake, language: :en
        annotation = language.annotate doc
        mock.verify

        assert_text_annotation annotation
      end
    end
  end

  def assert_text_annotation annotation
    annotation.language.must_equal "en"

    annotation.sentiment.language.must_equal "en"
    annotation.sentiment.polarity.must_equal 1.0
    annotation.sentiment.magnitude.must_equal 2.0999999046325684

    annotation.entities.count.must_equal 3
    annotation.entities.language.must_equal "en"
    annotation.entities.unknown.map(&:name).must_equal []
    annotation.entities.people.map(&:name).must_equal ["Chris", "Mike"]
    annotation.entities.locations.map(&:name).must_equal ["Utah"]
    annotation.entities.places.map(&:name).must_equal ["Utah"]
    annotation.entities.organizations.map(&:name).must_equal []
    annotation.entities.events.map(&:name).must_equal []
    annotation.entities.artwork.map(&:name).must_equal []
    annotation.entities.goods.map(&:name).must_equal []
    annotation.entities.other.map(&:name).must_equal []

    annotation.sentences.map(&:text).must_equal text_sentences
    annotation.tokens.count.must_equal 24
    token = annotation.tokens.first
    token.text.must_equal "Hello"
    token.part_of_speech.must_equal :X
    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"
  end
end
