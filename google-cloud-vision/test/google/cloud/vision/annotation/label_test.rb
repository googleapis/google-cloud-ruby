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

describe Google::Cloud::Vision::Annotation::Entity, :label, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:grpc) { label_annotation_response }
  let(:label) { Google::Cloud::Vision::Annotation::Entity.from_grpc grpc }

  it "knows the given attributes" do
    label.mid.must_equal "/m/02wtjj"
    label.locale.must_be :empty?
    label.description.must_equal "stone carving"
    label.score.must_be_close_to 0.9859733
    label.confidence.must_be :zero?
    label.topicality.must_be :zero?
    label.bounds.must_be :empty?
    label.locations.must_be :empty?
    label.properties.must_be :empty?
  end

  it "can convert to a hash" do
    hash = label.to_h
    hash.must_be_kind_of Hash
    hash[:mid].must_equal "/m/02wtjj"
    hash[:locale].must_equal ""
    hash[:description].must_equal "stone carving"
    hash[:score].must_be_close_to 0.9859733
    hash[:confidence].must_equal 0.0
    hash[:topicality].must_equal 0.0
    hash[:bounds].must_equal []
    hash[:locations].must_equal []
    hash[:properties].must_equal({})
  end

  it "can convert to a string" do
    label.to_s.must_equal "mid: \"/m/02wtjj\", locale: \"\", description: \"stone carving\", score: 0.9859732985496521, confidence: 0.0, topicality: 0.0, bounds: 0, locations: 0, properties: {}"
    label.inspect.must_include label.to_s
  end
end
