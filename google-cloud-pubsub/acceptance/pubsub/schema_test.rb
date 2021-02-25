# Copyright 2015 Google LLC
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

require "pubsub_helper"

# This test is a ruby version of gcloud-node's pubsub test.

describe Google::Cloud::PubSub::Schema, :pubsub do
  def retrieve_topic topic_name
    pubsub.get_topic(topic_name) || pubsub.create_topic(topic_name)
  end

  def retrieve_subscription topic, subscription_name
    topic.get_subscription(subscription_name) ||
      topic.subscribe(subscription_name)
  end

  def retrieve_snapshot project, subscription, snapshot_name
    existing = project.snapshots.detect { |s| s.name.split("/").last == snapshot_name }
    existing || subscription.create_snapshot(snapshot_name)
  end

  let(:topic_name) { $topic_names[10] }
  let(:schema_name) { $schema_names[0] }
  let :schema_definition_hash do
    {
      "type" => "record",
      "name" => "State",
      "namespace" => "utilities",
      "doc" => "A list of states in the United States of America.",
      "fields" => [
        {
          "name" => "name",
          "type" => "string",
          "doc" => "The common name of the state."
        },
        {
          "name" => "post_abbr",
          "type" => "string",
          "doc" => "The postal code abbreviation of the state."
        }
      ]
    }
  end
  let(:schema_definition) { definition_hash.to_json }
focus
  it "should create, list, get, use and delete a schema" do
    schema = pubsub.create_schema schema_name, :avro, schema_definition
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema

    topic = pubsub.create_topic topic_name, schema_name: schema_name, schema_encoding: :json

    _(topic).must_be_kind_of Google::Cloud::PubSub::Topic
    topic = pubsub.topic(topic.name)
    _(topic).wont_be :nil?
  end
end
