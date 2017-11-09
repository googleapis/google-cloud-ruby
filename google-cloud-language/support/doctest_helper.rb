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

require "google/cloud/language"

##
# Monkey-Patch CallOptions to support Mocks
class Google::Gax::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout === other.timeout &&
      retry_options === other.retry_options &&
      page_token === other.page_token &&
      kwargs === other.kwargs
  end
  def == other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout == other.timeout &&
      retry_options == other.retry_options &&
      page_token == other.page_token &&
      kwargs == other.kwargs
  end
end

module Google
  module Cloud
    module Language
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
    end
  end
end

def mock_language
  Google::Cloud::Language.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    language = Google::Cloud::Language::Project.new(Google::Cloud::Language::Service.new("my-project-id", credentials))

    language.service.mocked_service = Minitest::Mock.new
    if block_given?
      yield language.service.mocked_service
    end
    language
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Language::V1"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Language::Project#doc"
  doctest.skip "Google::Cloud::Language::Project#mark"
  doctest.skip "Google::Cloud::Language::Project#detect"
  doctest.skip "Google::Cloud::Language::Document#mark"
  doctest.skip "Google::Cloud::Language::Document#detect"

  doctest.before "Google::Cloud#language" do
    mock_language do |mock|
      mock.expect :annotate_text, text_resp, annotate_text_args
    end
  end

  doctest.before "Google::Cloud.language" do
    mock_language do |mock|
      mock.expect :annotate_text, text_resp, annotate_text_args
    end
  end

  doctest.before "Google::Cloud::Language" do
    mock_language do |mock|
      mock.expect :annotate_text, text_resp, annotate_text_args
    end
  end

  doctest.before "Google::Cloud::Language.new" do
    mock_language do |mock|
      mock.expect :annotate_text, text_resp, annotate_text_args
    end
  end

  # Project

  doctest.before "Google::Cloud::Language::Project" do
    mock_language do |mock|
      mock.expect :annotate_text, text_resp, annotate_text_args
    end
  end

  doctest.before "Google::Cloud::Language::Project#entities" do
    mock_language do |mock|
      mock.expect :analyze_entities, text_resp, analyze_entities_args
    end
  end

  doctest.before "Google::Cloud::Language::Project#sentiment" do
    mock_language do |mock|
      mock.expect :analyze_sentiment, text_resp, analyze_sentiment_args
    end
  end

  doctest.before "Google::Cloud::Language::Project#syntax" do
    mock_language do |mock|
      mock.expect :analyze_syntax, text_resp, analyze_entities_args
    end
  end

  # Document

  doctest.before "Google::Cloud::Language::Document#annotate@With feature flags:" do
    mock_language do |mock|
      mock.expect :annotate_text, text_resp, annotate_text_args({extract_document_sentiment: false})
    end
  end

  doctest.before "Google::Cloud::Language::Document#entities" do
    mock_language do |mock|
      mock.expect :analyze_entities, text_resp, analyze_entities_args
    end
  end

  doctest.before "Google::Cloud::Language::Document#sentiment" do
    mock_language do |mock|
      mock.expect :analyze_sentiment, text_resp, analyze_sentiment_args
    end
  end

  doctest.before "Google::Cloud::Language::Document#syntax" do
    mock_language do |mock|
      mock.expect :analyze_syntax, text_resp, analyze_entities_args
    end
  end
end

# Fixture helpers

def default_headers
  { "google-cloud-resource-prefix" => "projects/my-project-id" }
end

def default_options
  Google::Gax::CallOptions.new kwargs: default_headers
end

def grpc_doc
  Google::Cloud::Language::V1::Document.new content: content_arg, type: :PLAIN_TEXT
end

def annotate_text_args overrides_hash = {}
  features_hash = { extract_syntax: true, extract_entities: true, extract_document_sentiment: true }
  features_hash.merge! overrides_hash
  features = Google::Cloud::Language::V1::AnnotateTextRequest::Features.new features_hash
  [grpc_doc, features, { encoding_type: :UTF8, options: default_options }]
end

def analyze_entities_args
  [grpc_doc, { encoding_type: :UTF8, options: default_options }]
end

def analyze_sentiment_args
  [grpc_doc,  { encoding_type: :UTF8, options: default_options }]
end

def text_resp
  Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_resp_json
end

def content_arg
  "Star Wars is a great movie. The Death Star is fearsome."
end

