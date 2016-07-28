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

describe Google::Cloud::Vision::Project, :mock_vision do
  let(:filepath) { "../acceptance/data/face.jpg" }
  let(:area_json) { {"min_lat_lng"=>{"latitude"=>37.4220041, "longitude"=>-122.0862462},
                     "max_lat_lng"=>{"latitude"=>37.4320041, "longitude"=>-122.0762462}} }

  it "knows the project identifier" do
    vision.must_be_kind_of Google::Cloud::Vision::Project
    vision.project.must_equal project
  end

  it "builds an image from filepath input" do
    image = vision.image filepath

    image.wont_be :nil?
    image.must_be_kind_of Google::Cloud::Vision::Image
    image.must_be :io?
    image.wont_be :url?
  end

  it "allows different annotation options for different images" do
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 10),
            Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1)
          ]
        ),
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Apis::VisionV1::Feature.new(type: "LANDMARK_DETECTION", max_results: 20),
            Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1)
          ]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, faces_response_gapi, [req]

    vision.service.mocked_service = mock
    annotations = vision.annotate do |a|
      a.annotate filepath, faces: 10, text: true
      a.annotate filepath, landmarks: 20, safe_search: true
    end
    mock.verify

    annotations.count.must_equal 2
    annotations.first.face.wont_be :nil?
    annotations.last.face.wont_be :nil?
  end

  it "runs full annotation with empty options" do
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 100),
            Google::Apis::VisionV1::Feature.new(type: "LANDMARK_DETECTION", max_results: 100),
            Google::Apis::VisionV1::Feature.new(type: "LOGO_DETECTION", max_results: 100),
            Google::Apis::VisionV1::Feature.new(type: "LABEL_DETECTION", max_results: 100),
            Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1),
            Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1),
            Google::Apis::VisionV1::Feature.new(type: "IMAGE_PROPERTIES", max_results: 1)
          ]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, full_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath
    mock.verify

    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
    annotation.landmark.wont_be :nil?
    annotation.logo.wont_be :nil?
    annotation.labels.wont_be :nil?

    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
    annotation.text.text.must_include "Google Cloud Client for Ruby"
    annotation.text.locale.must_equal "en"
    annotation.text.words.count.must_equal 28
    annotation.text.words[0].text.must_equal "Google"
    annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.words[27].text.must_equal "Storage."
    annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?

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

  describe "ImageContext" do
    it "does not send when annotating file path" do
      req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
        requests: [
          Google::Apis::VisionV1::AnnotateImageRequest.new(
            image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
            features: [
              Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 10),
              Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1)
            ]
          )
        ]
      )
      mock = Minitest::Mock.new
      mock.expect :annotate_image, context_response_gapi, [req]

      vision.service.mocked_service = mock
      annotation = vision.annotate filepath, faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "does not send when annotating an image without context" do
      req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
        requests: [
          Google::Apis::VisionV1::AnnotateImageRequest.new(
            image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
            features: [
              Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 10),
              Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1)
            ]
          )
        ]
      )
      mock = Minitest::Mock.new
      mock.expect :annotate_image, context_response_gapi, [req]

      vision.service.mocked_service = mock
      image = vision.image filepath
      annotation = vision.annotate image, faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with location in context" do
      req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
        requests: [
          Google::Apis::VisionV1::AnnotateImageRequest.new(
            image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
            features: [
              Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 10),
              Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1)
            ]
          )
        ]
      )
      mock = Minitest::Mock.new
      mock.expect :annotate_image, context_response_gapi, [req]

      vision.service.mocked_service = mock
      image = vision.image filepath
      image.context.area.min.longitude = -122.0862462
      image.context.area.min.latitude = 37.4220041
      image.context.area.max.longitude = -122.0762462
      image.context.area.max.latitude = 37.4320041
      annotation = vision.annotate image, faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with location hash in context" do
      req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
        requests: [
          Google::Apis::VisionV1::AnnotateImageRequest.new(
            image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
            features: [
              Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 10),
              Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1)
            ]
          )
        ]
      )
      mock = Minitest::Mock.new
      mock.expect :annotate_image, context_response_gapi, [req]

      vision.service.mocked_service = mock
      image = vision.image filepath
      image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
      image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
      annotation = vision.annotate image, faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with language hints in context" do
      req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
        requests: [
          Google::Apis::VisionV1::AnnotateImageRequest.new(
            image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
            features: [
              Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 10),
              Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1)
            ]
          )
        ]
      )
      mock = Minitest::Mock.new
      mock.expect :annotate_image, context_response_gapi, [req]

      vision.service.mocked_service = mock
      image = vision.image filepath
      image.context.languages = ["en", "es"]
      annotation = vision.annotate image, faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with location and language hints in context" do
      req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
        requests: [
          Google::Apis::VisionV1::AnnotateImageRequest.new(
            image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
            features: [
              Google::Apis::VisionV1::Feature.new(type: "FACE_DETECTION", max_results: 10),
              Google::Apis::VisionV1::Feature.new(type: "TEXT_DETECTION", max_results: 1)
            ]
          )
        ]
      )
      mock = Minitest::Mock.new
      mock.expect :annotate_image, context_response_gapi, [req]

      vision.service.mocked_service = mock
      image = vision.image filepath
      image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
      image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
      image.context.languages = ["en", "es"]
      annotation = vision.annotate image, faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end
  end

  def faces_response_gapi
    MockVision::API::BatchAnnotateImagesResponse.new(
      responses: [
        MockVision::API::AnnotateImageResponse.new(
          face_annotations: [
            face_annotation_response
          ]
        ),
        MockVision::API::AnnotateImageResponse.new(
          face_annotations: [
            face_annotation_response
          ]
        )
      ]
    )
  end

  def full_response_gapi
    MockVision::API::BatchAnnotateImagesResponse.new(
      responses: [
        MockVision::API::AnnotateImageResponse.new(
          face_annotations: [face_annotation_response],
          landmark_annotations: [landmark_annotation_response],
          logo_annotations: [logo_annotation_response],
          label_annotations: [label_annotation_response],
          text_annotations: text_annotation_responses,
          safe_search_annotation: safe_search_annotation_response,
          image_properties_annotation: properties_annotation_response
        )
      ]
    )
  end

  def context_response_gapi
    MockVision::API::BatchAnnotateImagesResponse.new(
      responses: [
        MockVision::API::AnnotateImageResponse.new(
          face_annotations: [face_annotation_response],
          text_annotations: text_annotation_responses
        )
      ]
    )
  end
end
