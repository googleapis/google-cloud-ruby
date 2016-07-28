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


require "google/cloud/core/version"

##
# # Google Cloud
#
# The google-cloud library is the official library for interacting with Google
# Cloud Platform. Google Cloud Platform is a set of modular cloud-based services
# that allow you to create anything from simple websites to complex
# applications.
#
# The goal of google-cloud is to provide a API that is familiar and comfortable
# to Rubyists. Authentication is handled by providing project and credential
# information, or if you are running on Google Compute Engine this configuration
# is taken care of for you.
#
# You can learn more about various options for connection on the [Authentication
# Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
#
module Google
  module Cloud
    ##
    # Creates a new object for connecting to Google Cloud.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project Project identifier for the Pub/Sub service you are
    #   connecting to.
    # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
    #   file path the file must be readable.
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   datastore = gcloud.datastore
    #   pubsub  = gcloud.pubsub
    #   storage = gcloud.storage
    #
    def self.new project = nil, keyfile = nil, retries: nil, timeout: nil
      gcloud = Object.new
      gcloud.instance_variable_set "@project", project
      gcloud.instance_variable_set "@keyfile", keyfile
      gcloud.instance_variable_set "@retries", retries
      gcloud.instance_variable_set "@timeout", timeout
      gcloud.extend Google::Cloud
      gcloud
    end

    ##
    # Creates a new object for connecting to the Pub/Sub service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/pubsub`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Pubsub::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   pubsub = gcloud.pubsub
    #   topic = pubsub.topic "my-topic"
    #   topic.publish "task completed"
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   pubsub = gcloud.pubsub scope: platform_scope
    #
    def pubsub scope: nil, retries: nil, timeout: nil
      require "google/cloud/pubsub"
      Google::Cloud.pubsub @project, @keyfile, scope: scope,
                                               retries: (retries || @retries),
                                               timeout: (timeout || @timeout)
    end

    # rubocop:disable Metrics/LineLength
    # Disabled because the readonly scope in the example code is long and we
    # can't shorten it.

    ##
    # Creates a new object for connecting to the Resource Manager service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
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
    # @return [Google::Cloud::ResourceManager::Manager]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   resource_manager = gcloud.resource_manager
    #   resource_manager.projects.each do |project|
    #     puts projects.project_id
    #   end
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   readonly_scope = "https://www.googleapis.com/auth/cloudresourcemanager.readonly"
    #   resource_manager = gcloud.resource_manager scope: readonly_scope
    #
    def resource_manager scope: nil, retries: nil, timeout: nil
      require "google/cloud/resource_manager"
      Google::Cloud.resource_manager @keyfile, scope: scope,
                                               retries: (retries || @retries),
                                               timeout: (timeout || @timeout)
    end

    # rubocop:enable Metrics/LineLength

    ##
    # Creates a new object for connecting to the Translate service.
    # Each call creates a new connection.
    #
    # Unlike other Cloud Platform services, which authenticate using a project
    # ID and OAuth 2.0 credentials, Google Translate API requires a public API
    # access key. (This may change in future releases of Google Translate API.)
    # Follow the general instructions at [Identifying your application to
    # Google](https://cloud.google.com/translate/v2/using_rest#auth), and the
    # specific instructions for [Server
    # keys](https://cloud.google.com/translate/v2/using_rest#creating-server-api-keys).
    #
    # @param [String] key a public API access key (not an OAuth 2.0 token)
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Translate::Api]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   translate = gcloud.translate "api-key-abc123XYZ789"
    #
    #   translation = translate.translate "Hello world!", to: "la"
    #   translation.text #=> "Salve mundi!"
    #
    # @example Using API Key from the environment variable.
    #   require "google/cloud"
    #
    #   ENV["TRANSLATE_KEY"] = "api-key-abc123XYZ789"
    #
    #   gcloud = Google::Cloud.new
    #   translate = gcloud.translate
    #
    #   translation = translate.translate "Hello world!", to: "la"
    #   translation.text #=> "Salve mundi!"
    #
    def translate key = nil, retries: nil, timeout: nil
      require "google/cloud/translate"
      Google::Cloud.translate key, retries: (retries || @retries),
                                   timeout: (timeout || @timeout)
    end

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
      require "google/cloud/vision"
      Google::Cloud.vision @project, @keyfile, scope: scope,
                                               retries: (retries || @retries),
                                               timeout: (timeout || @timeout)
    end
  end
end
