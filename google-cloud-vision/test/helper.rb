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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/vision"

##
# Monkey-Patch Google API Client to support Mocks
module Google::Apis::Core::Hashable
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, the Google API Client objects do not match with ===.
  # Therefore, we must add this capability.
  # This module seems like as good a place as any...
  def === other
    return(to_h === other.to_h) if other.respond_to? :to_h
    super
  end
end

class MockVision < Minitest::Spec
  API = Google::Apis::VisionV1
  let(:project) { vision.service.project }
  let(:credentials) { vision.service.credentials }
  let(:vision) { Google::Cloud::Vision::Project.new(Google::Cloud::Vision::Service.new("test", OpenStruct.new)) }

  # Register this spec type for when :mock_vision is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_vision
  end

  def bounding_poly
    API::BoundingPoly.new(
      vertices: [
        API::Vertex.new(x: 1, y: 0),
        API::Vertex.new(x: 295, y: 0),
        API::Vertex.new(x: 295, y: 301),
        API::Vertex.new(x: 1, y: 301)
      ]
    )
  end

  def face_annotation_response
    API::FaceAnnotation.new(
      bounding_poly: bounding_poly,
      fd_bounding_poly: API::BoundingPoly.new(
        vertices: [
          API::Vertex.new(x: 28, y: 40),
          API::Vertex.new(x: 250, y: 40),
          API::Vertex.new(x: 250, y: 262),
          API::Vertex.new(x: 28, y: 262)
        ]
      ),
      landmarks: [
        API::Landmark.new(type: "LEFT_EYE", position: API::Position.new(x: 83.707092, y: 128.34, z: -0.00013388535)),
        API::Landmark.new(type: "RIGHT_EYE", position: API::Position.new(x: 181.17694, y: 115.16437, z: -12.82961)),
        API::Landmark.new(type: "LEFT_OF_LEFT_EYEBROW", position: API::Position.new(x: 58.790176, y: 113.28249, z: 17.89735)),
        API::Landmark.new(type: "RIGHT_OF_LEFT_EYEBROW", position: API::Position.new(x: 106.14151, y: 98.593758, z: -13.116687)),
        API::Landmark.new(type: 'LEFT_OF_RIGHT_EYEBROW', position: API::Position.new(x: 148.61565, y: 92.294594, z: -18.804882)),
        API::Landmark.new(type: "RIGHT_OF_RIGHT_EYEBROW", position: API::Position.new(x: 204.40808, y: 94.300117, z: -2.0009689)),
        API::Landmark.new(type: "MIDPOINT_BETWEEN_EYES", position: API::Position.new(x: 127.83745, y: 110.17557, z: -22.650913)),
        API::Landmark.new(type: "NOSE_TIP", position: API::Position.new(x: 128.14919, y: 153.68129, z: -63.198204)),
        API::Landmark.new(type: "UPPER_LIP", position: API::Position.new(x: 134.74164, y: 192.50438, z: -53.876408)),
        API::Landmark.new(type: "LOWER_LIP", position: API::Position.new(x: 137.28528, y: 219.23564, z: -56.663128)),
        API::Landmark.new(type: "MOUTH_LEFT", position: API::Position.new(x: 104.53558, y: 214.05037, z: -30.056231)),
        API::Landmark.new(type: "MOUTH_RIGHT", position: API::Position.new(x: 173.79134, y: 204.99333, z: -39.725758)),
        API::Landmark.new(type: "MOUTH_CENTER", position: API::Position.new(x: 136.43481, y: 204.37952, z: -51.620205)),
        API::Landmark.new(type: "NOSE_BOTTOM_RIGHT", position: API::Position.new(x: 161.31354, y: 168.24527, z: -36.1628)),
        API::Landmark.new(type: "NOSE_BOTTOM_LEFT", position: API::Position.new(x: 110.98372, y: 173.61331, z: -29.7784)),
        API::Landmark.new(type: "NOSE_BOTTOM_CENTER", position: API::Position.new(x: 133.81947, y: 173.16437, z: -48.287724)),
        API::Landmark.new(type: "LEFT_EYE_TOP_BOUNDARY", position: API::Position.new(x: 86.706947, y: 119.47144, z: -4.1606765)),
        API::Landmark.new(type: "LEFT_EYE_RIGHT_CORNER", position: API::Position.new(x: 105.28892, y: 125.57655, z: -2.51554)),
        API::Landmark.new(type: "LEFT_EYE_BOTTOM_BOUNDARY", position: API::Position.new(x: 84.883934, y: 134.59479, z: -2.8677137)),
        API::Landmark.new(type: "LEFT_EYE_LEFT_CORNER", position: API::Position.new(x: 72.213913, y: 132.04138, z: 9.6985674)),
        API::Landmark.new(type: "RIGHT_EYE_TOP_BOUNDARY", position: API::Position.new(x: 173.99446, y: 107.94287, z: -16.050705)),
        API::Landmark.new(type: "RIGHT_EYE_RIGHT_CORNER", position: API::Position.new(x: 194.59413, y: 115.91954, z: -6.952745)),
        API::Landmark.new(type: "RIGHT_EYE_BOTTOM_BOUNDARY", position: API::Position.new(x: 179.30353, y: 121.03307, z: -14.843414)),
        API::Landmark.new(type: "RIGHT_EYE_LEFT_CORNER", position: API::Position.new(x: 158.2863, y: 118.491, z: -9.723031)),
        API::Landmark.new(type: "LEFT_EYEBROW_UPPER_MIDPOINT", position: API::Position.new(x: 80.248711, y: 94.04303, z: 0.21131183)),
        API::Landmark.new(type: "RIGHT_EYEBROW_UPPER_MIDPOINT", position: API::Position.new(x: 174.70135, y: 81.580917, z: -12.702137)),
        API::Landmark.new(type: "LEFT_EAR_TRAGION", position: API::Position.new(x: 54.872219, y: 207.23712, z: 97.030685)),
        API::Landmark.new(type: "RIGHT_EAR_TRAGION", position: API::Position.new(x: 252.67567, y: 180.43124, z: 70.15992)),
        API::Landmark.new(type: "LEFT_EYE_PUPIL", position: API::Position.new(x: 86.531624, y: 126.49807, z: -2.2496929)),
        API::Landmark.new(type: "RIGHT_EYE_PUPIL", position: API::Position.new(x: 175.99976, y: 114.64407, z: -14.53744)),
        API::Landmark.new(type: "FOREHEAD_GLABELLA", position: API::Position.new(x: 126.53813, y: 93.812057, z: -18.863352)),
        API::Landmark.new(type: "CHIN_GNATHION", position: API::Position.new(x: 143.34183, y: 262.22998, z: -57.388493)),
        API::Landmark.new(type: "CHIN_LEFT_GONION", position: API::Position.new(x: 63.102425, y: 248.99081, z: 44.207638)),
        API::Landmark.new(type: "CHIN_RIGHT_GONION", position: API::Position.new(x: 241.72728, y: 225.53488, z: 19.758242))
      ],
      roll_angle: -0.050002542,
      pan_angle: -0.081090336,
      tilt_angle: 0.18012161,
      detection_confidence: 0.56748849,
      landmarking_confidence: 34.489909,
      joy_likelihood:          "LIKELY",
      sorrow_likelihood:       "UNLIKELY",
      anger_likelihood:        "VERY_UNLIKELY",
      surprise_likelihood:     "UNLIKELY",
      under_exposed_likelihood: "VERY_UNLIKELY",
      blurred_likelihood:      "VERY_UNLIKELY",
      headwear_likelihood:     "VERY_UNLIKELY",
    )
  end

  def landmark_annotation_response
    API::EntityAnnotation.new(
      mid: "/m/019dvv",
      description: "Mount Rushmore",
      score: 0.91912264,
      bounding_poly: bounding_poly,
      locations: [
        API::LocationInfo.new(
          lat_lng: API::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)
        )
     ]
    )
  end

  def logo_annotation_response
    API::EntityAnnotation.new(
      mid: "/m/045c7b",
      description: "Google",
      score: 0.6435439,
      bounding_poly: bounding_poly
    )
  end

  def label_annotation_response
    API::EntityAnnotation.new(
      mid: "/m/02wtjj",
      description: "stone carving",
      score: 0.9859733
    )
  end

  def text_annotation_response
    API::EntityAnnotation.new(
      locale: "en",
      description: "Google Cloud Client for Ruby an idiomatic, intuitive, and\nnatural way for Ruby developers to integrate with Google Cloud\nPlatform services, like Cloud Datastore and Cloud Storage.\n",
      bounding_poly: bounding_poly
    )
  end

  def text_annotation_responses
    [ text_annotation_response,
      API::EntityAnnotation.new(description: "Google", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 13, y: 8), API::Vertex.new(x: 53, y: 8), API::Vertex.new(x: 53, y: 23), API::Vertex.new(x: 13, y: 23)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 59, y: 8), API::Vertex.new(x: 89, y: 8), API::Vertex.new(x: 89, y: 23), API::Vertex.new(x: 59, y: 23)])),
      API::EntityAnnotation.new(description: "Client", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 96, y: 8), API::Vertex.new(x: 128, y: 8), API::Vertex.new(x: 128, y: 23), API::Vertex.new(x: 96, y: 23)])),
      API::EntityAnnotation.new(description: "Library", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 132, y: 8), API::Vertex.new(x: 170, y: 8), API::Vertex.new(x: 170, y: 23), API::Vertex.new(x: 132, y: 23)])),
      API::EntityAnnotation.new(description: "for", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 175, y: 8), API::Vertex.new(x: 191, y: 8), API::Vertex.new(x: 191, y: 23), API::Vertex.new(x: 175, y: 23)])),
      API::EntityAnnotation.new(description: "Ruby", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 195, y: 8), API::Vertex.new(x: 221, y: 8), API::Vertex.new(x: 221, y: 23), API::Vertex.new(x: 195, y: 23)])),
      API::EntityAnnotation.new(description: "an", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 236, y: 8), API::Vertex.new(x: 245, y: 8), API::Vertex.new(x: 245, y: 23), API::Vertex.new(x: 236, y: 23)])),
      API::EntityAnnotation.new(description: "idiomatic,", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 250, y: 8), API::Vertex.new(x: 307, y: 8), API::Vertex.new(x: 307, y: 23), API::Vertex.new(x: 250, y: 23)])),
      API::EntityAnnotation.new(description: "intuitive,", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 311, y: 8), API::Vertex.new(x: 360, y: 8), API::Vertex.new(x: 360, y: 23), API::Vertex.new(x: 311, y: 23)])),
      API::EntityAnnotation.new(description: "and", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 363, y: 8), API::Vertex.new(x: 385, y: 8), API::Vertex.new(x: 385, y: 23), API::Vertex.new(x: 363, y: 23)])),
      API::EntityAnnotation.new(description: "natural", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 13, y: 33), API::Vertex.new(x: 52, y: 33), API::Vertex.new(x: 52, y: 49), API::Vertex.new(x: 13, y: 49)])),
      API::EntityAnnotation.new(description: "way", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 56, y: 33), API::Vertex.new(x: 77, y: 33), API::Vertex.new(x: 77, y: 49), API::Vertex.new(x: 56, y: 49)])),
      API::EntityAnnotation.new(description: "for", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 82, y: 33), API::Vertex.new(x: 98, y: 33), API::Vertex.new(x: 98, y: 49), API::Vertex.new(x: 82, y: 49)])),
      API::EntityAnnotation.new(description: "Ruby", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 102, y: 33), API::Vertex.new(x: 130, y: 33), API::Vertex.new(x: 130, y: 49), API::Vertex.new(x: 102, y: 49)])),
      API::EntityAnnotation.new(description: "developers", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 135, y: 33), API::Vertex.new(x: 196, y: 33), API::Vertex.new(x: 196, y: 49), API::Vertex.new(x: 135, y: 49)])),
      API::EntityAnnotation.new(description: "to", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 201, y: 33), API::Vertex.new(x: 212, y: 33), API::Vertex.new(x: 212, y: 49), API::Vertex.new(x: 201, y: 49)])),
      API::EntityAnnotation.new(description: "integrate", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 215, y: 33), API::Vertex.new(x: 265, y: 33), API::Vertex.new(x: 265, y: 49), API::Vertex.new(x: 215, y: 49)])),
      API::EntityAnnotation.new(description: "with", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 270, y: 33), API::Vertex.new(x: 293, y: 33), API::Vertex.new(x: 293, y: 49), API::Vertex.new(x: 270, y: 49)])),
      API::EntityAnnotation.new(description: "Google", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 299, y: 33), API::Vertex.new(x: 339, y: 33), API::Vertex.new(x: 339, y: 49), API::Vertex.new(x: 299, y: 49)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 345, y: 33), API::Vertex.new(x: 376, y: 33), API::Vertex.new(x: 376, y: 49), API::Vertex.new(x: 345, y: 49)])),
      API::EntityAnnotation.new(description: "Platform", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 13, y: 59), API::Vertex.new(x: 59, y: 59), API::Vertex.new(x: 59, y: 74), API::Vertex.new(x: 13, y: 74)])),
      API::EntityAnnotation.new(description: "services,", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 67, y: 59), API::Vertex.new(x: 117, y: 59), API::Vertex.new(x: 117, y: 74), API::Vertex.new(x: 67, y: 74)])),
      API::EntityAnnotation.new(description: "like", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 121, y: 59), API::Vertex.new(x: 138, y: 59), API::Vertex.new(x: 138, y: 74), API::Vertex.new(x: 121, y: 74)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 145, y: 59), API::Vertex.new(x: 177, y: 59), API::Vertex.new(x: 177, y: 74), API::Vertex.new(x: 145, y: 74)])),
      API::EntityAnnotation.new(description: "Datastore", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 181, y: 59), API::Vertex.new(x: 236, y: 59), API::Vertex.new(x: 236, y: 74), API::Vertex.new(x: 181, y: 74)])),
      API::EntityAnnotation.new(description: "and", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 242, y: 59), API::Vertex.new(x: 260, y: 59), API::Vertex.new(x: 260, y: 74), API::Vertex.new(x: 242, y: 74)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 267, y: 59), API::Vertex.new(x: 298, y: 59), API::Vertex.new(x: 298, y: 74), API::Vertex.new(x: 267, y: 74)])),
      API::EntityAnnotation.new(description: "Storage.", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 304, y: 59), API::Vertex.new(x: 351, y: 59), API::Vertex.new(x: 351, y: 74), API::Vertex.new(x: 304, y: 74)]))
    ]
  end

  def safe_search_annotation_response
    API::SafeSearchAnnotation.new(
      adult:    "VERY_UNLIKELY",
      spoof:    "UNLIKELY",
      medical:  "POSSIBLE",
      violence: "LIKELY"
    )
  end

  def properties_annotation_response
    API::ImageProperties.new(
      dominant_colors: API::DominantColorsAnnotation.new(
        colors: [
          API::ColorInfo.new(color: API::Color.new(red: 145, green: 193, blue: 254),
                             score: 0.65757853,
                             pixel_fraction: 0.16903226),
          API::ColorInfo.new(color: API::Color.new(red: 0, green: 0, blue: 0),
                             score: 0.09256918,
                             pixel_fraction: 0.19258064),
          API::ColorInfo.new(color: API::Color.new(red: 255, green: 255, blue: 255),
                             score: 0.1002003,
                             pixel_fraction: 0.022258064),
          API::ColorInfo.new(color: API::Color.new(red: 3, green: 4, blue: 254),
                             score: 0.089072376,
                             pixel_fraction: 0.054516129),
          API::ColorInfo.new(color: API::Color.new(red: 168, green: 215, blue: 255),
                             score: 0.019252902,
                             pixel_fraction: 0.0070967744),
          API::ColorInfo.new(color: API::Color.new(red: 127, green: 177, blue: 255),
                             score: 0.017626688,
                             pixel_fraction: 0.0045161289),
          API::ColorInfo.new(color: API::Color.new(red: 178, green: 223, blue: 255),
                             score: 0.015010362,
                             pixel_fraction: 0.0022580645),
          API::ColorInfo.new(color: API::Color.new(red: 172, green: 224, blue: 255),
                             score: 0.0049617039,
                             pixel_fraction: 0.0012903226),
          API::ColorInfo.new(color: API::Color.new(red: 160, green: 218, blue: 255),
                             score: 0.0027604031,
                             pixel_fraction: 0.0022580645),
          API::ColorInfo.new(color: API::Color.new(red: 156, green: 214, blue: 255),
                             score: 0.00096750073,
                             pixel_fraction: 0.00064516132)
        ]
      )
    )
  end
end
