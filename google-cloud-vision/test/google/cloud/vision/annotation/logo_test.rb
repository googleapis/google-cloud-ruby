# Copyright 2016 Google LLC
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

describe Google::Cloud::Vision::Annotation::Entity, :logo, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:grpc) { logo_annotation_response }
  let(:logo) { Google::Cloud::Vision::Annotation::Entity.from_grpc grpc }

  it "knows the given attributes" do
    logo.mid.must_equal "/m/045c7b"
    logo.locale.must_be :empty?
    logo.description.must_equal "Google"
    logo.score.must_be_close_to 0.6435439
    logo.confidence.must_be :zero?
    logo.topicality.must_be :zero?
    logo.bounds[0].to_a.must_equal [1,  0]
    logo.bounds[1].to_a.must_equal [295, 0]
    logo.bounds[2].to_a.must_equal [295, 301]
    logo.bounds[3].to_a.must_equal [1,  301]
    logo.locations.must_be :empty?
    logo.properties.must_be :empty?
  end

  it "can convert to a hash" do
    hash = logo.to_h
    hash.must_be_kind_of Hash
    hash[:mid].must_equal "/m/045c7b"
    hash[:locale].must_equal ""
    hash[:description].must_equal "Google"
    hash[:score].must_be_close_to 0.6435439
    hash[:confidence].must_equal 0.0
    hash[:topicality].must_equal 0.0
    hash[:bounds].must_be_kind_of Array
    hash[:bounds][0].must_equal({ x: 1,   y: 0 })
    hash[:bounds][1].must_equal({ x: 295, y: 0 })
    hash[:bounds][2].must_equal({ x: 295, y: 301 })
    hash[:bounds][3].must_equal({ x: 1,   y: 301 })
    hash[:locations].must_equal []
    hash[:properties].must_equal({})
  end

  it "can convert to a string" do
    logo.to_s.must_equal "mid: \"/m/045c7b\", locale: \"\", description: \"Google\", score: 0.6435438990592957, confidence: 0.0, topicality: 0.0, bounds: 4, locations: 0, properties: {}"
    logo.inspect.must_include logo.to_s
  end
end
