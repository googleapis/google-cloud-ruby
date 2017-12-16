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

require "google/cloud/storage"
require "google/cloud/vision"

##
# Monkey-Patch CallOptions to support Mocks
class Google::Gax::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout === other.timeout &&
      retry_options === other.retry_options &&
      page_token === other.page_token &&
      kwargs === other.kwargs
  end
  def == other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout == other.timeout &&
      retry_options == other.retry_options &&
      page_token == other.page_token &&
      kwargs == other.kwargs
  end
end

class File
  def self.file? f
    true
  end
  def self.readable? f
    true
  end
  def self.read *args
    "fake file data"
  end
  def self.open *args
    # Examples use file paths such as "path/to/face.jpg"
    return StringIO.new("fake image data") if args[0] =~ /path\/to\//
    new *args
  end
end

class MicrophoneInput
  def self.read size
    "1,2,3"
  end
end

module Google
  module Cloud
    module Vision
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
    module Storage
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
    end
  end
end

def mock_vision
  Google::Cloud::Vision.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    vision = Google::Cloud::Vision::Project.new(Google::Cloud::Vision::Service.new("my-project", credentials))

    vision.service.mocked_service = Minitest::Mock.new
    if block_given?
      yield vision.service.mocked_service
    end
    vision
  end
end

def mock_storage
  Google::Cloud::Storage.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    storage = Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new("my-project", credentials))

    storage.service.mocked_service = Minitest::Mock.new
    yield storage.service.mocked_service
    storage
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Vision::V1"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Vision::Project#mark"
  doctest.skip "Google::Cloud::Vision::Project#detect"
  doctest.skip "Google::Cloud::Vision::Image#mark"
  doctest.skip "Google::Cloud::Vision::Image#detect"
  doctest.skip "Google::Cloud::Vision::Annotation::Face::Angles#pan"
  doctest.skip "Google::Cloud::Vision::Annotation::Face::Angles#tilt"

  doctest.before "Google::Cloud#vision" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, landmarks_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud.vision" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, landmarks_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, faces_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision.new" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, landmarks_resp, annotate_args
    end
  end

  doctest.skip "Google::Cloud::Vision::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::Vision.default_max" do
    # Reset all defaults to 100, since some examples change them to 5
    Google::Cloud::Vision.default_max_faces = 100
    Google::Cloud::Vision.default_max_labels = 100
    Google::Cloud::Vision.default_max_landmarks = 100
    Google::Cloud::Vision.default_max_logos = 100
    Google::Cloud::Vision.default_max_crop_hints = 100
    Google::Cloud::Vision.default_max_web = 100
    mock_vision do |mock|
      mock.expect :batch_annotate_images, labels_resp, annotate_args
    end
  end

  # Project

  doctest.before "Google::Cloud::Vision::Project" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, faces_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Project#annotate" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, faces_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Project#annotate@With multiple images:" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, labels_resp(2, 4, 6), annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Project#annotate@With multiple images and configurations passed in a block:" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, multi_resp, annotate_args
    end
  end

  # Image

  doctest.before "Google::Cloud::Vision::Image" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, text_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#faces" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, faces_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#landmarks" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, landmarks_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#logos" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, logos_resp(1, 5), annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#labels" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, labels_resp(1, 4), annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#text" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, text_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#safe_search" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, safe_search_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#properties" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, properties_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#crop_hints" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, crop_hints_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#web" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, web_detection_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Image#annotate" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, labels_landmarks_resp, annotate_args
    end
  end

  # Annotate

  doctest.before "Google::Cloud::Vision::Annotate" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, multi_resp, annotate_args
    end
  end

  # Annotation

  doctest.before "Google::Cloud::Vision::Annotation" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, faces_labels_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#landmark" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, landmarks_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#logo" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, logos_resp(1, 1), annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#label" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, labels_resp(1, 1), annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#text" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, text_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#safe_search" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, safe_search_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#properties" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, properties_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#crop_hint" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, crop_hints_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation#web" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, web_detection_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Face" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, faces_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Entity@In landmark detection:" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, landmarks_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Entity@In logo detection:" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, logos_resp(1, 5), annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Entity@In label detection:" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, labels_resp(1, 4), annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Text" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, text_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::SafeSearch" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, safe_search_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Vertex" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, text_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Properties" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, properties_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::CropHint" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, crop_hints_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Annotation::Web" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, web_detection_resp, annotate_args
    end
  end

  doctest.before "Google::Cloud::Vision::Location" do
    mock_vision do |mock|
      mock.expect :batch_annotate_images, landmarks_resp, annotate_args
    end
  end
end

# Fixture helpers



def default_headers
  { "google-cloud-resource-prefix" => "projects/my-project" }
