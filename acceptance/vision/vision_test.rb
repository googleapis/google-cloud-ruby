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
      annotation = vision.annotate face_image, faces: true

      annotation.faces.count.must_equal 1
    end

    it "detects faces from an image with custom max value" do
      annotation = vision.annotate face_image, faces: 1

      annotation.faces.count.must_equal 1
    end

    it "detects faces from an image with location context" do
      image = vision.image face_image
      image.context.area.min.latitude = 37.4220041
      image.context.area.min.longitude = -122.0862462
      image.context.area.max.latitude = 37.4320041
      image.context.area.max.longitude = -122.0762462
      annotation = vision.annotate image, faces: 1

      annotation.faces.count.must_equal 1
    end

    it "detects faces from multiple images" do
      annotations = vision.annotate face_image,
                             File.open(logo_image, "rb"),
                             Pathname.new(landmark_image),
                             faces: 1

      annotations.count.must_equal 3
      annotations[0].faces.count.must_equal 1
      annotations[1].faces.count.must_equal 0
      annotations[2].faces.count.must_equal 1
    end
  end

  describe "landmarks" do
    it "detects landmarks from an image" do
      annotation = vision.annotate landmark_image, landmarks: true

      annotation.landmarks.count.must_equal 1
    end

    it "detects landmarks from an image with custom max value" do
      annotation = vision.annotate landmark_image, landmarks: 1

      annotation.landmarks.count.must_equal 1
    end

    it "detects landmarks from multiple images" do
      annotations = vision.annotate landmark_image,
                             File.open(logo_image, "rb"),
                             landmarks: 1

      annotations.count.must_equal 2
      annotations[0].landmarks.count.must_equal 1
      annotations[1].landmarks.count.must_equal 0
    end
  end

  describe "logos" do
    it "detects logos from an image" do
      annotation = vision.annotate logo_image, logos: true

      annotation.logos.count.must_equal 1
    end

    it "detects logos from an image with custom max value" do
      annotation = vision.annotate logo_image, logos: 1

      annotation.logos.count.must_equal 1
    end

    it "detects logos from multiple images" do
      annotations = vision.annotate logo_image,
                             StringIO.new(File.read(face_image, mode: "rb")),
                             logos: 1

      annotations.count.must_equal 2
      annotations[0].logos.count.must_equal 1
      annotations[1].logos.count.must_equal 0
    end
  end

  describe "labels" do
    it "detects labels from an image" do
      annotation = vision.annotate landmark_image, labels: true

      annotation.labels.count.must_equal 6
    end

    it "detects labels from an image with custom max value" do
      annotation = vision.annotate landmark_image, labels: 10

      annotation.labels.count.must_equal 6
    end

    it "detects labels from multiple images" do
      annotations = vision.annotate landmark_image,
                             face_image,
                             labels: 10

      annotations.count.must_equal 2
      annotations[0].labels.count.must_equal 6
      annotations[1].labels.count.must_equal 4
    end
  end

  describe "text" do
    it "detects text from an image" do
      annotation = vision.annotate text_image, text: true

      annotation.text.text.must_include "Google Cloud Client Library for Ruby"
      annotation.text.locale.must_equal "en"
      annotation.text.words.count.must_equal 28
      annotation.text.words[0].text.must_equal "Google"
      annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
      annotation.text.words[27].text.must_equal "Storage."
      annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
    end

    it "detects text from multiple images" do
      annotations = vision.annotate text_image,
                             face_image,
                             logo_image,
                             text: true

      annotations.count.must_equal 3
      annotations[0].text.wont_be :nil?
      annotations[1].text.must_be :nil?
      annotations[2].text.wont_be :nil?
    end

    it "detects text from an image with context properties" do
      image = vision.image text_image
      image.context.languages = ["en"]
      annotation = vision.annotate image, text: true

      annotation.text.text.must_include "Google Cloud Client Library for Ruby"
      annotation.text.locale.must_equal "en"
      annotation.text.words.count.must_equal 28
      annotation.text.words[0].text.must_equal "Google"
      annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
      annotation.text.words[27].text.must_equal "Storage."
      annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
    end
  end

  describe "safe_search" do
    it "detects safe_search from an image" do
      annotation = vision.annotate face_image, safe_search: true

      annotation.safe_search.wont_be :nil?
      annotation.safe_search.wont_be :adult?
      annotation.safe_search.wont_be :spoof?
      annotation.safe_search.wont_be :medical?
      annotation.safe_search.wont_be :violence?
    end

    it "detects safe_search from multiple images" do
      annotations = vision.annotate text_image,
                             landmark_image,
                             text_image,
                             safe_search: true

      annotations.count.must_equal 3
      annotations[0].safe_search.wont_be :nil?
      annotations[0].safe_search.wont_be :adult?
      annotations[0].safe_search.wont_be :spoof?
      annotations[0].safe_search.wont_be :medical?
      annotations[0].safe_search.wont_be :violence?
      annotations[1].safe_search.wont_be :nil?
      annotations[1].safe_search.wont_be :adult?
      annotations[1].safe_search.wont_be :spoof?
      annotations[1].safe_search.wont_be :medical?
      annotations[1].safe_search.wont_be :violence?
      annotations[2].safe_search.wont_be :nil?
      annotations[2].safe_search.wont_be :adult?
      annotations[2].safe_search.wont_be :spoof?
      annotations[2].safe_search.wont_be :medical?
      annotations[2].safe_search.wont_be :violence?
    end
  end

  describe "properties" do
    it "detects properties from an image" do
      annotation = vision.annotate text_image, properties: true

      annotation.properties.wont_be :nil?
      annotation.properties.colors.count.must_equal 10

      annotation.properties.colors[0].red.must_equal 145
      annotation.properties.colors[0].green.must_equal 193
      annotation.properties.colors[0].blue.must_equal 254
      annotation.properties.colors[0].alpha.must_equal 1.0
      annotation.properties.colors[0].rgb.must_equal "91c1fe"
      annotation.properties.colors[0].score.must_equal 0.65757853
      annotation.properties.colors[0].pixel_fraction.must_equal 0.16903226

      annotation.properties.colors[9].red.must_equal 156
      annotation.properties.colors[9].green.must_equal 214
      annotation.properties.colors[9].blue.must_equal 255
      annotation.properties.colors[9].alpha.must_equal 1.0
      annotation.properties.colors[9].rgb.must_equal "9cd6ff"
      annotation.properties.colors[9].score.must_equal 0.00096750073
      annotation.properties.colors[9].pixel_fraction.must_equal 0.00064516132
    end

    it "detects properties from multiple images" do
      annotations = vision.annotate text_image,
                             face_image,
                             logo_image,
                             properties: true

      annotations.count.must_equal 3
      annotations[0].properties.wont_be :nil?
      annotations[1].properties.wont_be :nil?
      annotations[2].properties.wont_be :nil?
    end
  end

  describe "image" do
    describe "faces" do
      it "detects faces" do
        faces = vision.image(face_image).faces 10

        faces.count.must_equal 1
      end

      it "detects a single faces" do
        face = vision.image(face_image).face

        face.wont_be :nil?
      end

      it "detects a single face with location context" do
        image = vision.image face_image
        image.context.area.min.latitude = 37.4220041
        image.context.area.min.longitude = -122.0862462
        image.context.area.max.latitude = 37.4320041
        image.context.area.max.longitude = -122.0762462
        face = image.face

        face.wont_be :nil?
      end
    end

    describe "landmarks" do
      it "detects landmarks" do
        landmarks = vision.image(landmark_image).landmarks 10

        landmarks.count.must_equal 1
      end

      it "detects a single landmark" do
        landmark = vision.image(landmark_image).landmark

        landmark.wont_be :nil?
      end
    end

    describe "logos" do
      it "detects logos" do
        logos = vision.image(logo_image).logos 10

        logos.count.must_equal 1
      end

      it "detects a single logo" do
        logo = vision.image(logo_image).logo

        logo.wont_be :nil?
      end
    end

    describe "labels" do
      it "detects labels" do
        labels = vision.image(landmark_image).labels 10

        labels.count.must_equal 6
      end

      it "detects a single label" do
        label = vision.image(landmark_image).label

        label.wont_be :nil?
      end
    end

    describe "text" do
      it "detects text" do
        text = vision.image(text_image).text

        text.text.must_include "Google Cloud Client Library for Ruby"
        text.locale.must_equal "en"
        text.words.count.must_equal 28
        text.words[0].text.must_equal "Google"
        text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
        text.words[27].text.must_equal "Storage."
        text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
      end

      it "detects text with language hints properties" do
        image = vision.image text_image
        image.context.languages = ["en"]
        text = image.text

        text.text.must_include "Google Cloud Client Library for Ruby"
        text.locale.must_equal "en"
        text.words.count.must_equal 28
        text.words[0].text.must_equal "Google"
        text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
        text.words[27].text.must_equal "Storage."
        text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
      end
    end

    describe "safe_search" do
      it "detects safe_search" do
        safe_search = vision.image(face_image).safe_search

        safe_search.wont_be :nil?
        safe_search.wont_be :adult?
        safe_search.wont_be :spoof?
        safe_search.wont_be :medical?
        safe_search.wont_be :violence?
      end
    end

    describe "properties" do
      it "detects properties" do
        properties = vision.image(text_image).properties

        properties.wont_be :nil?
        properties.colors.count.must_equal 10

        properties.colors[0].red.must_equal 145
        properties.colors[0].green.must_equal 193
        properties.colors[0].blue.must_equal 254
        properties.colors[0].alpha.must_equal 1.0
        properties.colors[0].rgb.must_equal "91c1fe"
        properties.colors[0].score.must_equal 0.65757853
        properties.colors[0].pixel_fraction.must_equal 0.16903226

        properties.colors[9].red.must_equal 156
        properties.colors[9].green.must_equal 214
        properties.colors[9].blue.must_equal 255
        properties.colors[9].alpha.must_equal 1.0
        properties.colors[9].rgb.must_equal "9cd6ff"
        properties.colors[9].score.must_equal 0.00096750073
        properties.colors[9].pixel_fraction.must_equal 0.00064516132
      end
    end
  end
end
