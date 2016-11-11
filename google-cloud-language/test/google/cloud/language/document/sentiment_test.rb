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

describe Google::Cloud::Language::Document, :sentiment, :mock_language do
  let(:sentiment_text_json) { JSON.parse(text_json).select { |k,_v| %w{documentSentiment language sentences}.include? k }.to_json }
  let(:sentiment_html_json) { JSON.parse(html_json).select { |k,_v| %w{documentSentiment language sentences}.include? k }.to_json }

  it "runs sentiment content and empty options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSentimentResponse.decode_json sentiment_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_sentiment, grpc_resp, [grpc_doc, options: default_options]

    doc = language.document text_content
    doc.service.mocked_service = mock
    sentiment = doc.sentiment
    mock.verify

    assert_text_sentiment sentiment
  end

  it "runs sentiment with en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSentimentResponse.decode_json sentiment_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_sentiment, grpc_resp, [grpc_doc, options: default_options]

    doc = language.document text_content, language: :en
    doc.service.mocked_service = mock
    sentiment = doc.sentiment
    mock.verify

    assert_text_sentiment sentiment
  end

  it "runs sentiment with TEXT format options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSentimentResponse.decode_json sentiment_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_sentiment, grpc_resp, [grpc_doc, options: default_options]

    doc = language.text text_content
    doc.service.mocked_service = mock
    sentiment = doc.sentiment
    mock.verify

    assert_text_sentiment sentiment
  end

  it "runs sentiment with TEXT format and en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSentimentResponse.decode_json sentiment_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_sentiment, grpc_resp, [grpc_doc, options: default_options]

    doc = language.document text_content, format: :text, language: :en
    doc.service.mocked_service = mock
    sentiment = doc.sentiment
    mock.verify

    assert_text_sentiment sentiment
  end

  it "runs sentiment with HTML format options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: html_content, type: :HTML)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSentimentResponse.decode_json sentiment_html_json

    mock = Minitest::Mock.new
    mock.expect :analyze_sentiment, grpc_resp, [grpc_doc, options: default_options]

    doc = language.html html_content
    doc.service.mocked_service = mock
    sentiment = doc.sentiment
    mock.verify

    assert_html_sentiment sentiment
  end

  it "runs sentiment with HTML format and en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: html_content, type: :HTML, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeSentimentResponse.decode_json sentiment_html_json

    mock = Minitest::Mock.new
    mock.expect :analyze_sentiment, grpc_resp, [grpc_doc, options: default_options]

    doc = language.document html_content, format: :html, language: :en
    doc.service.mocked_service = mock
    sentiment = doc.sentiment
    mock.verify

    assert_html_sentiment sentiment
  end

  def assert_text_sentiment sentiment
    sentiment.language.must_equal "en"

    sentiment.language.must_equal "en"
    sentiment.score.must_equal 1.0
    sentiment.magnitude.must_equal 2.0999999046325684

    sentiment.sentences.each do |sentence|
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::Sentence
      sentence.text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
      sentence.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentence::Sentiment
    end
    sentiment.sentences.map(&:text).must_equal text_sentences
    sentiment.sentences.first.text.must_equal "Hello from Chris and Mike!"
    sentiment.sentences.first.offset.must_equal -1
    sentiment.sentences.first.must_be :sentiment?
    sentiment.sentences.first.score.must_equal 1.0
    sentiment.sentences.first.magnitude.must_equal 1.899999976158142
  end

  def assert_html_sentiment sentiment
    sentiment.language.must_equal "en"

    sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentiment
    sentiment.language.must_equal "en"
    sentiment.score.must_be_close_to 1.0
    sentiment.magnitude.must_be_close_to 1.899999976158142

    sentiment.sentences.each do |sentence|
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::Sentence
      sentence.text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
      sentence.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentence::Sentiment
    end
    sentiment.sentences.map(&:text).must_equal html_sentences
    sentiment.sentences.first.text.must_equal "Hello from Chris and Mike!"
    sentiment.sentences.first.offset.must_equal -1
    sentiment.sentences.first.must_be :sentiment?
    sentiment.sentences.first.score.must_equal 1.0
    sentiment.sentences.first.magnitude.must_equal 1.899999976158142
  end
end
