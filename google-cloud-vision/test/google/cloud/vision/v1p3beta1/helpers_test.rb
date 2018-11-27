# Copyright 2018 Google LLC
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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/vision"
require "google/cloud/vision/v1p3beta1/helpers"

require "google/cloud/vision/v1p3beta1/image_annotator_client"

class MockImageAnnotatorCredentials_v1p3beta1 < Google::Cloud::Vision::V1p3beta1::Credentials
  def initialize method_name
    @method_name = method_name
  end

  def updater_proc
    proc do
      raise "The method `#{@method_name}` was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Vision::V1p3beta1::ImageAnnotatorClient do
  let(:helper_methods) do
    helper_hash = {}
    Google::Cloud::Vision::v1p3beta1::Feature::Type.constants.each do |feature_type|
      next if feature_type == :TYPE_UNSPECIFIED
      method_name = feature_type.to_s.downcase
      method_name += "_detection" unless method_name.include? "detection"
      helper_hash[method_name] = feature_type
    end
    helper_hash
  end
  let(:image_uri) { "http://example.com/face.jpg" }
  let(:gcs_image_uri) { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
  let(:mock_credentials) { MockImageAnnotatorCredentials_v1p3beta1.new("batch_annotate_images") }

  def image_object image
    return { content: image.binmode.read } if image.respond_to? :binmode
    return { content: File.binread(image) } if File.file? image
    return { source: { image_uri: image_uri } } if image == image_uri
    { source: { gcs_image_uri: gcs_image_uri } }
  end

  def batch_annotate_stub image, feature_type
    feature = { type: feature_type, max_results: 10 }
    expected_requests =
      if image.is_a? Array
        (0...image.size).map do |n|
          {
            image: image_object(image[n]),
            features: [feature]
          }
        end
      else
        [{
          image: image_object(image),
          features: [feature]
        }]
      end
    proc do |requests|
      assert_equal(expected_requests, requests)
    end
  end

  def async_annotate_stub image, feature_type, destination
    feature = { type: feature_type, max_results: 10 }
    input_config = image_object(image)
    input_config[:mime_type] = "application/pdf"
    expected_requests = [
      {
        input_config: input_config,
        features: [feature],
        output_config: {
          gcs_destination: destination,
          batch_size: 10
        }
      }
    ]
    proc do |requests|
      assert_equal(expected_requests, requests)
    end
  end

  describe "face_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :FACE_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.face_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :FACE_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.face_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "landmark_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :LANDMARK_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.landmark_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :LANDMARK_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.landmark_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "logo_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :LOGO_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.logo_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :LOGO_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.logo_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "label_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :LABEL_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.label_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :LABEL_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.label_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "text_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.text_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :TEXT_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.text_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "document_text_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :DOCUMENT_TEXT_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.document_text_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :DOCUMENT_TEXT_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.document_text_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "safe_search_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :SAFE_SEARCH_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.safe_search_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :SAFE_SEARCH_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.safe_search_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "image_properties_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :IMAGE_PROPERTIES
        client.stub(:batch_annotate_images, stub) do
          client.image_properties_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :IMAGE_PROPERTIES, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.image_properties_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "crop_hints_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :CROP_HINTS
        client.stub(:batch_annotate_images, stub) do
          client.crop_hints_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :CROP_HINTS, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.crop_hints_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "product_search_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :PRODUCT_SEARCH
        client.stub(:batch_annotate_images, stub) do
          client.product_search_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :PRODUCT_SEARCH, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.product_search_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "object_localization_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :OBJECT_LOCALIZATION
        client.stub(:batch_annotate_images, stub) do
          client.object_localization_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :OBJECT_LOCALIZATION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.object_localization_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end

  describe "web_detection" do
    it "correctly calls batch_annotate_images when given a single image file" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub File.new("acceptance/data/face.jpg", "r"), :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection image: File.new("acceptance/data/face.jpg", "r")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image files" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { File.new("acceptance/data/face.jpg", "r") }, :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection images: (0..1).map { File.new("acceptance/data/face.jpg", "r") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single io object" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb"), :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection image: IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb")
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of io objects" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }, :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection images: (0..1).map { IO.new((IO.sysopen("acceptance/data/face.jpg", "r")), "rb") }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image path" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "acceptance/data/face.jpg", :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection image: "acceptance/data/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image paths" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "acceptance/data/face.jpg" }, :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection images: (0..1).map { "acceptance/data/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "http://example.com/face.jpg", :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection image: "http://example.com/face.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "http://example.com/face.jpg" }, :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection images: (0..1).map { "http://example.com/face.jpg" }
        end
      end
    end

    it "correctly calls batch_annotate_images when given a single gcs image uri" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub "gs://gapic-toolkit/President_Barack_Obama.jpg", :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection image: "gs://gapic-toolkit/President_Barack_Obama.jpg"
        end
      end
    end

    it "correctly calls batch_annotate_images when given a list of gcs image uri's" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = batch_annotate_stub (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }, :WEB_DETECTION
        client.stub(:batch_annotate_images, stub) do
          client.web_detection images: (0..1).map { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
        end
      end
    end

    it "correctly calls async_batch_annotate_files when async is true" do
      Google::Cloud::Vision::V1p3beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Vision::ImageAnnotator.new version: :v1p3beta1
        stub = async_annotate_stub gcs_image_uri, :WEB_DETECTION, "gs://my-bucket"
        client.stub(:async_batch_annotate_files, stub) do
         client.web_detection(
            image: gcs_image_uri,
            destination: "gs://my-bucket",
            async: true,
            mime_type: "application/pdf"
          )
        end
      end
    end
  end
end
