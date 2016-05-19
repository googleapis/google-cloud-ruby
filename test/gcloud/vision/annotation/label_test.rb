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

describe Gcloud::Vision::Annotation::Entity, :label, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:gapi) { JSON.parse(label_annotation_response.to_json) }
  let(:label) { Gcloud::Vision::Annotation::Entity.from_gapi gapi }

  it "knows the given attributes" do
    label.mid.must_equal "/m/02wtjj"
    label.locale.must_be :nil?
    label.description.must_equal "stone carving"
    label.score.must_equal 0.9859733
    label.confidence.must_be :nil?
    label.topicality.must_be :nil?
    label.bounds.must_be :empty?
    label.locations.must_be :empty?
    label.properties.must_be :empty?
  end
end
