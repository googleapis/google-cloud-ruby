# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Translate::Api, :detect, :mock_translate do
  it "doesn't make an API call if text is not given" do
    detection = translate.detect
    detection.must_be :nil?
  end

  it "detects a single language" do
    mock = Minitest::Mock.new
    detections_resource = { confidence: 0.123, language: "en", isReliable: false }
    list_detections_resource = JSON.parse({ detections: [[detections_resource]] }.to_json)
    mock.expect :detect, list_detections_resource, [["Hello"]]

    translate.service = mock
    detection = translate.detect "Hello"
    mock.verify

    detection.language.must_equal "en"
    detection.results.count.must_equal 1
    detection.results.first.language.must_equal "en"
  end

  it "detects multiple languages" do
    mock = Minitest::Mock.new
    detections_resource = { confidence: 0.123, language: "en", isReliable: false }
    detections_resource_2 = { confidence: 0.123, language: "es", isReliable: false }
    list_detections_resource = JSON.parse({ detections: [[detections_resource], [detections_resource_2]] }.to_json)
    mock.expect :detect, list_detections_resource, [["Hello", "Hola"]]

    translate.service = mock
    detections = translate.detect "Hello", "Hola"
    mock.verify

    detections.count.must_equal 2

    detections.first.language.must_equal "en"
    detections.first.results.count.must_equal 1
    detections.first.results.first.language.must_equal "en"

    detections.last.language.must_equal "es"
    detections.last.results.count.must_equal 1
    detections.last.results.first.language.must_equal "es"
  end

  it "detects multiple languages in an array" do
    mock = Minitest::Mock.new
    detections_resource = { confidence: 0.123, language: "en", isReliable: false }
    detections_resource_2 = { confidence: 0.123, language: "es", isReliable: false }
    list_detections_resource = JSON.parse({ detections: [[detections_resource], [detections_resource_2]] }.to_json)
    mock.expect :detect, list_detections_resource, [["Hello", "Hola"]]

    translate.service = mock
    detections = translate.detect ["Hello", "Hola"]
    mock.verify

    detections.count.must_equal 2

    detections.first.language.must_equal "en"
    detections.first.results.count.must_equal 1
    detections.first.results.first.language.must_equal "en"

    detections.last.language.must_equal "es"
    detections.last.results.count.must_equal 1
    detections.last.results.first.language.must_equal "es"
  end
end
