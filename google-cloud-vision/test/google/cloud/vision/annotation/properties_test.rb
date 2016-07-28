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

describe Google::Cloud::Vision::Annotation::Properties, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:gapi) { properties_annotation_response }
  let(:properties) { Google::Cloud::Vision::Annotation::Properties.from_gapi gapi }

  it "knows the given attributes" do
    properties.wont_be :nil?

    properties.colors.wont_be :empty?
    properties.colors.count.must_equal 10

    properties.colors[0].red.must_equal 145
    properties.colors[0].green.must_equal 193
    properties.colors[0].blue.must_equal 254
    properties.colors[0].alpha.must_equal 1.0
    properties.colors[0].rgb.must_equal "91c1fe"
    properties.colors[0].score.must_equal 0.65757853
    properties.colors[0].pixel_fraction.must_equal 0.16903226

    properties.colors[1].red.must_equal 0
    properties.colors[1].green.must_equal 0
    properties.colors[1].blue.must_equal 0
    properties.colors[1].alpha.must_equal 1.0
    properties.colors[1].rgb.must_equal "000000"
    properties.colors[1].score.must_equal 0.09256918
    properties.colors[1].pixel_fraction.must_equal 0.19258064

    properties.colors[2].red.must_equal 255
    properties.colors[2].green.must_equal 255
    properties.colors[2].blue.must_equal 255
    properties.colors[2].alpha.must_equal 1.0
    properties.colors[2].rgb.must_equal "ffffff"
    properties.colors[2].score.must_equal 0.1002003
    properties.colors[2].pixel_fraction.must_equal 0.022258064

    properties.colors[3].red.must_equal 3
    properties.colors[3].green.must_equal 4
    properties.colors[3].blue.must_equal 254
    properties.colors[3].alpha.must_equal 1.0
    properties.colors[3].rgb.must_equal "0304fe"
    properties.colors[3].score.must_equal 0.089072376
    properties.colors[3].pixel_fraction.must_equal 0.054516129

    properties.colors[9].red.must_equal 156
    properties.colors[9].green.must_equal 214
    properties.colors[9].blue.must_equal 255
    properties.colors[9].alpha.must_equal 1.0
    properties.colors[9].rgb.must_equal "9cd6ff"
    properties.colors[9].score.must_equal 0.00096750073
    properties.colors[9].pixel_fraction.must_equal 0.00064516132
  end
end
