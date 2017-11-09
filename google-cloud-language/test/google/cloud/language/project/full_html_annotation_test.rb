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

describe Google::Cloud::Language::Project, :full_html_annotation, :mock_language do
  describe "inline content" do
    it "runs full annotation with content and HTML format options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: html_content, type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate html_content, format: :html
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with content and HTML format and en language options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: html_content, type: :HTML, language: "en")
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate html_content, format: :html, language: :en
      mock.verify

      assert_html_annotation annotation
    end
  end

  describe "document object" do
    it "runs full annotation with document object using HTML format options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: html_content, type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      doc = language.document html_content, format: :html
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with document object using HTML format and en language options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        content: html_content, type: :HTML, language: "en")
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      doc = language.document html_content, format: :html, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    describe "using #html helper" do
      it "runs full annotation using empty options" do
        grpc_doc = Google::Cloud::Language::V1::Document.new(
          content: html_content, type: :HTML)
        features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

        language.service.mocked_service = mock
        doc = language.html html_content
        annotation = language.annotate doc
        mock.verify

        assert_html_annotation annotation
      end

      it "runs full annotation using en language options" do
        grpc_doc = Google::Cloud::Language::V1::Document.new(
          content: html_content, type: :HTML, language: "en")
        features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

        language.service.mocked_service = mock
        doc = language.html html_content, language: :en
        annotation = language.annotate doc
        mock.verify

        assert_html_annotation annotation
      end
    end
  end

  describe "inline URL" do
    it "runs full annotation with content and HTML format options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate "gs://bucket/path.ext", format: :html
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with content and HTML format and en language options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML, language: "en")
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate "gs://bucket/path.ext", format: :html, language: :en
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with content deriving HTML format from URL" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.html", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      annotation = language.annotate "gs://bucket/path.html"
      mock.verify

      assert_html_annotation annotation
    end
  end

  describe "document URL" do
    it "runs full annotation with document object using HTML format options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      doc = language.document "gs://bucket/path.ext", format: :html
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with document object using HTML format and en language options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML, language: "en")
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      doc = language.document "gs://bucket/path.ext", format: :html, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with document object deriving HTML format from URL" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.html", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      doc = language.document "gs://bucket/path.html"
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    describe "using #html helper" do
      it "runs full annotation using empty options" do
        grpc_doc = Google::Cloud::Language::V1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :HTML)
        features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

        language.service.mocked_service = mock
        doc = language.html "gs://bucket/path.ext"
        annotation = language.annotate doc
        mock.verify

        assert_html_annotation annotation
      end

      it "runs full annotation using en language options" do
        grpc_doc = Google::Cloud::Language::V1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :HTML, language: "en")
        features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

        language.service.mocked_service = mock
        doc = language.html "gs://bucket/path.ext", language: :en
        annotation = language.annotate doc
        mock.verify

        assert_html_annotation annotation
      end
    end
  end

  describe "inline GCS object" do
    it "runs full annotation with content and HTML format options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      annotation = language.annotate gcs_fake, format: :html
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with content and HTML format and en language options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML, language: "en")
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      annotation = language.annotate gcs_fake, format: :html, language: :en
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with content deriving HTML format from URL" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.html", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.html"
      annotation = language.annotate gcs_fake
      mock.verify

      assert_html_annotation annotation
    end
  end

  describe "document GCS object" do
    it "runs full annotation with document object using HTML format options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      doc = language.document gcs_fake, format: :html
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with document object using HTML format and en language options" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.ext", type: :HTML, language: "en")
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
      doc = language.document gcs_fake, format: :html, language: :en
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    it "runs full annotation with document object deriving HTML format from URL" do
      grpc_doc = Google::Cloud::Language::V1::Document.new(
        gcs_content_uri: "gs://bucket/path.html", type: :HTML)
      features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
        extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
      grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

      mock = Minitest::Mock.new
      mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

      language.service.mocked_service = mock
      gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.html"
      doc = language.document gcs_fake
      annotation = language.annotate doc
      mock.verify

      assert_html_annotation annotation
    end

    describe "using #html helper" do
      it "runs full annotation using empty options" do
        grpc_doc = Google::Cloud::Language::V1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :HTML)
        features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

        language.service.mocked_service = mock
        gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
        doc = language.html gcs_fake
        annotation = language.annotate doc
        mock.verify

        assert_html_annotation annotation
      end

      it "runs full annotation using en language options" do
        grpc_doc = Google::Cloud::Language::V1::Document.new(
          gcs_content_uri: "gs://bucket/path.ext", type: :HTML, language: "en")
        features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new(
          extract_syntax: true, extract_entities: true, extract_document_sentiment: true)
        grpc_resp = Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json

        mock = Minitest::Mock.new
        mock.expect :annotate_text, grpc_resp, [grpc_doc, features, encoding_type: :UTF8, options: default_options]

        language.service.mocked_service = mock
        gcs_fake = OpenStruct.new to_gs_url: "gs://bucket/path.ext"
        doc = language.html gcs_fake, language: :en
        annotation = language.annotate doc
        mock.verify

        assert_html_annotation annotation
      end
    end
  end

  def assert_html_annotation annotation
    annotation.language.must_equal "en"

    annotation.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentiment
    annotation.sentiment.language.must_equal "en"
    annotation.sentiment.score.must_be_close_to 1.0
    annotation.sentiment.magnitude.must_be_close_to 1.899999976158142

    annotation.entities.must_be_kind_of ::Array
    annotation.entities.class.must_equal Google::Cloud::Language::Annotation::Entities
    annotation.entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Language::Annotation::Entity
    end
    annotation.entities.count.must_equal 2
    annotation.entities.language.must_equal "en"
    annotation.entities.unknown.map(&:name).must_equal []
    annotation.entities.people.map(&:name).must_equal ["chris"]
    annotation.entities.locations.map(&:name).must_equal ["utah"]
    annotation.entities.places.map(&:name).must_equal ["utah"]
    annotation.entities.organizations.map(&:name).must_equal []
    annotation.entities.events.map(&:name).must_equal []
    annotation.entities.artwork.map(&:name).must_equal []
    annotation.entities.goods.map(&:name).must_equal []
    annotation.entities.other.map(&:name).must_equal []

    annotation.sentences.each do |sentence|
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::Sentence
      sentence.text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
      sentence.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentence::Sentiment
    end
    annotation.sentences.map(&:text).must_equal html_sentences
    annotation.sentences.first.text.must_equal "Hello from Chris and Mike!"
    annotation.sentences.first.offset.must_equal -1
    annotation.sentences.first.must_be :sentiment?
    annotation.sentences.first.score.must_equal 1.0
    annotation.sentences.first.magnitude.must_equal 1.899999976158142

    annotation.tokens.each do |token|
      token.must_be_kind_of Google::Cloud::Language::Annotation::Token
    end
    annotation.tokens.count.must_equal 24
    token = annotation.tokens.first
    token.text.must_equal "Hello"
    token.part_of_speech.tag.must_equal :X
    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"

    annotation.syntax.must_be_kind_of Google::Cloud::Language::Annotation::Syntax
    annotation.syntax.sentences.each do |sentence|
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::Sentence
      sentence.text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
      sentence.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentence::Sentiment
    end
    annotation.syntax.sentences.map(&:text).must_equal html_sentences
    annotation.syntax.sentences.first.text.must_equal "Hello from Chris and Mike!"
    annotation.syntax.sentences.first.offset.must_equal -1
    annotation.syntax.sentences.first.must_be :sentiment?
    annotation.syntax.sentences.first.score.must_equal 1.0
    annotation.syntax.sentences.first.magnitude.must_equal 1.899999976158142

    annotation.syntax.tokens.each do |token|
      token.must_be_kind_of Google::Cloud::Language::Annotation::Token
    end
    annotation.syntax.tokens.count.must_equal 24
    token = annotation.tokens.first
    token.text.must_equal "Hello"

    token.part_of_speech.tag.must_equal :X
    token.part_of_speech.aspect.must_equal :PERFECTIVE
    token.part_of_speech.case.must_equal :INSTRUMENTAL
    token.part_of_speech.form.must_equal :GERUND
    token.part_of_speech.gender.must_equal :NEUTER
    token.part_of_speech.mood.must_equal :SUBJUNCTIVE
    token.part_of_speech.number.must_equal :SINGULAR
    token.part_of_speech.person.must_equal :FIRST
    token.part_of_speech.proper.must_equal :NOT_PROPER
    token.part_of_speech.reciprocity.must_equal :RECIPROCAL
    token.part_of_speech.tense.must_equal :IMPERFECT
    token.part_of_speech.voice.must_equal :ACTIVE

    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"
  end
end
