# Copyright 2014 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::PubSub::Project, :mock_pubsub do
  it "knows the project identifier" do
    _(pubsub.project).must_equal project
  end

  it "creates topic with async options when skip_lookup enabled" do
    topic = pubsub.topic("test", skip_lookup: true, async: { interval: 1 })
    topic.publish_async("{}")
    _(topic.async_publisher.instance_variable_get("@interval")).must_equal 1
  end
end
