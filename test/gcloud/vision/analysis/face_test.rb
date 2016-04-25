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

describe Gcloud::Vision::Analysis::Face, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:gapi) { JSON.parse(face_annotation_response.to_json) }
  let(:face) { Gcloud::Vision::Analysis::Face.from_gapi gapi }

  it "knows the angles" do
    face.angles.wont_be :nil?

    face.angles.roll.must_equal -0.050002542
    face.angles.yaw.must_equal -0.081090336
    face.angles.pan.must_equal -0.081090336
    face.angles.pitch.must_equal 0.18012161
    face.angles.tilt.must_equal 0.18012161
  end

  it "knows the bounds" do
    face.bounds.wont_be :nil?

    face.bounds.head.must_be_kind_of Array
    face.bounds.head[0].to_a.must_equal [1, 0]
    face.bounds.head[1].to_a.must_equal [295, 0]
    face.bounds.head[2].to_a.must_equal [295, 301]
    face.bounds.head[3].to_a.must_equal [1, 301]

    face.bounds.face.must_be_kind_of Array
    face.bounds.face[0].to_a.must_equal [28, 40]
    face.bounds.face[1].to_a.must_equal [250, 40]
    face.bounds.face[2].to_a.must_equal [250, 262]
    face.bounds.face[3].to_a.must_equal [28, 262]
  end

  it "knows the features" do
    face.features.wont_be :nil?

    face.features.confidence.must_equal 34.489909

    face.features.chin.center.to_a.must_equal [143.34183, 262.22998, -57.388493]
    face.features.chin.left.to_a.must_equal   [63.102425, 248.99081, 44.207638]
    face.features.chin.right.to_a.must_equal  [241.72728, 225.53488, 19.758242]

    face.features.ears.left.to_a.must_equal  [54.872219, 207.23712, 97.030685]
    face.features.ears.right.to_a.must_equal [252.67567, 180.43124, 70.15992]

    face.features.eyebrows.left.left.to_a.must_equal  [58.790176, 113.28249, 17.89735]
    face.features.eyebrows.left.right.to_a.must_equal [106.14151, 98.593758, -13.116687]
    face.features.eyebrows.left.top.to_a.must_equal   [80.248711, 94.04303, 0.21131183]

    face.features.eyebrows.right.left.to_a.must_equal  [148.61565, 92.294594, -18.804882]
    face.features.eyebrows.right.right.to_a.must_equal [204.40808, 94.300117, -2.0009689]
    face.features.eyebrows.right.top.to_a.must_equal   [174.70135, 81.580917, -12.702137]

    face.features.eyes.left.bottom.to_a.must_equal [84.883934, 134.59479, -2.8677137]
    face.features.eyes.left.center.to_a.must_equal [83.707092, 128.34, -0.00013388535]
    face.features.eyes.left.left.to_a.must_equal [72.213913, 132.04138, 9.6985674]
    face.features.eyes.left.pupil.to_a.must_equal [86.531624, 126.49807, -2.2496929]
    face.features.eyes.left.right.to_a.must_equal [105.28892, 125.57655, -2.51554]
    face.features.eyes.left.top.to_a.must_equal [86.706947, 119.47144, -4.1606765]

    face.features.eyes.right.bottom.to_a.must_equal [179.30353, 121.03307, -14.843414]
    face.features.eyes.right.center.to_a.must_equal [181.17694, 115.16437, -12.82961]
    face.features.eyes.right.left.to_a.must_equal [158.2863, 118.491, -9.723031]
    face.features.eyes.right.pupil.to_a.must_equal [175.99976, 114.64407, -14.53744]
    face.features.eyes.right.right.to_a.must_equal [194.59413, 115.91954, -6.952745]
    face.features.eyes.right.top.to_a.must_equal [173.99446, 107.94287, -16.050705]

    face.features.forehead.to_a.must_equal [126.53813, 93.812057, -18.863352]

    face.features.lips.bottom.to_a.must_equal [137.28528, 219.23564, -56.663128]
    face.features.lips.lower.to_a.must_equal [137.28528, 219.23564, -56.663128]
    face.features.lips.top.to_a.must_equal [134.74164, 192.50438, -53.876408]
    face.features.lips.upper.to_a.must_equal [134.74164, 192.50438, -53.876408]

    face.features.mouth.center.to_a.must_equal [136.43481, 204.37952, -51.620205]
    face.features.mouth.left.to_a.must_equal [104.53558, 214.05037, -30.056231]
    face.features.mouth.right.to_a.must_equal [173.79134, 204.99333, -39.725758]

    face.features.nose.bottom.to_a.must_equal [133.81947, 173.16437, -48.287724]
    face.features.nose.left.to_a.must_equal [110.98372, 173.61331, -29.7784]
    face.features.nose.right.to_a.must_equal [161.31354, 168.24527, -36.1628]
    face.features.nose.tip.to_a.must_equal [128.14919, 153.68129, -63.198204]
    face.features.nose.top.to_a.must_equal [127.83745, 110.17557, -22.650913]
  end

  it "knows the likelihood" do
    face.likelihood.wont_be :nil?

    face.likelihood.joy?.must_equal true
    face.likelihood.sorrow?.must_equal false
    face.likelihood.anger?.must_equal false
    face.likelihood.surprise?.must_equal false
    face.likelihood.under_exposed?.must_equal false
    face.likelihood.blurred?.must_equal false
    face.likelihood.headwear?.must_equal false

    face.likelihood.joy.must_equal "LIKELY"
    face.likelihood.sorrow.must_equal "UNLIKELY"
    face.likelihood.anger.must_equal "VERY_UNLIKELY"
    face.likelihood.surprise.must_equal "UNLIKELY"
    face.likelihood.under_exposed.must_equal "VERY_UNLIKELY"
    face.likelihood.blurred.must_equal "VERY_UNLIKELY"
    face.likelihood.headwear.must_equal "VERY_UNLIKELY"
  end
end
