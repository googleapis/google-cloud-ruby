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
require "gcloud/bigquery/project"

##
# Google Cloud Bigquery
module Gcloud
  ##
  # Create a new Bigquery project.
  #
  #   bigquery = Gcloud.bigquery "my-todo-project",
  #                              "/path/to/keyfile.json"
  #   dataset = bigquery.dataset "my-todo-dataset"
  #
  # @param project [String] the project identifier for the Bigquery
  # account you are connecting to.
  # @param keyfile [String] the path to the keyfile you downloaded from
  # Google Cloud. The file must readable.
  # @return [Gcloud::Bigquery::Project] bigquery project.
  #
  # See Gcloud::Bigquery::Project
  def self.bigquery project = nil, keyfile = nil
    project ||= Gcloud::Bigquery::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Bigquery::Credentials.default
    else
      credentials = Gcloud::Bigquery::Credentials.new keyfile
    end
    Gcloud::Bigquery::Project.new project, credentials
  end
end
