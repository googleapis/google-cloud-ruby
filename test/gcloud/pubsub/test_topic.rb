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

require "helper"

describe Gcloud::Pubsub::Topic, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }

  it "knows its name" do
    topic.name.must_equal topic_path(topic_name)
  end

  it "can delete itself" do
    mock_connection.delete "/pubsub/v1beta1#{topic_path topic_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    topic.delete
  end
end
