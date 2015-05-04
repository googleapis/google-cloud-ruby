#--
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
require "gcloud/pubsub/project"

##
# Google Cloud Pub/Sub
module Gcloud
  ##
  # Create a new Pubsub project.
  #
  #   pubsub = Gcloud.pubsub "my-todo-project",
  #                          "/path/to/keyfile.json"
  #   topic = pubsub.topic "my-topic"
  #   topic.publish "task completed"
  #
  # @param project [String] the project identifier for the Pubsub
  # account you are connecting to.
  # @param keyfile [String] the path to the keyfile you downloaded from
  # Google Cloud. The file must readable.
  # @return [Gcloud::Pubsub::Project] the project instance.
  def self.pubsub project = nil, keyfile = nil
    project ||= Gcloud::Pubsub::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Pubsub::Credentials.default
    else
      credentials = Gcloud::Pubsub::Credentials.new keyfile
    end
    Gcloud::Pubsub::Project.new project, credentials
  end

  ##
  # Google Cloud Pubsub
  #
  #   pubsub = Gcloud::Pubsub.project "my-todo-project",
  #                                   "/path/to/keyfile.json"
  #   topic = pubsub.topic "my-topic"
  #   msg = topic.publish "task completed"
  #
  # See Gcloud::Pubsub::Project
  module Pubsub
  end
end
