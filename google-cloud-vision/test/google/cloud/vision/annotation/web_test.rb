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

describe Google::Cloud::Vision::Annotation::Web, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:grpc_web) { web_detection_response }
  let(:web) { Google::Cloud::Vision::Annotation::Web.from_grpc grpc_web }

  it "knows the given attributes" do
    web.must_be_kind_of Google::Cloud::Vision::Annotation::Web

    web.entities.count.must_equal 1
    web.entities[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Entity
    web.entities[0].entity_id.must_equal "/m/019dvv"
    web.entities[0].score.must_equal 107.34591674804688
    web.entities[0].description.must_equal "Mount Rushmore National Memorial"

    web.full_matching_images.count.must_equal 1
    web.full_matching_images[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Image
    web.full_matching_images[0].url.must_equal "http://www.example.com/pds/trip_image/350"
    web.full_matching_images[0].score.must_equal 0.10226666927337646

    web.partial_matching_images.count.must_equal 1
    web.partial_matching_images[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Image
    web.partial_matching_images[0].url.must_equal "http://img.example.com/img/tcs/t/pict/src/33/26/92/src_33269273.jpg"
    web.partial_matching_images[0].score.must_equal 0.13653333485126495

    web.pages_with_matching_images.count.must_equal 1
    web.pages_with_matching_images[0].must_be_kind_of Google::Cloud::Vision::Annotation::Web::Page
    web.pages_with_matching_images[0].url.must_equal "https://www.youtube.com/watch?v=wCLdngIgofg"
    web.pages_with_matching_images[0].score.must_equal 8.114753723144531
  end

  it "can convert to a hash" do
    hash = web.to_h
    hash.must_be_kind_of Hash

    hash[:entities].count.must_equal 1
    hash[:entities][0].must_be_kind_of Hash
    hash[:entities][0][:entity_id].must_equal "/m/019dvv"
    hash[:entities][0][:score].must_equal 107.34591674804688
    hash[:entities][0][:description].must_equal "Mount Rushmore National Memorial"

    hash[:full_matching_images].count.must_equal 1
    hash[:full_matching_images][0].must_be_kind_of Hash
    hash[:full_matching_images][0][:url].must_equal "http://www.example.com/pds/trip_image/350"
    hash[:full_matching_images][0][:score].must_equal 0.10226666927337646

    hash[:partial_matching_images].count.must_equal 1
    hash[:partial_matching_images][0].must_be_kind_of Hash
    hash[:partial_matching_images][0][:url].must_equal "http://img.example.com/img/tcs/t/pict/src/33/26/92/src_33269273.jpg"
    hash[:partial_matching_images][0][:score].must_equal 0.13653333485126495

    hash[:pages_with_matching_images].count.must_equal 1
    hash[:pages_with_matching_images][0].must_be_kind_of Hash
    hash[:pages_with_matching_images][0][:url].must_equal "https://www.youtube.com/watch?v=wCLdngIgofg"
    hash[:pages_with_matching_images][0][:score].must_equal 8.114753723144531
  end

  it "can convert to a string" do
    web.to_s.must_equal "(entities: 1, full_matching_images: 1, partial_matching_images: 1, pages_with_matching_images: 1)"
    web.inspect.must_include web.to_s
  end
end