end

def default_options
  Google::Gax::CallOptions.new kwargs: default_headers
end

def annotate_args
  [Array,Hash]
end

def faces_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        face_annotations: [
          face_annotation_response
        ]
      )
    ]
  )
end

def landmarks_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        landmark_annotations: [
          landmark_annotation_response
        ]
      )
    ]
  )
end

def logos_resp images_count = 1, *logos_counts
  responses = images_count.times.map do
    Google::Cloud::Vision::V1::AnnotateImageResponse.new(
      logo_annotations: logo_annotation_response(logos_counts.shift || 1)
    )
  end
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(responses: responses)
end

def labels_resp images_count = 1, *labels_counts
  responses = images_count.times.map do
    Google::Cloud::Vision::V1::AnnotateImageResponse.new(
      label_annotations: label_annotation_response(labels_counts.shift || 1)
    )
  end
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(responses: responses)
end

def labels_landmarks_resp images_count = 1, *labels_counts
  responses = images_count.times.map do
    Google::Cloud::Vision::V1::AnnotateImageResponse.new(
      label_annotations: label_annotation_response(labels_counts.shift || 1),
      landmark_annotations: [
        landmark_annotation_response
      ]
    )
  end
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(responses: responses)
end

def text_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        text_annotations: text_annotation_responses,
        full_text_annotation: full_text_annotation_response
      )
    ]
  )
end

def safe_search_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        safe_search_annotation: safe_search_annotation_response
      )
    ]
  )
end

def properties_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        image_properties_annotation: properties_annotation_response
      )
    ]
  )
end

def crop_hints_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        crop_hints_annotation: crop_hints_annotation_response
      )
    ]
  )
end

def web_detection_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        web_detection: web_detection_response
      )
    ]
  )
end

def faces_labels_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        face_annotations: [
          face_annotation_response
        ],
        label_annotations: label_annotation_response(4)
      )
    ]
  )
end

def multi_resp
  Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
    responses: [
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        face_annotations: [
          face_annotation_response
        ],
        label_annotations: label_annotation_response(4)
      ),
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        landmark_annotations: [
          landmark_annotation_response
        ]
      ),
      Google::Cloud::Vision::V1::AnnotateImageResponse.new(
        text_annotations: text_annotation_responses,
        full_text_annotation: full_text_annotation_response
      )
    ]
  )
end

def recognition_config
  Google::Cloud::Speech::V1::RecognitionConfig.new encoding: :LINEAR16, sample_rate: 16000
end

def bounding_poly
  Google::Cloud::Vision::V1::BoundingPoly.new(
    vertices: [
      Google::Cloud::Vision::V1::Vertex.new(x: 1, y: 0),
      Google::Cloud::Vision::V1::Vertex.new(x: 295, y: 0),
      Google::Cloud::Vision::V1::Vertex.new(x: 295, y: 301),
      Google::Cloud::Vision::V1::Vertex.new(x: 1, y: 301)
    ]
  )
end

def face_annotation_response
  Google::Cloud::Vision::V1::FaceAnnotation.new(
    bounding_poly: bounding_poly,
    fd_bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(
      vertices: [
        Google::Cloud::Vision::V1::Vertex.new(x: 28, y: 40),
        Google::Cloud::Vision::V1::Vertex.new(x: 250, y: 40),
        Google::Cloud::Vision::V1::Vertex.new(x: 250, y: 262),
        Google::Cloud::Vision::V1::Vertex.new(x: 28, y: 262)
      ]
    ),
    landmarks: [
      Google::Cloud::Vision::V1::FaceAnnotation::Landmark.new(type: :LEFT_EYE, position: Google::Cloud::Vision::V1::Position.new(x: 83.707092, y: 128.34, z: -0.00013388535)),
      Google::Cloud::Vision::V1::FaceAnnotation::Landmark.new(type: :FOREHEAD_GLABELLA, position: Google::Cloud::Vision::V1::Position.new(x: 126.53813, y: 93.812057, z: -18.863352))
    ],
    roll_angle: -5.1492119,
    pan_angle: -4.0695682,
    tilt_angle: -13.083284,
    detection_confidence: 0.86162376,
    landmarking_confidence: 34.489909,
    joy_likelihood:           :VERY_UNLIKELY,
    sorrow_likelihood:        :VERY_UNLIKELY,
    anger_likelihood:         :VERY_UNLIKELY,
    surprise_likelihood:      :VERY_UNLIKELY,
    under_exposed_likelihood: :VERY_UNLIKELY,
    blurred_likelihood:       :VERY_UNLIKELY,
    headwear_likelihood:      :VERY_UNLIKELY,
  )
end