def text_resp_json
  "{\"sentences\":[{\"text\":{\"content\":\"Star Wars is a great movie.\"},\"sentiment\":{\"magnitude\":0.69999999,\"score\":0.69999999}},{\"text\":{\"content\":\"The Death Star is fearsome.\",\"beginOffset\":28},\"sentiment\":{\"magnitude\":0.40000001,\"score\":-0.40000001}}],\"tokens\":[{\"text\":{\"content\":\"Star\"},\"partOfSpeech\":{\"tag\":\"NOUN\",\"number\":\"SINGULAR\",\"proper\":\"PROPER\"},\"dependencyEdge\":{\"headTokenIndex\":1,\"label\":\"TITLE\"},\"lemma\":\"Star\"},{\"text\":{\"content\":\"Wars\",\"beginOffset\":5},\"partOfSpeech\":{\"tag\":\"NOUN\",\"number\":\"PLURAL\",\"proper\":\"PROPER\"},\"dependencyEdge\":{\"headTokenIndex\":2,\"label\":\"NSUBJ\"},\"lemma\":\"Wars\"},{\"text\":{\"content\":\"is\",\"beginOffset\":10},\"partOfSpeech\":{\"tag\":\"VERB\",\"mood\":\"INDICATIVE\",\"number\":\"SINGULAR\",\"person\":\"THIRD\",\"tense\":\"PRESENT\"},\"dependencyEdge\":{\"headTokenIndex\":2,\"label\":\"ROOT\"},\"lemma\":\"be\"},{\"text\":{\"content\":\"a\",\"beginOffset\":13},\"partOfSpeech\":{\"tag\":\"DET\"},\"dependencyEdge\":{\"headTokenIndex\":5,\"label\":\"DET\"},\"lemma\":\"a\"},{\"text\":{\"content\":\"great\",\"beginOffset\":15},\"partOfSpeech\":{\"tag\":\"ADJ\"},\"dependencyEdge\":{\"headTokenIndex\":5,\"label\":\"AMOD\"},\"lemma\":\"great\"},{\"text\":{\"content\":\"movie\",\"beginOffset\":21},\"partOfSpeech\":{\"tag\":\"NOUN\",\"number\":\"SINGULAR\"},\"dependencyEdge\":{\"headTokenIndex\":2,\"label\":\"ATTR\"},\"lemma\":\"movie\"},{\"text\":{\"content\":\".\",\"beginOffset\":26},\"partOfSpeech\":{\"tag\":\"PUNCT\"},\"dependencyEdge\":{\"headTokenIndex\":2,\"label\":\"P\"},\"lemma\":\".\"},{\"text\":{\"content\":\"The\",\"beginOffset\":28},\"partOfSpeech\":{\"tag\":\"DET\"},\"dependencyEdge\":{\"headTokenIndex\":9,\"label\":\"DET\"},\"lemma\":\"The\"},{\"text\":{\"content\":\"Death\",\"beginOffset\":32},\"partOfSpeech\":{\"tag\":\"NOUN\",\"number\":\"SINGULAR\",\"proper\":\"PROPER\"},\"dependencyEdge\":{\"headTokenIndex\":9,\"label\":\"NN\"},\"lemma\":\"Death\"},{\"text\":{\"content\":\"Star\",\"beginOffset\":38},\"partOfSpeech\":{\"tag\":\"NOUN\",\"number\":\"SINGULAR\",\"proper\":\"PROPER\"},\"dependencyEdge\":{\"headTokenIndex\":10,\"label\":\"NSUBJ\"},\"lemma\":\"Star\"},{\"text\":{\"content\":\"is\",\"beginOffset\":43},\"partOfSpeech\":{\"tag\":\"VERB\",\"mood\":\"INDICATIVE\",\"number\":\"SINGULAR\",\"person\":\"THIRD\",\"tense\":\"PRESENT\"},\"dependencyEdge\":{\"headTokenIndex\":10,\"label\":\"ROOT\"},\"lemma\":\"be\"},{\"text\":{\"content\":\"fearsome\",\"beginOffset\":46},\"partOfSpeech\":{\"tag\":\"ADJ\"},\"dependencyEdge\":{\"headTokenIndex\":10,\"label\":\"ACOMP\"},\"lemma\":\"fearsome\"},{\"text\":{\"content\":\".\",\"beginOffset\":54},\"partOfSpeech\":{\"tag\":\"PUNCT\"},\"dependencyEdge\":{\"headTokenIndex\":10,\"label\":\"P\"},\"lemma\":\".\"}],\"entities\":[{\"name\":\"Star Wars\",\"type\":\"WORK_OF_ART\",\"metadata\":{\"wikipedia_url\":\"http://en.wikipedia.org/wiki/Star_Wars\",\"mid\":\"/m/06mmr\"},\"salience\":0.6457656,\"mentions\":[{\"text\":{\"content\":\"Star Wars\"},\"type\":\"PROPER\"}]},{\"name\":\"movie\",\"type\":\"WORK_OF_ART\",\"metadata\":{},\"salience\":0.3041383,\"mentions\":[{\"text\":{\"content\":\"movie\",\"beginOffset\":21},\"type\":\"COMMON\"}]},{\"name\":\"Death Star\",\"type\":\"PERSON\",\"metadata\":{\"wikipedia_url\":\"http://en.wikipedia.org/wiki/Death_Star\",\"mid\":\"/m/0f325\"},\"salience\":0.05009608,\"mentions\":[{\"text\":{\"content\":\"Death Star\",\"beginOffset\":32},\"type\":\"PROPER\"}]}],\"documentSentiment\":{\"magnitude\":1.1,\"score\":0.1},\"language\":\"en\"}"
end
