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

describe Gcloud::Vision::Analysis::Entity, :logo, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:gapi) { JSON.parse(logo_annotation_response.to_json) }
  let(:logo) { Gcloud::Vision::Analysis::Entity.from_gapi gapi }

  it "knows the given attributes" do
    logo.mid.must_equal "/m/045c7b"
    logo.locale.must_be :nil?
    logo.description.must_equal "Google"
    logo.score.must_equal 0.6435439
    logo.confidence.must_be :nil?
    logo.topicality.must_be :nil?
    logo.bounds[0].to_a.must_equal [11,  11]
    logo.bounds[1].to_a.must_equal [330, 11]
    logo.bounds[2].to_a.must_equal [330, 72]
    logo.bounds[3].to_a.must_equal [11,  72]
    logo.locations.must_be :empty?
    logo.properties.must_be :empty?
  end
end
