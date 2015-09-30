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
require "gcloud/resource_manager/manager"

#--
# Google Cloud Resource Manager
module Gcloud
  ##
  # Creates a new +Project+ instance connected to the Resource Manager service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
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
  #   * +https://www.googleapis.com/auth/cloudresourcemanager+
  #
  # === Returns
  #
  # Gcloud::ResourceManager::Manager
  #
  # === Example
  #
  #   require "gcloud/resource_manager"
  #
  #   resource_manager = Gcloud.resource_manager
  #   resource_manager.projects.each do |project|
  #     puts projects.project_id
  #   end
  #
  def self.resource_manager keyfile = nil, options = {}
    if keyfile.nil?
      credentials = Gcloud::ResourceManager::Credentials.default options
    else
      credentials = Gcloud::ResourceManager::Credentials.new keyfile, options
    end
    Gcloud::ResourceManager::Manager.new credentials
  end

  ##
  # = Google Cloud Resource Manager
  #
  module ResourceManager
  end
end