def landmark_annotation_response
  Google::Cloud::Vision::V1::EntityAnnotation.new(
    mid: "/m/019dvv",
    description: "Mount Rushmore",
    score: 0.91912264,
    bounding_poly: bounding_poly,
    locations: [
      Google::Cloud::Vision::V1::LocationInfo.new(
        lat_lng: Google::Type::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)
      )
   ]
  )
end

def logo_annotation_response count = 1
  count.times.map do
    Google::Cloud::Vision::V1::EntityAnnotation.new(
      mid: "/m/0b34hf",
      description: "Google",
      score: 0.70057315,
      bounding_poly: bounding_poly
    )
  end
end

def label_annotation_response count = 1
  count.times.map do
    Google::Cloud::Vision::V1::EntityAnnotation.new(
      mid: "/m/02wtjj",
      description: "stone carving",
      score: 0.9481349
    )
  end
end

def text_annotation_response
  Google::Cloud::Vision::V1::EntityAnnotation.new(
    locale: "en",
    description: "Google Cloud Client for Ruby an idiomatic, intuitive, and\nnatural way for Ruby developers to integrate with Google Cloud\nPlatform services, like Cloud Datastore and Cloud Storage.\n",
    bounding_poly: bounding_poly
  )
end

def text_annotation_responses
  [ text_annotation_response,
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Google", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 53, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 53, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Cloud", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 59, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 89, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 89, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 59, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Client", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 96, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 128, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 128, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 96, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Library", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 132, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 170, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 170, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 132, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "for", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 175, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 191, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 191, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 175, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Ruby", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 195, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 221, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 221, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 195, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "an", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 236, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 245, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 245, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 236, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "idiomatic,", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 250, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 307, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 307, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 250, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "intuitive,", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 311, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 360, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 360, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 311, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "and", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 363, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 385, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 385, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 363, y: 23)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "natural", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 52, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 52, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "way", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 56, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 77, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 77, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 56, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "for", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 82, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 98, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 98, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 82, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Ruby", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 102, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 130, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 130, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 102, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "developers", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 135, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 196, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 196, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 135, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "to", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 201, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 212, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 212, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 201, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "integrate", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 215, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 265, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 265, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 215, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "with", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 270, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 293, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 293, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 270, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Google", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 299, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 339, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 339, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 299, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Cloud", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 345, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 376, y: 33), Google::Cloud::Vision::V1::Vertex.new(x: 376, y: 49), Google::Cloud::Vision::V1::Vertex.new(x: 345, y: 49)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Platform", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 59, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 59, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 74)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "services,", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 67, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 117, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 117, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 67, y: 74)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "like", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 121, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 138, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 138, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 121, y: 74)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Cloud", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 145, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 177, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 177, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 145, y: 74)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Datastore", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 181, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 236, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 236, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 181, y: 74)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "and", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 242, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 260, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 260, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 242, y: 74)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Cloud", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 267, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 298, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 298, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 267, y: 74)])),
    Google::Cloud::Vision::V1::EntityAnnotation.new(description: "Storage.", bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 304, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 351, y: 59), Google::Cloud::Vision::V1::Vertex.new(x: 351, y: 74), Google::Cloud::Vision::V1::Vertex.new(x: 304, y: 74)]))
  ]
end

def full_text_annotation_response
  Google::Cloud::Vision::V1::TextAnnotation.new(
    text: "Google Cloud Client for Ruby an idiomatic, intuitive, and\nnatural way for Ruby developers to integrate with Google Cloud\nPlatform services, like Cloud Datastore and Cloud Storage.\n",
    pages: [
      Google::Cloud::Vision::V1::Page.new(
        property: Google::Cloud::Vision::V1::TextAnnotation::TextProperty.new(detected_languages: [Google::Cloud::Vision::V1::TextAnnotation::DetectedLanguage.new(language_code: "en", confidence: 0.0)], detected_break: nil), width: 400, height: 80,
        blocks: [
          Google::Cloud::Vision::V1::Block.new(
            property: Google::Cloud::Vision::V1::TextAnnotation::TextProperty.new(
              detected_languages: [Google::Cloud::Vision::V1::TextAnnotation::DetectedLanguage.new(language_code: "en", confidence: 0.0)], detected_break: nil),
            bounding_box: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 385, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 385, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 23)]),
            paragraphs: [
              Google::Cloud::Vision::V1::Paragraph.new(
                property: Google::Cloud::Vision::V1::TextAnnotation::TextProperty.new(
                  detected_languages: [Google::Cloud::Vision::V1::TextAnnotation::DetectedLanguage.new(language_code: "en", confidence: 0.0)], detected_break: nil),
                bounding_box: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 385, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 385, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 23)]),
                words: 10.times.map do
                  Google::Cloud::Vision::V1::Word.new(
                    property: Google::Cloud::Vision::V1::TextAnnotation::TextProperty.new(detected_languages: [Google::Cloud::Vision::V1::TextAnnotation::DetectedLanguage.new(language_code: "en", confidence: 0.0)], detected_break: nil),
                    bounding_box: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 53, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 53, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 23)]),
                    symbols: 6.times.map do
                      Google::Cloud::Vision::V1::Symbol.new(
                        property: Google::Cloud::Vision::V1::TextAnnotation::TextProperty.new(detected_languages: [Google::Cloud::Vision::V1::TextAnnotation::DetectedLanguage.new(language_code: "en", confidence: 0.0)], detected_break: nil),
                        bounding_box: Google::Cloud::Vision::V1::BoundingPoly.new(vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 21, y: 8), Google::Cloud::Vision::V1::Vertex.new(x: 21, y: 23), Google::Cloud::Vision::V1::Vertex.new(x: 13, y: 23)]),
                        text: "G"
                      )
                    end
                  )
                end
              )
            ]
          )
        ]
      )
    ]
  )
