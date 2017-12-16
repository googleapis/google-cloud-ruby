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

require "vision_helper"
require "pathname"

# This test is a ruby version of gcloud-node's vision test.

describe "Vision", :vision do
  let(:face_image)     { "acceptance/data/face.jpg" }
  let(:logo_image)     { "acceptance/data/logo.jpg" }
  let(:landmark_image) { "acceptance/data/landmark.jpg" }
  let(:text_image)     { "acceptance/data/text.png" }

  let(:https_url)  { "https://raw.githubusercontent.com/GoogleCloudPlatform/google-cloud-ruby/master/acceptance/data/face.jpg" }

  let(:bucket)   { storage.bucket($vision_prefix) || storage.create_bucket($vision_prefix) }
  let(:gcs_file) { bucket.file(face_image) || bucket.create_file(face_image) }
  let(:gcs_url)  { gcs_file.to_gs_url }

  describe "default" do
    it "runs all annotations if none are specified" do
      annotation = vision.annotate face_image

      annotation.must_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.must_be :label?
      annotation.must_be :text?
      annotation.must_be :safe_search?
      annotation.must_be :properties?
      annotation.must_be :crop_hints?
      annotation.must_be :web?
    end

    it "runs all annotations on an HTTPS URL" do
      image = vision.image https_url
      annotation = vision.annotate image

      annotation.must_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.must_be :label?
      annotation.must_be :text?
      annotation.must_be :safe_search?
      annotation.must_be :properties?
      annotation.must_be :web?
    end

    it "runs all annotations on a Storage File" do
      annotation = vision.annotate gcs_file

      annotation.must_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.must_be :label?
      annotation.must_be :text?
      annotation.must_be :safe_search?
      annotation.must_be :properties?
      annotation.must_be :web?
    end

    it "runs all annotations on a GCS URL" do
      image = vision.image gcs_url
      annotation = vision.annotate image

      annotation.must_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.must_be :label?
      annotation.must_be :text?
      annotation.must_be :safe_search?
      annotation.must_be :properties?
      annotation.must_be :web?
    end
  end

  describe "faces" do
    it "detects faces from an image" do
      annotation = vision.annotate face_image, faces: true

      annotation.faces.count.must_equal 1
    end

    it "detects faces from an image with custom max value" do
      annotation = vision.annotate face_image, faces: 1

      annotation.faces.count.must_equal 1
      annotation.faces.each { |f| f.must_be_kind_of Google::Cloud::Vision::Annotation::Face }

      annotation.must_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.wont_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      face = annotation.face
      annotation.face.must_be_kind_of Google::Cloud::Vision::Annotation::Face

      face.bounds.head.must_be_kind_of Array
      face.bounds.head[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      face.bounds.head[0].x.must_equal 122
      face.bounds.head[0].y.must_equal 0
      face.bounds.head[0].to_a.must_equal [122, 0]
      face.bounds.head[1].to_a.must_equal [336, 0]
      face.bounds.head[2].to_a.must_equal [336, 203]
      face.bounds.head[3].to_a.must_equal [122, 203]

      face.bounds.face.must_be_kind_of Array
      face.bounds.face[0].to_a.must_equal [153, 34]
      face.bounds.face[1].to_a.must_equal [299, 34]
      face.bounds.face[2].to_a.must_equal [299, 180]
      face.bounds.face[3].to_a.must_equal [153, 180]

      face.features.wont_be :nil?

      face.features.confidence.must_be_close_to 0.4, 0.1
      face.features.chin.center.must_be_kind_of Google::Cloud::Vision::Annotation::Face::Features::Landmark
      face.features.chin.center.x.must_be_close_to 233.2, 0.1
      face.features.chin.center.y.must_be_close_to 189.4, 0.1
      face.features.chin.center.z.must_be_close_to 19.4, 0.1
      face.features.chin.left.to_a.must_be_close_to_array   [166.70468, 145.37173, 71.187653]
      face.features.chin.right.to_a.must_be_close_to_array  [299.02509, 135.58951, 61.98719]

      face.features.ears.left.to_a.must_be_close_to_array  [157.35168, 99.431313, 87.90876]
      face.features.ears.right.to_a.must_be_close_to_array [303.81198, 88.5782, 77.719193]

      face.features.eyebrows.left.left.to_a.must_be_close_to_array  [168.85481, 69.338295, 3.9220245]
      face.features.eyebrows.left.right.to_a.must_be_close_to_array [206.07896, 70.761108, -16.882086]
      face.features.eyebrows.left.top.to_a.must_be_close_to_array   [186.34938, 63.386711, -12.43734]

      face.features.eyebrows.right.left.to_a.must_be_close_to_array  [237.42259, 68.241989, -19.10948]
      face.features.eyebrows.right.right.to_a.must_be_close_to_array [276.57953, 61.42263, -3.5625641]
      face.features.eyebrows.right.top.to_a.must_be_close_to_array   [256.3194, 58.222664, -17.299419]

      face.features.eyes.left.bottom.to_a.must_be_close_to_array [192.65559, 87.8156, 0.42953849]
      face.features.eyes.left.center.to_a.must_be_close_to_array [189.72849, 82.965874, -0.00075325265]
      face.features.eyes.left.left.to_a.must_be_close_to_array   [179.03802, 83.742157, 6.790463]
      face.features.eyes.left.pupil.to_a.must_be_close_to_array  [190.41544, 84.4557, -1.3682901]
      face.features.eyes.left.right.to_a.must_be_close_to_array  [201.79512, 83.127563, -0.33577749]
      face.features.eyes.left.top.to_a.must_be_close_to_array    [190.90974, 80.660713, -5.1845775]

      face.features.eyes.right.bottom.to_a.must_be_close_to_array [257.98438, 83.214119, -3.9316273]
      face.features.eyes.right.center.to_a.must_be_close_to_array [258.15857, 78.317787, -4.6232729]
      face.features.eyes.right.left.to_a.must_be_close_to_array   [244.01581, 81.332283, -3.0447886]
      face.features.eyes.right.pupil.to_a.must_be_close_to_array  [256.63464, 79.641411, -6.0731235]
      face.features.eyes.right.right.to_a.must_be_close_to_array  [268.5871, 77.159126, 0.41419673]
      face.features.eyes.right.top.to_a.must_be_close_to_array    [255.46104, 75.925194, -9.6693773]

      face.features.forehead.to_a.must_be_close_to_array [221.5365, 69.323875, -20.554575]

      face.features.lips.bottom.to_a.must_be_close_to_array [230.27597, 163.10367, 3.8628895]
      face.features.lips.lower.to_a.must_be_close_to_array  [230.27597, 163.10367, 3.8628895]
      face.features.lips.top.to_a.must_be_close_to_array    [228.54768, 143.2952, -5.6550336]
      face.features.lips.upper.to_a.must_be_close_to_array  [228.54768, 143.2952, -5.6550336]

      face.features.mouth.center.to_a.must_be_close_to_array [228.53499, 150.29066, 1.1069832]
      face.features.mouth.left.to_a.must_be_close_to_array   [204.32407, 149.64627, 15.126297]
      face.features.mouth.right.to_a.must_be_close_to_array  [255.67624, 145.21121, 11.706608]

      face.features.nose.bottom.to_a.must_be_close_to_array [226.5867, 130.57584, -8.9499149]
      face.features.nose.left.to_a.must_be_close_to_array   [209.35193, 126.05315, 1.0702859]
      face.features.nose.right.to_a.must_be_close_to_array  [244.11844, 123.26714, -1.5220336]
      face.features.nose.tip.to_a.must_be_close_to_array    [225.23511, 122.47372, -25.817825]
      face.features.nose.top.to_a.must_be_close_to_array    [222.40179, 83.179443, -15.773396]

      face.likelihood.wont_be :nil?
      face.likelihood.joy?.must_equal false
      face.likelihood.sorrow?.must_equal false
      face.likelihood.anger?.must_equal false
      face.likelihood.surprise?.must_equal false
      face.likelihood.under_exposed?.must_equal false
      face.likelihood.blurred?.must_equal false
      face.likelihood.headwear?.must_equal false

      face.likelihood.joy.must_equal :VERY_UNLIKELY
      face.likelihood.sorrow.must_equal :VERY_UNLIKELY
      face.likelihood.anger.must_equal :VERY_UNLIKELY
      face.likelihood.surprise.must_equal :VERY_UNLIKELY
      face.likelihood.under_exposed.must_equal :VERY_UNLIKELY
      face.likelihood.blurred.must_equal :VERY_UNLIKELY
      face.likelihood.headwear.must_equal :VERY_UNLIKELY
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
      annotation.landmarks.each { |f| f.must_be_kind_of Google::Cloud::Vision::Annotation::Entity }

      annotation.wont_be :face?
      annotation.must_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.wont_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      landmark = annotation.landmark
      landmark.must_be_kind_of Google::Cloud::Vision::Annotation::Entity

      landmark.mid.must_equal "/m/019dvv"
      landmark.locale.must_be :empty?
      landmark.description.must_equal "Mount Rushmore"
      landmark.score.must_be_close_to 0.9, 0.1
      landmark.confidence.must_be :zero?
      landmark.topicality.must_be :zero?
      landmark.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      landmark.bounds[0].x.must_equal 9
      landmark.bounds[0].y.must_equal 35
      landmark.bounds[1].to_a.must_equal [478, 35]
      landmark.bounds[2].to_a.must_equal [478, 319]
      landmark.bounds[3].to_a.must_equal [9, 319]
      landmark.locations[0].must_be_kind_of Google::Cloud::Vision::Location
      landmark.locations[0].latitude.must_be_close_to 43.8, 0.1
      landmark.locations[0].longitude.must_be_close_to -103.4, 0.1
      landmark.properties.must_be :empty?
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
      annotation.logos.each { |l| l.must_be_kind_of Google::Cloud::Vision::Annotation::Entity }

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.must_be :logo?
      annotation.wont_be :label?
      annotation.wont_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      logo = annotation.logo
      logo.must_be_kind_of Google::Cloud::Vision::Annotation::Entity

      logo.mid.must_equal "/m/0b34hf"
      logo.locale.must_be :empty?
      logo.description.must_equal "Google"
      logo.score.must_be_close_to 0.7, 0.1
      logo.confidence.must_be :zero?
      logo.topicality.must_be :zero?
      logo.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      logo.bounds[0].x.must_equal 11
      logo.bounds[0].y.must_equal 14
      logo.bounds[1].to_a.must_equal [335, 14]
      logo.bounds[2].to_a.must_equal [335, 84]
      logo.bounds[3].to_a.must_equal [11,  84]
      logo.locations.must_be :empty?
      logo.properties.must_be :empty?
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

      annotation.labels.count.must_be :>, 0
      annotation.logos.each { |l| l.must_be_kind_of Google::Cloud::Vision::Annotation::Entity }

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.must_be :label?
      annotation.wont_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      label = annotation.label
      label.must_be_kind_of Google::Cloud::Vision::Annotation::Entity

      label.mid.must_be_kind_of String
      label.locale.must_be :empty?
      label.description.must_be_kind_of String
      label.score.must_be_kind_of Float
      label.confidence.must_be :zero?
      label.topicality.must_be :zero?
      label.bounds.must_be :empty?
      label.locations.must_be :empty?
      label.properties.must_be :empty?
    end

    it "detects labels from an image with custom max value" do
      annotation = vision.annotate landmark_image, labels: 10

      annotation.labels.count.must_be :>, 0
    end

    it "detects labels from multiple images" do
      annotations = vision.annotate landmark_image,
                             face_image,
                             labels: 10

      annotations.count.must_equal 2
      annotations[0].labels.count.must_be :>, 0
      annotations[1].labels.count.must_be :>, 0
    end
  end

  describe "text" do
    it "detects text from an image" do
      annotation = vision.annotate text_image, text: true

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.must_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      text = annotation.text
      text.must_be_kind_of Google::Cloud::Vision::Annotation::Text

      text.text.must_include "Google Cloud Client Library for Ruby"
      text.locale.must_equal "en"

      text.words.count.must_equal 28
      text.words[0].must_be_kind_of Google::Cloud::Vision::Annotation::Text::Word
      text.words[0].text.must_be_kind_of String
      text.words[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.words[0].text.must_equal "Google"
      text.words[0].bounds.count.must_equal 4
      text.words[27].text.must_equal "Storage."
      text.words[27].bounds.count.must_equal 4

      text.pages.count.must_equal 1
      text.pages[0].must_be_kind_of Google::Cloud::Vision::Annotation::Text::Page
      text.pages[0].languages.count.must_equal 1
      text.pages[0].languages[0].code.must_equal "en"
      text.pages[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].break_type.must_be :nil?
      text.pages[0].wont_be :prefix_break?
      text.pages[0].width.must_equal 400
      text.pages[0].height.must_equal 80

      text.pages[0].blocks.count.must_equal 1
      text.pages[0].blocks[0].languages[0].code.must_equal "en"
      text.pages[0].blocks[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].blocks[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].blocks[0].break_type.must_be :nil?
      text.pages[0].blocks[0].wont_be :prefix_break?
      text.pages[0].blocks[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].bounds.count.must_equal 4

      text.pages[0].blocks[0].paragraphs.count.must_equal 1
      text.pages[0].blocks[0].paragraphs[0].languages[0].code.must_equal "en"
      text.pages[0].blocks[0].paragraphs[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].blocks[0].paragraphs[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].blocks[0].paragraphs[0].break_type.must_be :nil?
      text.pages[0].blocks[0].paragraphs[0].wont_be :prefix_break?
      text.pages[0].blocks[0].paragraphs[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].paragraphs[0].bounds.count.must_equal 4

      text.pages[0].blocks[0].paragraphs[0].words.count.must_equal 28
      text.pages[0].blocks[0].paragraphs[0].words[0].languages[0].code.must_equal "en"
      text.pages[0].blocks[0].paragraphs[0].words[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].blocks[0].paragraphs[0].words[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].blocks[0].paragraphs[0].words[0].break_type.must_be :nil?
      text.pages[0].blocks[0].paragraphs[0].words[0].wont_be :prefix_break?
      text.pages[0].blocks[0].paragraphs[0].words[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].paragraphs[0].words[0].bounds.count.must_equal 4

      text.pages[0].blocks[0].paragraphs[0].words[0].symbols.count.must_equal 6
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].languages[0].code.must_equal "en"
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].break_type.must_be :nil?
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].wont_be :prefix_break?
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].bounds.count.must_equal 4
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].text.must_equal "G"
    end

    it "detects text from multiple images" do
      annotations = vision.annotate text_image,
                             face_image,
                             logo_image,
                             text: true

      annotations.count.must_equal 3
      annotations[0].text.wont_be :nil?
      annotations[1].text.wont_be :nil?
      annotations[2].text.wont_be :nil?
    end

    it "detects text from an image with context properties" do
      image = vision.image text_image
      image.context.languages = ["en"]
      annotation = vision.annotate image, text: true

      text = annotation.text
      text.must_be_kind_of Google::Cloud::Vision::Annotation::Text

      text.text.must_include "Google Cloud Client Library for Ruby"
      text.locale.must_equal "en"
      text.words.count.must_equal 28
      text.pages.count.must_equal 1
    end
  end

  describe "document" do
    it "detects text from an image with document option" do
      annotation = vision.annotate text_image, document: true

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.must_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      text = annotation.text
      text.must_be_kind_of Google::Cloud::Vision::Annotation::Text

      text.text.must_include "Google Cloud Client Library for Ruby"
      text.locale.must_equal "en"

      text.words.count.must_equal 33
      text.words[0].must_be_kind_of Google::Cloud::Vision::Annotation::Text::Word
      text.words[0].text.must_be_kind_of String
      text.words[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.words[0].text.must_equal "Google"
      text.words[0].bounds.count.must_equal 4
      text.words[27].text.must_equal "Cloud"
      text.words[27].bounds.count.must_equal 4

      text.pages.count.must_equal 1
      text.pages[0].must_be_kind_of Google::Cloud::Vision::Annotation::Text::Page
      text.pages[0].languages.count.must_equal 1
      text.pages[0].languages[0].code.must_equal "en"
      text.pages[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].break_type.must_be :nil?
      text.pages[0].wont_be :prefix_break?
      text.pages[0].width.must_equal 400
      text.pages[0].height.must_equal 80

      text.pages[0].blocks.count.must_equal 1
      text.pages[0].blocks[0].languages.must_be :empty?
      text.pages[0].blocks[0].break_type.must_be :nil?
      text.pages[0].blocks[0].wont_be :prefix_break?
      text.pages[0].blocks[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].bounds.count.must_equal 4

      text.pages[0].blocks[0].paragraphs.count.must_equal 1
      text.pages[0].blocks[0].paragraphs[0].languages.must_be :empty?
      text.pages[0].blocks[0].paragraphs[0].break_type.must_be :nil?
      text.pages[0].blocks[0].paragraphs[0].wont_be :prefix_break?
      text.pages[0].blocks[0].paragraphs[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].paragraphs[0].bounds.count.must_equal 4

      text.pages[0].blocks[0].paragraphs[0].words.count.must_equal 33
      text.pages[0].blocks[0].paragraphs[0].words[0].languages[0].code.must_equal "en"
      text.pages[0].blocks[0].paragraphs[0].words[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].blocks[0].paragraphs[0].words[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].blocks[0].paragraphs[0].words[0].break_type.must_be :nil?
      text.pages[0].blocks[0].paragraphs[0].words[0].wont_be :prefix_break?
      text.pages[0].blocks[0].paragraphs[0].words[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].paragraphs[0].words[0].bounds.count.must_equal 4

      text.pages[0].blocks[0].paragraphs[0].words[0].symbols.count.must_equal 6
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].languages[0].code.must_equal "en"
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].languages[0].confidence.must_be_kind_of Float
      # text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].languages[0].confidence.must_be :>, 0  #TODO: investigate why 0.0 returned for obvious english text
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].break_type.must_be :nil?
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].wont_be :prefix_break?
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].bounds.first.must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].bounds.count.must_equal 4
      text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].text.must_equal "G"
    end

    it "detects text from multiple images with document option" do
      annotations = vision.annotate text_image,
                             face_image,
                             logo_image,
                             document: true

      annotations.count.must_equal 3
      annotations[0].text.wont_be :nil?
      annotations[1].text.wont_be :nil?
      annotations[2].text.wont_be :nil?
    end

    it "detects text from an image with context properties with document option" do
      image = vision.image text_image
      image.context.languages = ["en"]
      annotation = vision.annotate image, document: true

      text = annotation.text
      text.must_be_kind_of Google::Cloud::Vision::Annotation::Text

      text.text.must_include "Google Cloud Client Library for Ruby"
      text.locale.must_equal "en"
      text.words.count.must_equal 33
      text.pages.count.must_equal 1
    end
  end

  describe "safe_search" do
    it "detects safe_search from an image" do
      annotation = vision.annotate face_image, safe_search: true

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.wont_be :text?
      annotation.must_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      annotation.safe_search.wont_be :nil?
      annotation.safe_search.wont_be :adult?
      annotation.safe_search.wont_be :spoof?
      annotation.safe_search.wont_be :medical?
      annotation.safe_search.wont_be :violence?
    end

    it "detects safe_search from multiple images" do
      annotations = vision.annotate text_image,
                             landmark_image,
                             logo_image,
                             safe_search: true

      annotations.count.must_equal 3
      annotations[0].safe_search.wont_be :nil?
      annotations[0].safe_search.wont_be :adult?
      annotations[0].safe_search.wont_be :spoof?
      # annotations[0].safe_search.must_be :medical?
      annotations[0].safe_search.wont_be :violence?
      annotations[1].safe_search.wont_be :nil?
      annotations[1].safe_search.wont_be :adult?
      annotations[1].safe_search.wont_be :spoof?
      # annotations[1].safe_search.wont_be :medical?
      annotations[1].safe_search.wont_be :violence?
      annotations[2].safe_search.wont_be :nil?
      annotations[2].safe_search.wont_be :adult?
      annotations[2].safe_search.wont_be :spoof?
      # annotations[2].safe_search.wont_be :medical?
      annotations[2].safe_search.wont_be :violence?
    end
  end

  describe "properties" do
    it "detects properties from an image" do
      annotation = vision.annotate text_image, properties: true

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.wont_be :text?
      annotation.wont_be :safe_search?
      annotation.must_be :properties?
      # annotation.wont_be :crop_hints?
      annotation.wont_be :web?

      annotation.properties.wont_be :nil?
      annotation.properties.colors.count.must_equal 10

      annotation.properties.colors[0].must_be_kind_of Google::Cloud::Vision::Annotation::Properties::Color
      annotation.properties.colors[0].red.must_equal 145
      annotation.properties.colors[0].green.must_equal 193
      annotation.properties.colors[0].blue.must_equal 254
      annotation.properties.colors[0].alpha.must_equal 1.0
      annotation.properties.colors[0].rgb.must_equal "91c1fe"
      annotation.properties.colors[0].score.must_be_close_to 0.6, 0.1
      annotation.properties.colors[0].pixel_fraction.must_be_close_to 0.1, 0.1

      annotation.properties.colors[9].red.must_equal 156
      annotation.properties.colors[9].green.must_equal 214
      annotation.properties.colors[9].blue.must_equal 255
      annotation.properties.colors[9].alpha.must_equal 1.0
      annotation.properties.colors[9].rgb.must_equal "9cd6ff"
      annotation.properties.colors[9].score.must_be_close_to 0.0, 0.1
      annotation.properties.colors[9].pixel_fraction.must_be_close_to 0.0, 0.1
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

  describe "crop_hints" do
    it "detects crop hints from an image" do
      annotation = vision.annotate face_image, crop_hints: true

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.wont_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.must_be :crop_hints?
      annotation.wont_be :web?

      crop_hints = annotation.crop_hints
      crop_hints.count.must_equal 1
      crop_hint = crop_hints.first
      crop_hint.must_be_kind_of Google::Cloud::Vision::Annotation::CropHint

      crop_hint.bounds.count.must_equal 4
      crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex

      crop_hint.confidence.must_be_kind_of Float
      crop_hint.confidence.wont_be :zero?
      crop_hint.importance_fraction.must_be_kind_of Float
      crop_hint.importance_fraction.wont_be :zero?
    end

    it "detects crop hints from multiple images" do
      annotations = vision.annotate text_image,
                             face_image,
                             logo_image,
                             crop_hints: true

      annotations.count.must_equal 3
      annotations[0].crop_hints.wont_be :nil?
      annotations[1].crop_hints.wont_be :nil?
      annotations[2].crop_hints.wont_be :nil?
    end

    it "detects crop hints from an image with context aspect ratios" do
      image = vision.image face_image
      image.context.aspect_ratios = [1.0] # square
      annotation = vision.annotate image, crop_hints: true

      crop_hints = annotation.crop_hints
      crop_hints.count.must_equal 1
      crop_hint = crop_hints.first
      crop_hint.must_be_kind_of Google::Cloud::Vision::Annotation::CropHint

      crop_hint.bounds.count.must_equal 4
      crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
    end
  end

  describe "web" do
    it "detects web matches from an image" do
      annotation = vision.annotate landmark_image, web: true

      annotation.wont_be :face?
      annotation.wont_be :landmark?
      annotation.wont_be :logo?
      annotation.wont_be :label?
      annotation.wont_be :text?
      annotation.wont_be :safe_search?
      annotation.wont_be :properties?
      annotation.wont_be :crop_hints?
      annotation.must_be :web?

      annotation.web.wont_be :nil?

      annotation.web.entities.count.must_be :>, 0
      annotation.web.entities[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Entity
      annotation.web.entities[0].entity_id.must_equal "/m/019dvv"
      annotation.web.entities[0].score.must_be_kind_of Float
      annotation.web.entities[0].score.wont_be :zero?
      annotation.web.entities[0].description.must_equal "Mount Rushmore National Memorial"

      annotation.web.full_matching_images.count.wont_be :zero?
      annotation.web.full_matching_images.each do |full_matching_image|
        full_matching_image.must_be_kind_of Google::Cloud::Vision::Annotation::Web::Image
        full_matching_image.url.must_be_kind_of String
        full_matching_image.url.wont_be :empty?
        full_matching_image.score.must_be_kind_of Float
      end

      annotation.web.partial_matching_images.count.wont_be :zero?
      annotation.web.partial_matching_images.each do |partial_matching_image|
        partial_matching_image.must_be_kind_of Google::Cloud::Vision::Annotation::Web::Image
        partial_matching_image.url.must_be_kind_of String
        partial_matching_image.url.wont_be :empty?
        partial_matching_image.score.must_be_kind_of Float
      end

      annotation.web.pages_with_matching_images.count.wont_be :zero?
      annotation.web.pages_with_matching_images.each do |pages_with_matching_image|
        pages_with_matching_image.must_be_kind_of Google::Cloud::Vision::Annotation::Web::Page
        pages_with_matching_image.url.must_be_kind_of String
        pages_with_matching_image.url.wont_be :empty?
        pages_with_matching_image.score.must_be_kind_of Float
      end
    end

    it "detects web from multiple images" do
      annotations = vision.annotate text_image,
                             face_image,
                             logo_image,
                             web: 10

      annotations.count.must_equal 3
      annotations[0].web.wont_be :nil?
      annotations[1].web.wont_be :nil?
      annotations[2].web.wont_be :nil?
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

        labels.count.must_be :>, 0
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
        text.words[0].bounds.count.must_equal 4
        text.words[27].text.must_equal "Storage."
        text.words[27].bounds.count.must_equal 4
      end

      it "detects text with language hints properties" do
        image = vision.image text_image
        image.context.languages = ["en"]
        text = image.text

        text.text.must_include "Google Cloud Client Library for Ruby"
        text.locale.must_equal "en"
        text.words.count.must_equal 28
        text.words[0].text.must_equal "Google"
        text.words[0].bounds.count.must_equal 4
        text.words[27].text.must_equal "Storage."
        text.words[27].bounds.count.must_equal 4
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
        properties.colors[0].score.must_be_close_to 0.6, 0.1
        properties.colors[0].pixel_fraction.must_be_close_to 0.1, 0.1

        properties.colors[9].red.must_equal 156
        properties.colors[9].green.must_equal 214
        properties.colors[9].blue.must_equal 255
        properties.colors[9].alpha.must_equal 1.0
        properties.colors[9].rgb.must_equal "9cd6ff"
        properties.colors[9].score.must_be_close_to 0.0, 0.1
        properties.colors[9].pixel_fraction.must_be_close_to 0.0, 0.1
      end
    end

    describe "crop_hints" do
      it "detects crop hints" do
        crop_hints = vision.image(face_image).crop_hints

        crop_hints.count.must_equal 1
        crop_hint = crop_hints.first
        crop_hint.must_be_kind_of Google::Cloud::Vision::Annotation::CropHint

        crop_hint.bounds.count.must_equal 4
        crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex

        crop_hint.confidence.must_be_kind_of Float
        crop_hint.confidence.wont_be :zero?
        crop_hint.importance_fraction.must_be_kind_of Float
        crop_hint.importance_fraction.wont_be :zero?
      end

      it "detects crop hints with context aspect ratios" do
        image = vision.image face_image
        image.context.aspect_ratios = [1.0] # square
        crop_hints = image.crop_hints

        crop_hints.count.must_equal 1
        crop_hint = crop_hints.first
        crop_hint.must_be_kind_of Google::Cloud::Vision::Annotation::CropHint

        crop_hint.bounds.count.must_equal 4
        crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
      end
    end

    describe "web" do
      it "detects web matches" do
        web = vision.image(landmark_image).web 10

        web.entities.count.must_equal 10
        web.full_matching_images.count.must_equal 10
        web.partial_matching_images.count.must_equal 10
        web.pages_with_matching_images.count.must_equal 10
      end
    end
  end
end
