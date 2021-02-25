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
  let(:topic_name) { $topic_names[10] }
  let(:topic_name_2) { $topic_names[11] }
  let(:schema_name) { $schema_names[0] }
  let :definition_hash do
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
  let(:definition) { definition_hash.to_json }
focus
  it "should create, list, get, use and delete a schema" do
    schema = pubsub.create_schema schema_name, :avro, definition
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(schema.type).must_equal :AVRO
    _(schema.definition).must_equal definition

    schema = pubsub.schema schema_name, view: :full
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(schema.type).must_equal :AVRO
    _(schema.definition).must_equal definition

    topic = pubsub.create_topic topic_name, schema_name: schema_name, schema_encoding: :json
    _(topic.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic.schema_encoding).must_equal :JSON

    topic = pubsub.topic topic.name
    _(topic.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic.schema_encoding).must_equal :JSON

    schema.delete

    schema = pubsub.schema schema_name
    _(schema).must_be :nil?

    topic = pubsub.topic topic.name
    _(topic.schema_name).must_equal "_deleted-schema_"
    _(topic.schema_encoding).must_equal :JSON

    expect do 
      pubsub.create_topic topic_name_2, schema_name: schema_name, schema_encoding: :json
    end.must_raise Google::Cloud::NotFoundError

    topic_2 = pubsub.create_topic topic_name_2
    _(topic_2.schema_name).must_be :nil?
    _(topic_2.schema_encoding).must_be :nil?

    topic_2.schema_name = schema_name
    _(topic_2.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic_2.schema_encoding).must_equal :ENCODING_UNSPECIFIED

    topic_2.schema_encoding = :BINARY
    _(topic_2.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic_2.schema_encoding).must_equal :BINARY

    topic_2 = pubsub.topic topic_2.name
    _(topic_2.schema_name).must_be :nil?
  end
end
