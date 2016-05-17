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


require "gcloud"
require "gcloud/vision/project"

module Gcloud
  ##
  # Creates a new object for connecting to the Vision service.
  # Each call creates a new connection.
  #
  # @param [String] project Project identifier for the Vision service you are
  #   connecting to.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/cloud-platform`
  #
  # @return [Gcloud::Vision::Project]
  #
  # @example
  #   require "gcloud/vision"
  #
  #   gcloud = Gcloud.new
  #   vision = gcloud.vision
  #
  #   image = vision.image "./acceptance/data/landmark.jpg"
  #
  #   landmark = image.landmark
  #   landmark.description #=> "Mount Rushmore"
  #
  def self.vision project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Vision::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Vision::Credentials.default scope: scope
    else
      credentials = Gcloud::Vision::Credentials.new keyfile, scope: scope
    end
    Gcloud::Vision::Project.new project, credentials
  end

  ##
  # # Google Cloud Vision
  #
  # Google Cloud Vision allows easy integration of vision detection features
  # developer applications, including image labeling, face and landmark
  # detection, optical character recognition (OCR), and tagging of explicit
  # content.
  #
  # For more information about Cloud Vision, read the [Google Cloud Vision API
  # Documentation](https://cloud.google.com/vision/docs/).
  #
  # Gcloud's goal is to provide an API that is familiar and comfortable to
  # Rubyists. Authentication is handled by {Gcloud#vision}. You can provide the
  # project and credential information to connect to the Cloud Vision service,
  # or if you are running on Google Compute Engine this configuration is taken
  # care of for you. You can read more about the options for connecting in the
  # [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # ## Creating images
  #
  # The Cloud Vision API supports a variety of image file formats, including
  # JPEG, PNG8, PNG24, Animated GIF (first frame only), and RAW. See [Best
  # Practices - Image Types](https://cloud.google.com/vision/docs/image-best-practices#image_types)
  # for the list of formats. Be aware that Cloud Vision sets upper limits on
  # file size as well as on the total combined size of all images in a request.
  # Reducing your file size can significantly improve throughput; however, be
  # careful not to reduce image quality in the process. See [Best Practices -
  # Image Sizing](https://cloud.google.com/vision/docs/image-best-practices#image_sizing)
  # for current file size limits.
  #
  # Use {Vision::Project#image} to create images for the Cloud Vision service:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # vision = gcloud.vision
  #
  # image = vision.image "./acceptance/data/landmark.jpg"
  # ```
  #
  # Once you have an image, you can set metadata on its context:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # vision = gcloud.vision
  #
  # image = vision.image "./acceptance/data/landmark.jpg"
  #
  # image.context.area.min = { longitude: -122.0862462,
  #                            latitude: 37.4220041 }
  # image.context.area.max = { longitude: -122.0762462,
  #                            latitude: 37.4320041 }
  #
  # ```
  #
  # ## Annotating images
  #
  # You can use the instance methods on {Vision::Image} to invoke Cloud Vision's
  # detection features individually. Each method call makes an API request. (If
  # you want to run multiple features in a single request, see the examples for
  # {Vision::Project#annotate}, below.)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # vision = gcloud.vision
  #
  # image = vision.image "./acceptance/data/face.jpg"
  #
  # face = image.face
  #
  # face.features.to_h.count #=> 9
  # face.features.eyes.left.pupil
  # #=> #<Landmark (x: 190.41544, y: 84.4557, z: -1.3682901)>
  # face.features.chin.center
  # #=> #<Landmark (x: 233.21977, y: 189.47475, z: 19.487228)>
  # ```
  #
  # You can also use the {Vision::Project#annotate} method to perform image
  # detection. This method allows you to configure multiple detection features
  # in a single request.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # vision = gcloud.vision
  #
  # image = vision.image "./acceptance/data/face.jpg"
  #
  # analysis = vision.annotate image, faces: 10, labels: 10
  # analysis.faces.count #=> 1
  # analysis.labels.count #=> 4
  # ```
  #
  # You can also perform detection tasks on multiple images in a single request:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # vision = gcloud.vision
  #
  # face_image = vision.image "./acceptance/data/face.jpg"
  # landmark_image = vision.image "./acceptance/data/landmark.jpg"
  #
  # analyses = vision.annotate face_image, landmark_image, labels: 10
  #
  # analyses[0].labels.count #=> 4
  # analyses[1].labels.count #=> 6
  # ```
  #
  # It is even possible to configure different features for multiple images in
  # a single call using a block. The following example results in a single
  # request to the Cloud Vision API:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # vision = gcloud.vision
  #
  # face_image = vision.image "./acceptance/data/face.jpg"
  # landmark_image = vision.image "./acceptance/data/landmark.jpg"
  # text_image = vision.image "./acceptance/data/text.png"
  #
  # analyses = vision.annotate do |annotate|
  #    annotate.annotate face_image, faces: 10, labels: 10
  #    annotate.annotate landmark_image, landmarks: 10
  #    annotate.annotate text_image, text: true
  # end
  #
  # analyses[0].faces.count #=> 1
  # analyses[0].labels.count #=> 4
  # analyses[1].landmarks.count #=> 1
  # analyses[2].text.words.count #=> 28
  # ```
  #
  module Vision
  end
end
