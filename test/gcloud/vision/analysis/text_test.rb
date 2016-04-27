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

describe Gcloud::Vision::Analysis::Entity, :text, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:gapi) { JSON.parse(text_annotation_response.to_json) }
  let(:text) { Gcloud::Vision::Analysis::Entity.from_gapi gapi }

  it "knows the given attributes" do
    text.mid.must_be :nil?
    text.locale.must_equal "en"
    text.description.must_equal "Google Cloud Client Library for Ruby an idiomatic, intuitive, and\nnatural way for Ruby developers to integrate with Google Cloud\nPlatform services, like Cloud Datastore and Cloud Storage.\n"
    text.score.must_be :nil?
    text.confidence.must_be :nil?
    text.topicality.must_be :nil?
    text.bounds[0].to_a.must_equal [13,  8]
    text.bounds[1].to_a.must_equal [385, 8]
    text.bounds[2].to_a.must_equal [385, 74]
    text.bounds[3].to_a.must_equal [13,  74]
    text.locations.must_be :empty?
    text.properties.must_be :empty?
  end
end
