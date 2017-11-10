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

describe Google::Cloud::Language::Project, :entities, :mock_language do
  let(:entities_text_json) { JSON.parse(text_json).select { |k,_v| %w{entities language}.include? k }.to_json }
  let(:entities_html_json) { JSON.parse(html_json).select { |k,_v| %w{entities language}.include? k }.to_json }

  it "runs entities content and empty options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeEntitiesResponse.decode_json entities_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_entities, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    language.service.mocked_service = mock
    entities = language.entities text_content
    mock.verify

    assert_text_entities entities
  end

  it "runs entities with en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeEntitiesResponse.decode_json entities_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_entities, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    language.service.mocked_service = mock
    entities = language.entities text_content, language: :en
    mock.verify

    assert_text_entities entities
  end

  it "runs entities with TEXT format options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeEntitiesResponse.decode_json entities_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_entities, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    language.service.mocked_service = mock
    entities = language.entities text_content, format: :text
    mock.verify

    assert_text_entities entities
  end

  it "runs entities with TEXT format and en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: text_content, type: :PLAIN_TEXT, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeEntitiesResponse.decode_json entities_text_json

    mock = Minitest::Mock.new
    mock.expect :analyze_entities, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    language.service.mocked_service = mock
    entities = language.entities text_content, format: :text, language: :en
    mock.verify

    assert_text_entities entities
  end

  it "runs entities with HTML format options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: html_content, type: :HTML)
    grpc_resp = Google::Cloud::Language::V1::AnalyzeEntitiesResponse.decode_json entities_html_json

    mock = Minitest::Mock.new
    mock.expect :analyze_entities, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    language.service.mocked_service = mock
    entities = language.entities html_content, format: :html
    mock.verify

    assert_html_entities entities
  end

  it "runs entities with HTML format and en language options" do
    grpc_doc = Google::Cloud::Language::V1::Document.new(
      content: html_content, type: :HTML, language: "en")
    grpc_resp = Google::Cloud::Language::V1::AnalyzeEntitiesResponse.decode_json entities_html_json

    mock = Minitest::Mock.new
    mock.expect :analyze_entities, grpc_resp, [grpc_doc, encoding_type: :UTF8, options: default_options]

    language.service.mocked_service = mock
    entities = language.entities html_content, format: :html, language: :en
    mock.verify

    assert_html_entities entities
  end

  def assert_text_entities entities
    entities.must_be_kind_of ::Array
    entities.class.must_equal Google::Cloud::Language::Annotation::Entities
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Language::Annotation::Entity
    end
    entities.count.must_equal 3
    entities.language.must_equal "en"
    entities.unknown.map(&:name).must_equal []
    entities.people.map(&:name).must_equal ["Chris", "Mike"]
    entities.locations.map(&:name).must_equal ["Utah"]
    entities.places.map(&:name).must_equal ["Utah"]
    entities.organizations.map(&:name).must_equal []
    entities.events.map(&:name).must_equal []
    entities.artwork.map(&:name).must_equal []
    entities.goods.map(&:name).must_equal []
    entities.other.map(&:name).must_equal []
  end

  def assert_html_entities entities
    entities.must_be_kind_of ::Array
    entities.class.must_equal Google::Cloud::Language::Annotation::Entities
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Language::Annotation::Entity
    end
    entities.count.must_equal 2
    entities.language.must_equal "en"
    entities.unknown.map(&:name).must_equal []
    entities.people.map(&:name).must_equal ["chris"]
    entities.locations.map(&:name).must_equal ["utah"]
    entities.places.map(&:name).must_equal ["utah"]
    entities.organizations.map(&:name).must_equal []
    entities.events.map(&:name).must_equal []
    entities.artwork.map(&:name).must_equal []
    entities.goods.map(&:name).must_equal []
    entities.other.map(&:name).must_equal []
  end
end
