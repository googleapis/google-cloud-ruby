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
  #   # ...
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
  # ...
  module Vision
  end
end
