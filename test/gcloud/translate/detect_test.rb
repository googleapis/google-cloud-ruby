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

describe Gcloud::Translate::Api, :detect, :mock_translate do
  it "doesn't make an API call if text is not given" do
    detection = translate.detect
    detection.must_be :nil?

    detection = translate.detect quota_user: "quota_user-1234567899"
    detection.must_be :nil?
  end

  it "detects multiple langauges with user_ip" do
    mock_connection.get "/language/translate/v2/detect" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "Hola"]
      env.params["quotaUser"].must_be :nil?
      env.params["userIp"].must_equal "127.0.0.1"
      [200, { "Content-Type" => "application/json" },
       detect_json("en", "es")]
    end

    detections = translate.detect "Hello", "Hola", user_ip: "127.0.0.1"
    translation = translate.translate to: "es", from: :en, format: :html
    translation.must_be :nil?
  end


  it "detects a single langauge" do
    mock_connection.get "/language/translate/v2/detect" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "Hello"
      env.params["quotaUser"].must_be :nil?
      env.params["userIp"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       detect_json("en")]
    end

    detection = translate.detect "Hello"
    detection.language.must_equal "en"
    detection.results.count.must_equal 1
    detection.results.first.language.must_equal "en"
  end

  it "detects a single langauge with quota_user" do
    mock_connection.get "/language/translate/v2/detect" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "Hello"
      env.params["quotaUser"].must_equal "quota_user-1234567899"
      env.params["userIp"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       detect_json("en")]
    end

    detection = translate.detect "Hello", quota_user: "quota_user-1234567899"
    detection.language.must_equal "en"
    detection.results.count.must_equal 1
    detection.results.first.language.must_equal "en"
  end

  it "detects a single langauge with user_ip" do
    mock_connection.get "/language/translate/v2/detect" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "Hello"
      env.params["quotaUser"].must_be :nil?
      env.params["userIp"].must_equal "127.0.0.1"
      [200, { "Content-Type" => "application/json" },
       detect_json("en")]
    end

    detection = translate.detect "Hello", user_ip: "127.0.0.1"
    detection.language.must_equal "en"
    detection.results.count.must_equal 1
    detection.results.first.language.must_equal "en"
  end

  it "detects multiple langauges" do
    mock_connection.get "/language/translate/v2/detect" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "Hola"]
      env.params["quotaUser"].must_be :nil?
      env.params["userIp"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       detect_json("en", "es")]
    end

    detections = translate.detect "Hello", "Hola"
    detections.count.must_equal 2

    detections.first.language.must_equal "en"
    detections.first.results.count.must_equal 1
    detections.first.results.first.language.must_equal "en"

    detections.last.language.must_equal "es"
    detections.last.results.count.must_equal 1
    detections.last.results.first.language.must_equal "es"
  end

  it "detects multiple langauges with quota_user" do
    mock_connection.get "/language/translate/v2/detect" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "Hola"]
      env.params["quotaUser"].must_equal "quota_user-1234567899"
      env.params["userIp"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       detect_json("en", "es")]
    end

    detections = translate.detect "Hello", "Hola", quota_user: "quota_user-1234567899"
    detections.count.must_equal 2

    detections.first.language.must_equal "en"
    detections.first.results.count.must_equal 1
    detections.first.results.first.language.must_equal "en"

    detections.last.language.must_equal "es"
    detections.last.results.count.must_equal 1
    detections.last.results.first.language.must_equal "es"
  end

  it "detects multiple langauges with user_ip" do
    mock_connection.get "/language/translate/v2/detect" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "Hola"]
      env.params["quotaUser"].must_be :nil?
      env.params["userIp"].must_equal "127.0.0.1"
      [200, { "Content-Type" => "application/json" },
       detect_json("en", "es")]
    end

    detections = translate.detect "Hello", "Hola", user_ip: "127.0.0.1"
    detections.count.must_equal 2

    detections.first.language.must_equal "en"
    detections.first.results.count.must_equal 1
    detections.first.results.first.language.must_equal "en"

    detections.last.language.must_equal "es"
    detections.last.results.count.must_equal 1
    detections.last.results.first.language.must_equal "es"
  end
end
