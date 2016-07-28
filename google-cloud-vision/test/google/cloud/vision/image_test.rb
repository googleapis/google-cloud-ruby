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

describe Google::Cloud::Vision::Image, :mock_vision do
  let(:filepath) { "../acceptance/data/face.jpg" }

  it "can create from an existing file path" do
    image = vision.image filepath

    image.must_be_kind_of Google::Cloud::Vision::Image
    image.must_be :io?
    image.wont_be :url?
  end

  it "can create from a Pathname object" do
    image = vision.image Pathname.new(filepath)

    image.must_be_kind_of Google::Cloud::Vision::Image
    image.must_be :io?
    image.wont_be :url?
  end

  it "can create from a File object" do
    image = vision.image File.open(filepath, "rb")

    image.must_be_kind_of Google::Cloud::Vision::Image
    image.must_be :io?
    image.wont_be :url?
  end

  it "can create from a StringIO object" do
    image = vision.image StringIO.new(File.read(filepath, mode: "rb"))

    image.must_be_kind_of Google::Cloud::Vision::Image
    image.must_be :io?
    image.wont_be :url?
  end

  it "can create from a Tempfile object" do
    image = nil
    Tempfile.open ["image", "png"] do |tmpfile|
      tmpfile.binmode
      tmpfile.write File.read(filepath, mode: "rb")

      image = vision.image tmpfile
    end

    image.must_be_kind_of Google::Cloud::Vision::Image
    image.must_be :io?
    image.wont_be :url?
  end

  it "can create from a Google Storage URL" do
    image = vision.image "gs://test/file.ext"

    image.must_be_kind_of Google::Cloud::Vision::Image
    image.wont_be :io?
    image.must_be :url?
  end

  it "can create from a Storage::File object" do
    gs_img = OpenStruct.new to_gs_url: "gs://test/file.ext"
    image = vision.image gs_img

    image.must_be_kind_of Google::Cloud::Vision::Image
    image.wont_be :io?
    image.must_be :url?
  end

  it "raises when giving an object that is not IO or a Google Storage URL" do
    obj = OpenStruct.new hello: "world"

    expect { vision.image obj }.must_raise ArgumentError
  end
end
