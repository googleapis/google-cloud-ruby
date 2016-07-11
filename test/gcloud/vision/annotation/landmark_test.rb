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

describe Gcloud::Vision::Annotation::Entity, :landmark, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:gapi) { landmark_annotation_response }
  let(:landmark) { Gcloud::Vision::Annotation::Entity.from_gapi gapi }

  it "knows the given attributes" do
    landmark.mid.must_equal "/m/019dvv"
    landmark.locale.must_be :nil?
    landmark.description.must_equal "Mount Rushmore"
    landmark.score.must_equal 0.91912264
    landmark.confidence.must_be :nil?
    landmark.topicality.must_be :nil?
    landmark.bounds[0].to_a.must_equal [1,  0]
    landmark.bounds[1].to_a.must_equal [295, 0]
    landmark.bounds[2].to_a.must_equal [295, 301]
    landmark.bounds[3].to_a.must_equal [1,  301]
    landmark.locations[0].latitude.must_equal 43.878264
    landmark.locations[0].longitude.must_equal -103.45700740814209
    landmark.properties.must_be :empty?
  end
end
