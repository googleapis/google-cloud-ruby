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
require "avro"

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
  let(:message_data) { { "name" => "Alaska", "post_abbr" => "AK" }.to_json }
  let(:message_data_invalid) { { "BAD_VALUE" => nil }.to_json }

  it "should publish an AVRO message to a topic with an AVRO schema" do
    file = File.open('sightings.avro', 'wb')
    schema = Avro::Schema.parse definition
    writer = Avro::IO::DatumWriter.new(schema)
    dw = Avro::DataFile::Writer.new(file, writer, schema)
    dw << { "name" => "Alaska", "post_abbr" => "AK" }
    dw.close
    file = File.open('sightings.avro', 'r+')
    reader = Avro::IO::DatumReader.new(nil, schema)
    dr = Avro::DataFile::Reader.new(file, reader)
    dr.each { |record| p record }
  end

  it "should validate schema, create, list, get, validate message with, create topic with, and delete a schema" do
    # validate schema
    _(pubsub.valid_schema? :avro, definition).must_equal true
    _(pubsub.valid_schema? :TYPE_UNSPECIFIED, definition).must_equal false
    _(pubsub.valid_schema? :avro, nil).must_equal false
    _(pubsub.valid_schema? :avro, { "BAD_VALUE" => nil }.to_json).must_equal false

    # create
    schema = pubsub.create_schema schema_name, :avro, definition
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(schema.type).must_equal :AVRO
    _(schema.definition).must_equal definition

    # list
    schemas = pubsub.schemas view: :full
    _(schemas).wont_be :empty?
    schema = schemas.first
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).wont_be :nil?
    _(schema.type).wont_be :nil?
    _(schema.definition).wont_be :nil?

    # get
    schema = pubsub.schema schema_name, view: :full
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(schema.type).must_equal :AVRO
    _(schema.definition).must_equal definition

    # validate message
    _(schema.validate_message message_data, :json).must_equal true
    _(schema.validate_message message_data_invalid, :json).must_equal false

    # create topic with schema
    topic = pubsub.create_topic topic_name, schema_name: schema_name, schema_encoding: :json
    _(topic.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic.schema_encoding).must_equal :JSON

    topic = pubsub.topic topic.name
    _(topic.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic.schema_encoding).must_equal :JSON

    # delete
    schema.delete

    schema = pubsub.schema schema_name
    _(schema).must_be :nil?

    topic = pubsub.topic topic.name
    _(topic.schema_name).must_equal "_deleted-schema_"
    _(topic.schema_encoding).must_equal :JSON

    expect do 
      pubsub.create_topic topic_name_2, schema_name: schema_name, schema_encoding: :json
    end.must_raise Google::Cloud::NotFoundError
  end
end
