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
require "pathname"

# This test is a ruby version of gcloud-node's vision test.

describe "Vision", :vision do
  let(:face_image)     { "acceptance/data/face.jpg" }
  let(:logo_image)     { "acceptance/data/logo.jpg" }
  let(:landmark_image) { "acceptance/data/landmark.jpg" }
  let(:text_image)     { "acceptance/data/text.png" }

  describe "faces" do
    it "detects faces from an image" do
      analysis = vision.mark face_image, faces: 1

      analysis.faces.count.must_equal 1
    end

    it "detects faces from multiple images" do
      analyses = vision.mark face_image,
                             File.open(logo_image, "rb"),
                             Pathname.new(landmark_image),
                             faces: 1

      analyses.count.must_equal 3
      analyses[0].faces.count.must_equal 1
      analyses[1].faces.count.must_equal 0
      analyses[2].faces.count.must_equal 1
    end
  end

  describe "landmarks" do
    it "detects landmarks from an image" do
      analysis = vision.mark landmark_image, landmarks: 1

      analysis.landmarks.count.must_equal 1
    end

    it "detects landmarks from multiple images" do
      analyses = vision.mark landmark_image,
                             File.open(logo_image, "rb"),
                             landmarks: 1

      analyses.count.must_equal 2
      analyses[0].landmarks.count.must_equal 1
      analyses[1].landmarks.count.must_equal 0
    end
  end

  describe "logos" do
    it "detects logos from an image" do
      analysis = vision.mark logo_image, logos: 1

      analysis.logos.count.must_equal 1
    end

    it "detects logos from multiple images" do
      analyses = vision.mark logo_image,
                             StringIO.new(File.read(face_image, mode: "rb")),
                             logos: 1

      analyses.count.must_equal 2
      analyses[0].logos.count.must_equal 1
      analyses[1].logos.count.must_equal 0
    end
  end

  describe "labels" do
    it "detects labels from an image" do
      analysis = vision.mark landmark_image, labels: 10

      analysis.labels.count.must_equal 6
    end

    it "detects labels from multiple images" do
      analyses = vision.mark landmark_image,
                             face_image,
                             labels: 10

      analyses.count.must_equal 2
      analyses[0].labels.count.must_equal 6
      analyses[1].labels.count.must_equal 4
    end
  end

  describe "text" do
    it "detects text from an image" do
      analysis = vision.mark text_image, text: true

      analysis.texts.count.must_equal 29
    end

    it "detects text from multiple images" do
      analyses = vision.mark text_image,
                             face_image,
                             logo_image,
                             text: true

      analyses.count.must_equal 3
      analyses[0].texts.count.must_equal 29
      analyses[1].texts.count.must_equal 0
      analyses[2].texts.count.must_equal 2
    end
  end
end
