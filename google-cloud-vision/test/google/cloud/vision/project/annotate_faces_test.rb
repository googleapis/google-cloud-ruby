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

describe Google::Cloud::Vision::Project, :annotate, :faces, :mock_vision do
  let(:filepath) { "../acceptance/data/face.jpg" }

  it "detects face detection using mark alias" do
    feature = MockVision::API::Feature.new(type: "FACE_DETECTION", max_results: 1)
    req = MockVision::API::BatchAnnotateImagesRequest.new(
      requests: [
        MockVision::API::AnnotateImageRequest.new(
          image: MockVision::API::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, face_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, faces: 1
    mock.verify

    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
  end

  it "detects face detection using detect alias" do
    feature = MockVision::API::Feature.new(type: "FACE_DETECTION", max_results: 1)
    req = MockVision::API::BatchAnnotateImagesRequest.new(
      requests: [
        MockVision::API::AnnotateImageRequest.new(
          image: MockVision::API::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, face_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.detect filepath, faces: 1
    mock.verify

    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
  end

  it "detects face detection on multiple images" do
    feature = MockVision::API::Feature.new(type: "FACE_DETECTION", max_results: 1)
    req = MockVision::API::BatchAnnotateImagesRequest.new(
      requests: [
        MockVision::API::AnnotateImageRequest.new(
          image: MockVision::API::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        ),
        MockVision::API::AnnotateImageRequest.new(
          image: MockVision::API::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, faces_response_gapi, [req]

    vision.service.mocked_service = mock
    annotations = vision.annotate filepath, filepath, faces: 1
    mock.verify

    annotations.count.must_equal 2
    annotations.first.face.wont_be :nil?
    annotations.last.face.wont_be :nil?
  end

  it "uses the default configuration" do
    feature = MockVision::API::Feature.new(type: "FACE_DETECTION", max_results: Google::Cloud::Vision.default_max_faces)
    req = MockVision::API::BatchAnnotateImagesRequest.new(
      requests: [
        MockVision::API::AnnotateImageRequest.new(
          image: MockVision::API::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, face_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, faces: true
    mock.verify

    annotation.face.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    feature = MockVision::API::Feature.new(type: "FACE_DETECTION", max_results: Google::Cloud::Vision.default_max_faces)
    req = MockVision::API::BatchAnnotateImagesRequest.new(
      requests: [
        MockVision::API::AnnotateImageRequest.new(
          image: MockVision::API::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, face_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, faces: "9999"
    mock.verify

    annotation.face.wont_be :nil?
  end

  it "uses the updated configuration" do
    feature = MockVision::API::Feature.new(type: "FACE_DETECTION", max_results: 25)
    req = MockVision::API::BatchAnnotateImagesRequest.new(
      requests: [
        MockVision::API::AnnotateImageRequest.new(
          image: MockVision::API::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, face_response_gapi, [req]
    vision.service.mocked_service = mock

    Google::Cloud::Vision.stub :default_max_faces, 25 do
      annotation = vision.annotate filepath, faces: true
      annotation.face.wont_be :nil?
    end
    mock.verify
  end

  def face_response_gapi
    MockVision::API::BatchAnnotateImagesResponse.new(
      responses: [
        MockVision::API::AnnotateImageResponse.new(
          face_annotations: [
            face_annotation_response
          ]
        )
      ]
    )
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
end
