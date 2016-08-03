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

##
# This file is here to be autorequired by bundler, so that the .bigquery and
# #bigquery methods can be available, but the library and all dependencies won't
# be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Vision service.
    # Each call creates a new connection.
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Vision::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   vision = gcloud.vision
    #
    #   image = vision.image "path/to/landmark.jpg"
    #
    #   landmark = image.landmark
    #   landmark.description #=> "Mount Rushmore"
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   vision = gcloud.vision scope: platform_scope
    #
    def vision scope: nil, retries: nil, timeout: nil
      Google::Cloud.vision @project, @keyfile, scope: scope,
                                               retries: (retries || @retries),
                                               timeout: (timeout || @timeout)
    end

    ##
    # Creates a new object for connecting to the Vision service.
    # Each call creates a new connection.
    #
    # @param [String] project Project identifier for the Vision service you are
    #   connecting to.
    # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
    #   file path the file must be readable.
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Vision::Project]
    #
    # @example
    #   require "google/cloud/vision"
    #
    #   gcloud = Google::Cloud.new
    #   vision = gcloud.vision
    #
    #   image = vision.image "path/to/landmark.jpg"
    #
    #   landmark = image.landmark
    #   landmark.description #=> "Mount Rushmore"
    #
    def self.vision project = nil, keyfile = nil, scope: nil, retries: nil,
                    timeout: nil
      require "google/cloud/vision"
      project ||= Google::Cloud::Vision::Project.default_project
      project = project.to_s # Always cast to a string
      fail ArgumentError, "project is missing" if project.empty?

      if keyfile.nil?
        credentials = Google::Cloud::Vision::Credentials.default scope: scope
      else
        credentials = Google::Cloud::Vision::Credentials.new \
          keyfile, scope: scope
      end

      Google::Cloud::Vision::Project.new(
        Google::Cloud::Vision::Service.new(
          project, credentials, retries: retries, timeout: timeout))
    end
  end
end
