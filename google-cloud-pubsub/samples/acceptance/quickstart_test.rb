# Copyright 2021 Google LLC
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

require_relative "helper"
require_relative "../quickstart.rb"

describe "quickstart" do
  let(:pubsub) { Google::Cloud::Pubsub.new }
  let(:topic_id) { random_topic_id }
  let(:topic_admin) { pubsub.topic_admin }

  it "supports quickstart_create_topic" do
    assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
      quickstart topic_id: topic_id
    end

    topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)
    assert topic
    # cleanup
    topic_admin.delete_topic topic: topic.name
  end
end
