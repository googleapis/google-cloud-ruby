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

  it "is empty by default" do
    image.context.must_be :empty?

    image.context.to_gapi.must_be :nil?
  end

  it "is can populate the location" do
    image.context.location.latitude = 37.4220041
    image.context.location.longitude = -122.0862462
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({"latLongRect"=>{:latitude=>37.4220041, :longitude=>-122.0862462}})
  end

  it "is can set the location object" do
    image.context.location = Gcloud::Vision::Location.new 37.4220041, -122.0862462
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({"latLongRect"=>{:latitude=>37.4220041, :longitude=>-122.0862462}})
  end

  it "is can set a location with a hash" do
    image.context.location = { longitude: -122.0862462, latitude: 37.4220041 }
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({"latLongRect"=>{:latitude=>37.4220041, :longitude=>-122.0862462}})
  end

  it "is can populate language hints" do
    image.context.languages << "en"
    image.context.languages << "es"
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({"languageHints"=>["en", "es"]})
  end

  it "is can set a language hints" do
    image.context.languages = ["en", "es"]
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({"languageHints"=>["en", "es"]})
  end

  it "is can set all the things" do
    image.context.location = { longitude: -122.0862462, latitude: 37.4220041 }
    image.context.languages = ["en", "es"]
    image.context.wont_be :empty?

    image.context.to_gapi.wont_be :nil?
    image.context.to_gapi.must_equal({"latLongRect"=>{:latitude=>37.4220041, :longitude=>-122.0862462}, "languageHints"=>["en", "es"]})
  end
end
