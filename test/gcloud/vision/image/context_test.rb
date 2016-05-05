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

describe Gcloud::Vision::Image::Context, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }
  let(:area_gapi) { {minLatLng: { latitude: 37.4220041, longitude: -122.0862462},
                     maxLatLng: { latitude: 37.4320041, longitude: -122.0762462}} }

  it "is empty by default" do
    image.context.must_be :empty?

    image.context.to_gapi.must_be :nil?
  end

  it "is can populate the location" do
    image.context.area.min.longitude = -122.0862462
    image.context.area.min.latitude = 37.4220041
    image.context.area.max.longitude = -122.0762462
    image.context.area.max.latitude = 37.4320041
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({latLongRect: area_gapi})
  end

  it "is can set the location object" do
    image.context.area.min = Gcloud::Vision::Location.new 37.4220041, -122.0862462
    image.context.area.max = Gcloud::Vision::Location.new 37.4320041, -122.0762462
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({latLongRect: area_gapi})
  end

  it "is can set a location with a hash" do
    image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
    image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({latLongRect: area_gapi})
  end

  it "is can populate language hints" do
    image.context.languages << "en"
    image.context.languages << "es"
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({languageHints: ["en", "es"]})
  end

  it "is can set a language hints" do
    image.context.languages = ["en", "es"]
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({languageHints: ["en", "es"]})
  end

  it "is can set all the things" do
    image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
    image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
    image.context.languages = ["en", "es"]
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({latLongRect: area_gapi, languageHints: ["en", "es"]})
  end
end
