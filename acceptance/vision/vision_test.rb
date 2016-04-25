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

require "vision_helper"

# This test is a ruby version of gcloud-node's vision test.

describe "Vision", :vision do
  let(:face_image)     { "acceptance/data/face.jpg" }
  let(:logo_image)     { "acceptance/data/logo.jpg" }
  let(:location_image) { "acceptance/data/location.jpg" }
  let(:text_image)     { "acceptance/data/text.png" }

  describe "faces" do
    it "detects faces from an image" do
      analysis = vision.mark face_image, faces: 1

      analysis.faces.count.must_equal 1
    end

    it "detects faces from multiple images" do
      analyses = vision.mark face_image, logo_image, location_image, faces: 1

      analyses.count.must_equal 3
      analyses[0].faces.count.must_equal 1
      analyses[1].faces.count.must_equal 0
      analyses[2].faces.count.must_equal 1
    end
  end
end
