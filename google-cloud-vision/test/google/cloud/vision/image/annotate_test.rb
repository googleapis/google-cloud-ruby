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

describe Google::Cloud::Vision::Image, :annotate, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }
  let(:area_json) { {"min_lat_lng"=>{"latitude"=>37.4220041, "longitude"=>-122.0862462},
                     "max_lat_lng"=>{"latitude"=>37.4320041, "longitude"=>-122.0762462}} }

  it "allows multiple annotation options" do
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [
          Google::Cloud::Vision::V1::Feature.new(type: :FACE_DETECTION, max_results: 10),
          Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
        ]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, context_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = image.annotate faces: 10, text: true
    mock.verify

    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
    annotation.text.wont_be :nil?
  end

  it "runs full annotation with empty options" do
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [
          Google::Cloud::Vision::V1::Feature.new(type: :FACE_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :LANDMARK_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :LOGO_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :DOCUMENT_TEXT_DETECTION, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :SAFE_SEARCH_DETECTION, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :IMAGE_PROPERTIES, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :WEB_DETECTION, max_results: 100)
        ]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, full_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = image.annotate
    mock.verify

    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
    annotation.landmark.wont_be :nil?
    annotation.logo.wont_be :nil?
    annotation.label.wont_be :nil?

    annotation.must_be :face?
    annotation.must_be :landmark?
    annotation.must_be :logo?
    annotation.must_be :label?

    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
    annotation.must_be :text?
    annotation.text.text.must_include "Google Cloud Client for Ruby"
    annotation.text.locale.must_equal "en"
    # the `text_annotations` model
    annotation.text.words.count.must_equal 28
    annotation.text.words[0].text.must_equal "Google"
    annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.words[27].text.must_equal "Storage."
    annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
    # the `full_text_annotation` model
    annotation.text.pages.count.must_equal 1
    annotation.text.pages[0].must_be_kind_of Google::Cloud::Vision::Annotation::Text::Page
    annotation.text.pages[0].languages.count.must_equal 1
    annotation.text.pages[0].languages[0].code.must_equal "en"
    annotation.text.pages[0].languages[0].confidence.must_equal 0.0
    annotation.text.pages[0].break_type.must_be :nil?
    annotation.text.pages[0].wont_be :prefix_break?
    annotation.text.pages[0].width.must_equal 400
    annotation.text.pages[0].height.must_equal 80
    annotation.text.pages[0].blocks[0].bounds.map(&:to_a).must_equal [[13, 8], [385, 8], [385, 23], [13, 23]]
    annotation.text.pages[0].blocks[0].paragraphs[0].bounds.map(&:to_a).must_equal [[13, 8], [385, 8], [385, 23], [13, 23]]
    annotation.text.pages[0].blocks[0].paragraphs[0].words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].bounds.map(&:to_a).must_equal [[13, 8], [21, 8], [21, 23], [13, 23]]
    annotation.text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].text.must_equal "G"

    annotation.safe_search.wont_be :nil?
    annotation.must_be :safe_search?
    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?

    annotation.properties.wont_be :nil?
    annotation.must_be :properties?
    annotation.properties.colors.count.must_equal 10

    annotation.properties.colors[0].red.must_equal 145
    annotation.properties.colors[0].green.must_equal 193
    annotation.properties.colors[0].blue.must_equal 254
    annotation.properties.colors[0].alpha.must_equal 1.0
    annotation.properties.colors[0].rgb.must_equal "91c1fe"
    annotation.properties.colors[0].score.must_be_close_to 0.65757853
    annotation.properties.colors[0].pixel_fraction.must_be_close_to 0.16903226

    annotation.properties.colors[9].red.must_equal 156
    annotation.properties.colors[9].green.must_equal 214
    annotation.properties.colors[9].blue.must_equal 255
    annotation.properties.colors[9].alpha.must_be_close_to 1.0
    annotation.properties.colors[9].rgb.must_equal "9cd6ff"
    annotation.properties.colors[9].score.must_be_close_to 0.00096750073
    annotation.properties.colors[9].pixel_fraction.must_be_close_to 0.00064516132

    annotation.crop_hints[0].bounds.count.must_equal 4
    annotation.crop_hints[0].bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
    annotation.crop_hints[0].bounds.map(&:to_a).must_equal [[1, 0], [295, 0], [295, 301], [1, 301]]
    annotation.crop_hints[0].confidence.must_equal 1.0
    annotation.crop_hints[0].importance_fraction.must_equal 1.0399999618530273

    annotation.web.entities.count.must_equal 1
    annotation.web.entities[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Entity
    annotation.web.entities[0].entity_id.must_equal "/m/019dvv"
    annotation.web.entities[0].score.must_equal 107.34591674804688
    annotation.web.entities[0].description.must_equal "Mount Rushmore National Memorial"

    annotation.web.full_matching_images.count.must_equal 1
    annotation.web.full_matching_images[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Image
    annotation.web.full_matching_images[0].url.must_equal "http://www.example.com/pds/trip_image/350"
    annotation.web.full_matching_images[0].score.must_equal 0.10226666927337646

    annotation.web.partial_matching_images.count.must_equal 1
    annotation.web.partial_matching_images[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Image
    annotation.web.partial_matching_images[0].url.must_equal "http://img.example.com/img/tcs/t/pict/src/33/26/92/src_33269273.jpg"
    annotation.web.partial_matching_images[0].score.must_equal 0.13653333485126495

    annotation.web.pages_with_matching_images.count.must_equal 1
    annotation.web.pages_with_matching_images[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Page
    annotation.web.pages_with_matching_images[0].url.must_equal "https://www.youtube.com/watch?v=wCLdngIgofg"
    annotation.web.pages_with_matching_images[0].score.must_equal 8.114753723144531
  end

  describe "ImageContext" do
    it "sends when annotating an image with location in context" do
      req = [
        Google::Cloud::Vision::V1::AnnotateImageRequest.new(
          image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Cloud::Vision::V1::Feature.new(type: :FACE_DETECTION, max_results: 10),
            Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
          ],
          image_context: Google::Cloud::Vision::V1::ImageContext.new(
            lat_long_rect: Google::Cloud::Vision::V1::LatLongRect.new(
              min_lat_lng: Google::Type::LatLng.new(latitude: 37.4220041, longitude: -122.0862462),
              max_lat_lng: Google::Type::LatLng.new(latitude: 37.4320041, longitude: -122.0762462)
            )
          )
        )
      ]
      mock = Minitest::Mock.new
      mock.expect :batch_annotate_images, context_response_grpc, [req, options: default_options]

      vision.service.mocked_service = mock
      image.context.area.min.longitude = -122.0862462
      image.context.area.min.latitude = 37.4220041
      image.context.area.max.longitude = -122.0762462
      image.context.area.max.latitude = 37.4320041
      annotation = image.annotate faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with location hash in context" do
      req = [
        Google::Cloud::Vision::V1::AnnotateImageRequest.new(
          image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Cloud::Vision::V1::Feature.new(type: :FACE_DETECTION, max_results: 10),
            Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
          ],
          image_context: Google::Cloud::Vision::V1::ImageContext.new(
            lat_long_rect: Google::Cloud::Vision::V1::LatLongRect.new(
              min_lat_lng: Google::Type::LatLng.new(latitude: 37.4220041, longitude: -122.0862462),
              max_lat_lng: Google::Type::LatLng.new(latitude: 37.4320041, longitude: -122.0762462)
            )
          )
        )
      ]
      mock = Minitest::Mock.new
      mock.expect :batch_annotate_images, context_response_grpc, [req, options: default_options]

      vision.service.mocked_service = mock
      image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
      image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
      annotation = image.annotate faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with language hints in context" do
      req = [
        Google::Cloud::Vision::V1::AnnotateImageRequest.new(
          image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Cloud::Vision::V1::Feature.new(type: :FACE_DETECTION, max_results: 10),
            Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
          ],
          image_context: Google::Cloud::Vision::V1::ImageContext.new(
            language_hints: ["en", "es"]
          )
        )
      ]
      mock = Minitest::Mock.new
      mock.expect :batch_annotate_images, context_response_grpc, [req, options: default_options]

      vision.service.mocked_service = mock
      image.context.languages = ["en", "es"]
      annotation = image.annotate faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with crop hints aspect ratios in context" do
      req = [
        Google::Cloud::Vision::V1::AnnotateImageRequest.new(
          image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 100)
          ],
          image_context: Google::Cloud::Vision::V1::ImageContext.new(
            crop_hints_params: Google::Cloud::Vision::V1::CropHintsParams.new(
              aspect_ratios: [1.0]
            )
          )
        )
      ]
      mock = Minitest::Mock.new
      mock.expect :batch_annotate_images, crop_hints_annotation_response_grpc, [req, options: default_options]

      vision.service.mocked_service = mock
      image.context.aspect_ratios = [1.0]
      annotation = image.annotate crop_hints: true
      mock.verify

      annotation.wont_be :nil?
      annotation.crop_hints.wont_be :nil?
    end

    it "sends when annotating an image with location and language hints in context" do
      req = [
        Google::Cloud::Vision::V1::AnnotateImageRequest.new(
          image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [
            Google::Cloud::Vision::V1::Feature.new(type: :FACE_DETECTION, max_results: 10),
            Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
          ],
          image_context: Google::Cloud::Vision::V1::ImageContext.new(
            lat_long_rect: Google::Cloud::Vision::V1::LatLongRect.new(
              min_lat_lng: Google::Type::LatLng.new(latitude: 37.4220041, longitude: -122.0862462),
              max_lat_lng: Google::Type::LatLng.new(latitude: 37.4320041, longitude: -122.0762462)
            ),
            language_hints: ["en", "es"]
          )
        )
      ]
      mock = Minitest::Mock.new
      mock.expect :batch_annotate_images, context_response_grpc, [req, options: default_options]

      vision.service.mocked_service = mock
      image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
      image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
      image.context.languages = ["en", "es"]
      annotation = image.annotate faces: 10, text: true
      mock.verify

      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end
  end

  def faces_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          face_annotations: [
            face_annotation_response
          ]
        ),
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          face_annotations: [
            face_annotation_response
          ]
        )
      ]
    )
  end

  def context_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          face_annotations: [face_annotation_response],
          text_annotations: text_annotation_responses,
          full_text_annotation: full_text_annotation_response
        )
      ]
    )
  end
end
