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

require "helper"

describe Google::Cloud::Vision::Image::Context, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }
  let(:language_hints) { ["en", "es"] }

  it "is empty by default" do
    image.context.must_be :empty?

    image.context.to_grpc.must_be :nil?
  end

  it "is can populate the location" do
    image.context.area.min.longitude = -122.0862462
    image.context.area.min.latitude = 37.4220041
    image.context.area.max.longitude = -122.0762462
    image.context.area.max.latitude = 37.4320041
    image.context.wont_be :empty?

    image.context.to_grpc.wont_be :nil?
    image.context.to_grpc.must_be_kind_of Google::Cloud::Vision::V1::ImageContext
    lat_long_rect_must_equal image.context.to_grpc.lat_long_rect
  end

  it "is can set the location object" do
    image.context.area.min = Google::Cloud::Vision::Location.new 37.4220041, -122.0862462
    image.context.area.max = Google::Cloud::Vision::Location.new 37.4320041, -122.0762462
    image.context.wont_be :empty?

    image.context.to_grpc.wont_be :nil?
    image.context.to_grpc.must_be_kind_of Google::Cloud::Vision::V1::ImageContext
    lat_long_rect_must_equal image.context.to_grpc.lat_long_rect
  end

  it "is can set a location with a hash" do
    image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
    image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
    image.context.wont_be :empty?

    image.context.to_grpc.wont_be :nil?
    image.context.to_grpc.must_be_kind_of Google::Cloud::Vision::V1::ImageContext
    lat_long_rect_must_equal image.context.to_grpc.lat_long_rect
  end

  it "is can populate language hints" do
    image.context.languages << "en"
    image.context.languages << "es"
    image.context.wont_be :empty?

    image.context.to_grpc.wont_be :nil?
    image.context.to_grpc.must_be_kind_of Google::Cloud::Vision::V1::ImageContext
    image.context.to_grpc.language_hints.must_equal language_hints
  end

  it "is can set a language hints" do
    image.context.languages = ["en", "es"]
    image.context.wont_be :empty?

    image.context.to_grpc.wont_be :nil?
    image.context.to_grpc.must_be_kind_of Google::Cloud::Vision::V1::ImageContext
    image.context.to_grpc.language_hints.must_equal language_hints
  end

  it "is can set all the things" do
    image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
    image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
    image.context.languages = ["en", "es"]
    image.context.wont_be :empty?

    image.context.to_grpc.wont_be :nil?
    image.context.to_grpc.must_be_kind_of Google::Cloud::Vision::V1::ImageContext
    lat_long_rect_must_equal image.context.to_grpc.lat_long_rect
    image.context.to_grpc.language_hints.must_equal language_hints
  end

  def lat_long_rect_must_equal lat_long_rect_grpc
    lat_long_rect_grpc.must_be_kind_of Google::Cloud::Vision::V1::LatLongRect
    lat_long_rect_grpc.min_lat_lng.must_be_kind_of Google::Type::LatLng
    lat_long_rect_grpc.min_lat_lng.latitude.must_be_close_to 37.4220041
    lat_long_rect_grpc.min_lat_lng.longitude.must_be_close_to -122.0862462
    lat_long_rect_grpc.max_lat_lng.must_be_kind_of Google::Type::LatLng
    lat_long_rect_grpc.max_lat_lng.latitude.must_be_close_to 37.4320041
    lat_long_rect_grpc.max_lat_lng.longitude.must_be_close_to -122.0762462
  end
end
