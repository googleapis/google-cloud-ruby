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
require "gcloud/logging/project"

module Gcloud
  ##
  # Creates a new object for connecting to the Logging service.
  # Each call creates a new connection.
  #
  # @param [String] project Project identifier for the Logging service you are
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
  #   * `https://www.googleapis.com/auth/logging.admin`
  #
  # @return [Gcloud::Logging::Project]
  #
  # @example
  #   require "gcloud/logging"
  #
  #   gcloud = Gcloud.new
  #   logging = gcloud.logging
  #   # ...
  #
  def self.logging project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Logging::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Logging::Credentials.default scope: scope
    else
      credentials = Gcloud::Logging::Credentials.new keyfile, scope: scope
    end
    Gcloud::Logging::Project.new project, credentials
  end

  ##
  # # Google Cloud Logging
  #
  # Google Cloud Logging collects and stores logs from applications and services
  # on the Google Cloud Platform.
  #
  # ...
  module Logging
  end
end