end

def safe_search_annotation_response
  Google::Cloud::Vision::V1::SafeSearchAnnotation.new(
    adult:    :VERY_UNLIKELY,
    spoof:    :VERY_UNLIKELY,
    medical:  :POSSIBLE,
    violence: :LIKELY
  )
end

def properties_annotation_response
  Google::Cloud::Vision::V1::ImageProperties.new(
    dominant_colors: Google::Cloud::Vision::V1::DominantColorsAnnotation.new(
      colors: [
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 247, green: 236, blue: 20),
                           score: 0.20301804,
                           pixel_fraction: 0.0072649573),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 0, green: 0, blue: 0),
                           score: 0.09256918,
                           pixel_fraction: 0.19258064),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 255, green: 255, blue: 255),
                           score: 0.1002003,
                           pixel_fraction: 0.022258064),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 3, green: 4, blue: 254),
                           score: 0.089072376,
                           pixel_fraction: 0.054516129),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 168, green: 215, blue: 255),
                           score: 0.019252902,
                           pixel_fraction: 0.0070967744),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 127, green: 177, blue: 255),
                           score: 0.017626688,
                           pixel_fraction: 0.0045161289),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 178, green: 223, blue: 255),
                           score: 0.015010362,
                           pixel_fraction: 0.0022580645),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 172, green: 224, blue: 255),
                           score: 0.0049617039,
                           pixel_fraction: 0.0012903226),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 160, green: 218, blue: 255),
                           score: 0.0027604031,
                           pixel_fraction: 0.0022580645),
        Google::Cloud::Vision::V1::ColorInfo.new(color: Google::Type::Color.new(red: 156, green: 214, blue: 255),
                           score: 0.00096750073,
                           pixel_fraction: 0.00064516132)
      ]
    )
  )
end

def crop_hints_bounding_poly
  Google::Cloud::Vision::V1::BoundingPoly.new(
    vertices: [
      Google::Cloud::Vision::V1::Vertex.new(x: 1, y: 0),
      Google::Cloud::Vision::V1::Vertex.new(x: 511, y: 0),
      Google::Cloud::Vision::V1::Vertex.new(x: 511, y: 383),
      Google::Cloud::Vision::V1::Vertex.new(x: 0, y: 383)
    ]
  )
end

def crop_hints_annotation_response
  Google::Cloud::Vision::V1::CropHintsAnnotation.new(
    crop_hints: [
      Google::Cloud::Vision::V1::CropHint.new(
        bounding_poly: crop_hints_bounding_poly,
        confidence: 1.0,
        importance_fraction: 1.0399999618530273
      )
    ]
  )
end

def web_detection_response
  Google::Cloud::Vision::V1::WebDetection.new(
    web_entities: [
      Google::Cloud::Vision::V1::WebDetection::WebEntity.new(
        entity_id: "/m/019dvv", score: 107.34591674804688, description: "Mount Rushmore National Memorial"
      )
    ],
    full_matching_images: [
      Google::Cloud::Vision::V1::WebDetection::WebImage.new(
        url: "http://example.com/images/123.jpg", score: 0.10226666927337646
      )
    ],
    partial_matching_images: [
      Google::Cloud::Vision::V1::WebDetection::WebImage.new(
        url: "http://img.example.com/img/tcs/t/pict/src/33/26/92/src_33269273.jpg", score: 0.13653333485126495
      )
    ],
    pages_with_matching_images: [
      Google::Cloud::Vision::V1::WebDetection::WebPage.new(
        url: "http://example.com/posts/123", score: 8.114753723144531
      )
    ]
  )
end
