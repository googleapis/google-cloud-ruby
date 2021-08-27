# Copyright 2021 Google LLC
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

describe Google::Cloud::Bigquery::Schema, :mock_bigquery do
  let(:policy_tag) { "projects/#{project}/locations/us/taxonomies/1/policyTags/1" }
  let(:policy_tag_2) { "projects/#{project}/locations/us/taxonomies/1/policyTags/2" }
  let(:policy_tag_3) { "projects/#{project}/locations/us/taxonomies/1/policyTags/3" }
  let(:policy_tags) { [ policy_tag, policy_tag_2 ] }
  let(:policy_tags_gapi) { Google::Apis::BigqueryV2::TableFieldSchema::PolicyTags.new names: policy_tags }
  let :field_integer_gapi do
    Google::Apis::BigqueryV2::TableFieldSchema.new(
      name: "rank",
      type: "INTEGER",
      mode: "NULLABLE",
      policy_tags: policy_tags_gapi
    )
  end
  let :schema_gapi do
    Google::Apis::BigqueryV2::TableSchema.new(
      fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(
          name: "my_secret_integer",
          type: "INT64",
          mode: "REQUIRED",
          policy_tags: policy_tags_gapi
        ),
        Google::Apis::BigqueryV2::TableFieldSchema.new(
          name: "cities_lived",
          type: "RECORD",
          mode: "REPEATED",
          fields: [field_integer_gapi]
        )
      ]
    )
  end
  let(:schema) { Google::Cloud::Bigquery::Schema.from_gapi schema_gapi }

  it "knows its policy tags" do
    _(schema.field("my_secret_integer").policy_tags).must_equal policy_tags
    _(schema.field("cities_lived").field("rank").policy_tags).must_equal policy_tags
  end

  it "includes policy tags in to_gapi" do
    gapi = schema.to_gapi
    _(gapi.fields[0].policy_tags).must_be_instance_of Google::Apis::BigqueryV2::TableFieldSchema::PolicyTags
    _(gapi.fields[0].policy_tags.names).must_equal policy_tags
  end

  it "sets its policy tags to a new array" do
    field = schema.field :my_secret_integer
    _(field.policy_tags).must_equal policy_tags

    field.policy_tags = [policy_tag_3]
    _(field.policy_tags).must_equal [policy_tag_3]
  end

  it "sets its policy tags to a single string" do
    field = schema.field :my_secret_integer
    _(field.policy_tags).must_equal policy_tags

    field.policy_tags = policy_tag_3
    _(field.policy_tags).must_equal [policy_tag_3]
  end

  it "removes its policy tags" do
    field = schema.field :my_secret_integer
    _(field.policy_tags).must_equal policy_tags

    field.policy_tags = nil
    _(field.policy_tags).must_be :nil?
    gapi = schema.to_gapi
    _(gapi.fields[0].policy_tags).must_be_instance_of Google::Apis::BigqueryV2::TableFieldSchema::PolicyTags
    _(gapi.fields[0].policy_tags.names).must_equal []
  end
end
