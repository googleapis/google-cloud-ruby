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

describe Google::Cloud::Vision::Annotation::ObjectLocalization, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:grpc_list) { object_localizations_annotation_response }
  let(:object_localization) { Google::Cloud::Vision::Annotation::ObjectLocalization.from_grpc grpc_list.first }

  it "knows the given attributes" do
    object_localization.must_be_kind_of Google::Cloud::Vision::Annotation::ObjectLocalization

    object_localization.mid.must_equal "/m/01bqk0"
    object_localization.code.must_equal "en-US"
    object_localization.name.must_equal "Bicycle wheel"
    object_localization.score.must_be_close_to 0.89648587

    object_localization.bounds.count.must_equal 4
    object_localization.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::NormalizedVertex
    object_localization.bounds[0].to_a.must_be_close_to_array [0.31, 0.66]
    object_localization.bounds[1].to_a.must_be_close_to_array [0.63, 0.66]
    object_localization.bounds[2].to_a.must_be_close_to_array [0.63, 0.97]
    object_localization.bounds[3].to_a.must_be_close_to_array [0.31, 0.97]
  end

  it "can convert to a hash" do
    hash = object_localization.to_h
    hash.must_be_kind_of Hash
    hash[:mid].must_equal "/m/01bqk0"
    hash[:code].must_equal "en-US"
    hash[:name].must_equal "Bicycle wheel"
    hash[:score].must_be_close_to 0.89648587
    hash[:bounds].must_be_kind_of Array
    hash[:bounds][0].must_equal({:x=>0.3100000023841858, :y=>0.6600000262260437})
    hash[:bounds][1].must_equal({:x=>0.6299999952316284, :y=>0.6600000262260437})
    hash[:bounds][2].must_equal({:x=>0.6299999952316284, :y=>0.9700000286102295})
    hash[:bounds][3].must_equal({:x=>0.3100000023841858, :y=>0.9700000286102295})
  end

  it "can convert to a string" do
    object_localization.to_s.must_equal "mid: \"/m/01bqk0\", code: \"en-US\", name: \"Bicycle wheel\", score: 0.8964858651161194,  bounds: 4"
    object_localization.inspect.must_include object_localization.to_s
  end
end
