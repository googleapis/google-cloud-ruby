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

describe Google::Cloud::Language::Annotation, :mock_language do
  let(:text_annotation_grpc) { Google::Cloud::Language::V1::AnnotateTextResponse.decode_json text_json }
  let(:html_annotation_grpc) { Google::Cloud::Language::V1::AnnotateTextResponse.decode_json html_json }
  let(:annotation)      { Google::Cloud::Language::Annotation.from_grpc annotation_grpc }

  it "represents a plain text annotation response" do
    annotation = Google::Cloud::Language::Annotation.from_grpc text_annotation_grpc
    annotation.must_be_kind_of Google::Cloud::Language::Annotation

    annotation.language.must_equal "en"

    annotation.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentiment
    annotation.sentiment.language.must_equal "en"
    annotation.sentiment.polarity.must_equal 1.0
    annotation.sentiment.magnitude.must_equal 2.0999999046325684

    annotation.entities.must_be_kind_of ::Array
    annotation.entities.class.must_equal Google::Cloud::Language::Annotation::Entities
    annotation.entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Language::Annotation::Entity
    end
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

    annotation.sentences.each do |sentence|
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
    end
    annotation.sentences.map(&:text).must_equal text_sentences

    annotation.tokens.each do |token|
      token.must_be_kind_of Google::Cloud::Language::Annotation::Token
    end
    annotation.tokens.count.must_equal 24
    token = annotation.tokens.first
    token.text.must_equal "Hello"
    token.part_of_speech.must_equal :X
    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"
  end

  it "represents an html annotation response" do
    annotation = Google::Cloud::Language::Annotation.from_grpc html_annotation_grpc
    annotation.must_be_kind_of Google::Cloud::Language::Annotation

    annotation.language.must_equal "en"

    annotation.sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentiment
    annotation.sentiment.language.must_equal "en"
    annotation.sentiment.polarity.must_be_close_to 1.0
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
      sentence.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
    end
    annotation.sentences.map(&:text).must_equal html_sentences

    annotation.tokens.each do |token|
      token.must_be_kind_of Google::Cloud::Language::Annotation::Token
    end
    annotation.tokens.count.must_equal 24
    token = annotation.tokens.first
    token.text.must_equal "Hello"
    token.part_of_speech.must_equal :X
    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"
  end

  it "has a pretty #inspect" do
    annotation = Google::Cloud::Language::Annotation.from_grpc html_annotation_grpc
    annotation.inspect.must_equal %{#<Google::Cloud::Language::Annotation (sentences: 3, tokens: 24, entities: 2, sentiment: true, language: "en")>}
  end
end
