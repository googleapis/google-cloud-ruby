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

describe Google::Cloud::Vision::Annotation::Entity, :landmark, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:grpc) { landmark_annotation_response }
  let(:landmark) { Google::Cloud::Vision::Annotation::Entity.from_grpc grpc }

  it "knows the given attributes" do
    landmark.mid.must_equal "/m/019dvv"
    landmark.locale.must_be :empty?
    landmark.description.must_equal "Mount Rushmore"
    landmark.score.must_be_close_to 0.91912264
    landmark.confidence.must_be :zero?
    landmark.topicality.must_be :zero?
    landmark.bounds[0].to_a.must_equal [1,  0]
    landmark.bounds[1].to_a.must_equal [295, 0]
    landmark.bounds[2].to_a.must_equal [295, 301]
    landmark.bounds[3].to_a.must_equal [1,  301]
    landmark.locations[0].latitude.must_be_close_to 43.878264
    landmark.locations[0].longitude.must_be_close_to -103.45700740814209
    landmark.locations[0].to_a.must_be_close_to_array [43.878264, -103.45700740814209]
    landmark.properties.must_be :empty?
  end

  it "can convert to a hash" do
    hash = landmark.to_h
    hash.must_be_kind_of Hash
    hash[:mid].must_equal "/m/019dvv"
    hash[:locale].must_equal ""
    hash[:description].must_equal "Mount Rushmore"
    hash[:score].must_be_close_to 0.91912264
    hash[:confidence].must_equal 0.0
    hash[:topicality].must_equal 0.0
    hash[:bounds].must_be_kind_of Array
    hash[:bounds][0].must_equal({ x: 1,  y: 0 })
    hash[:bounds][1].must_equal({ x: 295, y: 0 })
    hash[:bounds][2].must_equal({ x: 295, y: 301 })
    hash[:bounds][3].must_equal({ x: 1,  y: 301 })
    hash[:locations].must_be_kind_of Array
    hash[:locations][0].must_equal({ latitude: 43.878264, longitude: -103.45700740814209 })
    hash[:properties].must_equal({})
  end

  it "can convert to a string" do
    landmark.to_s.must_equal "mid: \"/m/019dvv\", locale: \"\", description: \"Mount Rushmore\", score: 0.9191226363182068, confidence: 0.0, topicality: 0.0, bounds: 4, locations: 1, properties: {}"
    landmark.inspect.must_include landmark.to_s

    landmark.locations.each do |location|
      location.inspect.must_include location.to_s
    end
  end
end
