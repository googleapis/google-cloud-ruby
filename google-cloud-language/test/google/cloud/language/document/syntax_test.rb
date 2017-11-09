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

describe Google::Cloud::Language::Document, :syntax, :mock_language do
  let(:syntax_text_json) { JSON.parse(text_json).select { |k,_v| %w{sentences tokens language}.include? k }.to_json }
  let(:syntax_html_json) { JSON.parse(html_json).select { |k,_v| %w{sentences tokens language}.include? k }.to_json }

  it "runs syntax content and empty options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSyntaxResponse.decode_json syntax_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_syntax, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    doc = language.document text_content
    doc.service.mocked_service = mock
    syntax = doc.syntax
    mock.verify

    assert_text_syntax syntax
  end

  it "runs syntax with en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSyntaxResponse.decode_json syntax_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_syntax, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    doc = language.document text_content, language: :en
    doc.service.mocked_service = mock
    syntax = doc.syntax
    mock.verify

    assert_text_syntax syntax
  end

  it "runs syntax with TEXT format options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSyntaxResponse.decode_json syntax_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_syntax, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    doc = language.text text_content
    doc.service.mocked_service = mock
    syntax = doc.syntax
    mock.verify

    assert_text_syntax syntax
  end

  it "runs syntax with TEXT format and en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSyntaxResponse.decode_json syntax_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_syntax, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    doc = language.document text_content, format: :text, language: :en
    doc.service.mocked_service = mock
    syntax = doc.syntax
    mock.verify

    assert_text_syntax syntax
  end

  it "runs syntax with HTML format options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: html_content, type: :HTML)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSyntaxResponse.decode_json syntax_html_json

    mock = Minitest::Mock.new
    mock.expect :analyze_syntax, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    doc = language.html html_content
    doc.service.mocked_service = mock
    syntax = doc.syntax
    mock.verify

    assert_html_syntax syntax
  end

  it "runs syntax with HTML format and en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: html_content, type: :HTML, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSyntaxResponse.decode_json syntax_html_json

    mock = Minitest::Mock.new
    mock.expect :analyze_syntax, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    doc = language.document html_content, format: :html, language: :en
    doc.service.mocked_service = mock
    syntax = doc.syntax
    mock.verify

    assert_html_syntax syntax
  end

  def assert_text_syntax syntax
    syntax.must_be_kind_of Google::Cloud::Language::Annotation::Syntax
    syntax.sentences.each do |sentence|
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::Sentence
      sentence.text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
      sentence.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentence::Sentiment
    end
    syntax.sentences.map(&:text).must_equal text_sentences
    syntax.sentences.first.text.must_equal "Hello from Chris and Mike!"
    syntax.sentences.first.offset.must_equal -1
    syntax.sentences.first.must_be :sentiment?
    syntax.sentences.first.score.must_equal 1.0
    syntax.sentences.first.magnitude.must_equal 1.899999976158142

    syntax.tokens.count.must_equal 24
    token = syntax.tokens.first
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

    syntax.language.must_equal "en"
  end

  def assert_html_syntax syntax
    syntax.must_be_kind_of Google::Cloud::Language::Annotation::Syntax
    syntax.sentences.each do |sentence|
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::Sentence
      sentence.text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
      sentence.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentence::Sentiment
    end
    syntax.sentences.map(&:text).must_equal html_sentences
    syntax.sentences.first.text.must_equal "Hello from Chris and Mike!"
    syntax.sentences.first.offset.must_equal -1
    syntax.sentences.first.must_be :sentiment?
    syntax.sentences.first.score.must_equal 1.0
    syntax.sentences.first.magnitude.must_equal 1.899999976158142

    syntax.tokens.each do |token|
      token.must_be_kind_of Google::Cloud::Language::Annotation::Token
    end
    syntax.tokens.count.must_equal 24
    token = syntax.tokens.first
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

    syntax.language.must_equal "en"
  end
end
