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
require "pathname"

describe Google::Cloud::Vision::Image, :safe_search, :mock_vision do
  let(:filepath) { "../acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }

  it "detects safe_search" do
    feature = Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1)
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, safe_search_response_gapi, [req]

    vision.service.mocked_service = mock
    safe_search = image.safe_search
    mock.verify

    safe_search.wont_be :nil?
    safe_search.wont_be :adult?
    safe_search.wont_be :spoof?
    safe_search.must_be :medical?
    safe_search.must_be :violence?
  end

  def safe_search_response_gapi
    MockVision::API::BatchAnnotateImagesResponse.new(
      responses: [
        MockVision::API::AnnotateImageResponse.new(
          safe_search_annotation: safe_search_annotation_response
        )
      ]
    )
  end
end
