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

require "bigquery_helper"
require "google/cloud/data_catalog"
require "google/cloud/data_catalog/v1"

describe Google::Cloud::Bigquery::Schema, :policy_tags, :bigquery do

  let(:policy_tag_manager) { Google::Cloud::DataCatalog.policy_tag_manager }
  let(:policy_tag_location) { "us" }
  let(:taxonomy_parent) { "projects/#{bigquery.project_id}/locations/#{policy_tag_location}" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "table_policy_tag_#{SecureRandom.hex(16)}" }
  let(:table_id_2) { "table_policy_tag_2_#{SecureRandom.hex(16)}" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.integer   "id",    description: "id description",    mode: :required
        schema.string    "name",  description: "name description",  mode: :required
        schema.timestamp "dob",   description: "dob description",   mode: :required
      end
    end
    t
  end

  it "sets, updates and removes policy tags for a field" do
    taxonomy_id = nil
    begin
      taxonomy = Google::Cloud::DataCatalog::V1::Taxonomy.new(
        display_name: "google-cloud-ruby bigquery testing taxonomy",
			  description: "Taxonomy created for google-cloud-ruby acceptance tests",
			  activated_policy_types: [:FINE_GRAINED_ACCESS_CONTROL]
      )
      taxonomy = policy_tag_manager.create_taxonomy parent: taxonomy_parent, taxonomy: taxonomy
      taxonomy_id = taxonomy.name
      _(taxonomy_id).must_be_kind_of String

      policy_tag = Google::Cloud::DataCatalog::V1::PolicyTag.new(
        display_name: "ExamplePolicyTag"
      )
      policy_tag = policy_tag_manager.create_policy_tag parent: taxonomy_id, policy_tag: policy_tag
      policy_tag_id = policy_tag.name
      _(policy_tag_id).must_be_kind_of String

      _(table.schema.field("dob").policy_tags).must_be :nil?

      table.schema do |schema|
        schema.field("dob").policy_tags = policy_tag_id
      end

      _(table.schema.field("dob").policy_tags).must_equal [policy_tag_id]
      table.reload!
      _(table.schema.field("dob").policy_tags).must_equal [policy_tag_id]

      table.schema do |schema|
        schema.field("dob").policy_tags = nil
      end

      _(table.schema.field("dob").policy_tags).must_be :nil?
      table.reload!
      _(table.schema.field("dob").policy_tags).must_be :nil?

      table_2 = dataset.create_table table_id_2 do |t|
        t.schema do |schema|
          schema.integer   "id",    description: "id description",    mode: :required
          schema.string    "name",  description: "name description",  mode: :required
          schema.timestamp "dob",   description: "dob description",   mode: :required, policy_tags: [policy_tag_id]

          schema.record "spells", mode: :repeated do |spells|
            spells.string "name", mode: :nullable, policy_tags: [policy_tag_id]
            spells.record "properties", mode: :repeated do |properties|
              properties.float "power", mode: :nullable, policy_tags: [policy_tag_id]
            end
          end
        end
      end

      _(table_2.schema.field("dob").policy_tags).must_equal [policy_tag_id]
      _(table_2.schema.field("spells").field("name").policy_tags).must_equal [policy_tag_id]
      _(table_2.schema.field("spells").field("properties").field("power").policy_tags).must_equal [policy_tag_id]
      table_2.reload!
      _(table_2.schema.field("dob").policy_tags).must_equal [policy_tag_id]
      _(table_2.schema.field("spells").field("name").policy_tags).must_equal [policy_tag_id]
      _(table_2.schema.field("spells").field("properties").field("power").policy_tags).must_equal [policy_tag_id]
      
    ensure
      policy_tag_manager.delete_taxonomy name: taxonomy_id if taxonomy_id
    end
  end
end
