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
require "pathname"

describe Google::Cloud::Vision::Image, :web, :mock_vision do
  let(:filepath) { "acceptance/data/landmark.jpg" }
  let(:image)    { vision.image filepath }

  it "detects multiple web matches" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :WEB_DETECTION, max_results: 10)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, web_detection_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    web = image.web 10
    mock.verify

    web.entities.count.must_equal 1
    web.full_matching_images.count.must_equal 1
    web.partial_matching_images.count.must_equal 1
    web.pages_with_matching_images.count.must_equal 1
  end

  it "detects multiple web matches without specifying a count" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :WEB_DETECTION, max_results: 100)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, web_detection_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    web = image.web
    mock.verify

    web.entities.count.must_equal 1
    web.full_matching_images.count.must_equal 1
    web.partial_matching_images.count.must_equal 1
    web.pages_with_matching_images.count.must_equal 1
  end
end
