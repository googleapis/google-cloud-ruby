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

describe Google::Cloud::Vision::Annotation::CropHint, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:grpc_list) { crop_hints_annotation_response }
  let(:crop_hint) { Google::Cloud::Vision::Annotation::CropHint.from_grpc grpc_list.crop_hints.first }

  it "knows the given attributes" do
    crop_hint.must_be_kind_of Google::Cloud::Vision::Annotation::CropHint

    crop_hint.bounds.count.must_equal 4
    crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
    crop_hint.bounds.map(&:to_a).must_equal [[1, 0], [295, 0], [295, 301], [1, 301]]

    crop_hint.confidence.must_equal 1.0
    crop_hint.importance_fraction.must_equal 1.0399999618530273
  end

  it "can convert to a hash" do
    hash = crop_hint.to_h
    hash.must_be_kind_of Hash
    hash[:bounds].must_be_kind_of Array
    hash[:bounds][0].must_equal({ x: 1,   y: 0 })
    hash[:bounds][1].must_equal({ x: 295, y: 0 })
    hash[:bounds][2].must_equal({ x: 295, y: 301 })
    hash[:bounds][3].must_equal({ x: 1,   y: 301 })
    hash[:confidence].must_equal 1.0
    hash[:importance_fraction].must_equal 1.0399999618530273
  end

  it "can convert to a string" do
    crop_hint.to_s.must_equal "bounds: 4, confidence: 1.0, importance_fraction: 1.0399999618530273"
    crop_hint.inspect.must_include crop_hint.to_s
  end
end
