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
require "gcloud/translate/api"

module Gcloud
  ##
  # Creates a new `Api` instance connected to the Translate service.
  # Each call creates a new connection.
  #
  # TODO: Add info for creatign an API Key here...
  #
  # @param [String] key API Key
  #
  # @return [Gcloud::Translate::Api]
  #
  # @example
  #   require "gcloud"
  #
  #   translate = Gcloud.translate "api-key-abc123XYZ789"
  #
  #   zone = translate.zone "example-com"
  #
  # @example Using API Key from the environment variable.
  #   require "gcloud"
  #
  #   ENV["TRANSLATE_KEY"] = "api-key-abc123XYZ789"
  #
  #   translate = Gcloud.translate
  #
  #   zone = translate.zone "example-com"
  #
  def self.translate key = nil
    Gcloud::Translate::Api.new key
  end

  ##
  # # Google Cloud Translate
  #
  # TODO
  #
  module Translate
  end
end
