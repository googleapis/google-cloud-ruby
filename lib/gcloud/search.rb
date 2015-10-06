# Copyright 2015 Google Inc. All rights reserved.
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
require "gcloud/search/project"

#--
# Google Cloud Search
module Gcloud
  ##
  # Creates a new +Project+ instance connected to the Search service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +project+::
  #   Identifier for a Search project. If not present, the default project for
  #   the credentials is used. (+String+)
  # +keyfile+::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (+String+ or +Hash+)
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scope is:
  #
  #   * +https://www.googleapis.com/auth/cloudsearch+
  #
  # === Returns
  #
  # Gcloud::Search::Project
  def self.search project = nil, keyfile = nil, options = {}
    project ||= Gcloud::Search::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Search::Credentials.default options
    else
      credentials = Gcloud::Search::Credentials.new keyfile, options
    end
    Gcloud::Search::Project.new project, credentials
  end

  ##
  # = Google Cloud Search
  #
  module Search
  end
end
