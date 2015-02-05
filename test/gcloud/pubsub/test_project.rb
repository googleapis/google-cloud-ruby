# Copyright 2014 Google Inc. All rights reserved.
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

require "helper"

describe Gcloud::Pubsub::Project, :mock_pubsub do
  it "knows the project identifier" do
    pubsub.project.must_equal project
  end

  it "creates a topic" do
    new_topic_name = "new-topic-#{Time.now.to_i}"
    mock_connection.post "/pubsub/v1beta1/topics" do |env|
      JSON.parse(env.body)["name"].must_equal topic_path(new_topic_name)
      [200, {"Content-Type"=>"application/json"},
       topic_json(new_topic_name)]
    end

    pubsub.create_topic new_topic_name
  end
end
