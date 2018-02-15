# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery, :advanced, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) { bigquery.dataset(dataset_id) || bigquery.create_dataset(dataset_id) }
  let(:table_id) { "examples_table" }
  let(:table) { @table }

  before do
    @table = get_or_create_example_table dataset, table_id
  end

  it "loads and returns the properly formatted data" do
    table.data.sort_by { |r| r[:id] }.zip(example_table_rows) do |returned_row, example_row|
      assert_rows_equal returned_row, example_row
    end
  end

  it "queries values in standard mode" do
    rows = bigquery.query "SELECT * FROM #{dataset_id}.#{table_id} WHERE id = ?", params: [2]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    row = rows.first

    assert_rows_equal rows.first, example_table_rows[1]
  end

  it "queries repeated scalars in legacy mode" do
    rows = bigquery.query "SELECT name, scores FROM [#{table.id}] WHERE id = 2", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 3
    rows[0].must_equal({ name: "Gandalf", scores: 100.0})
    rows[1].must_equal({ name: "Gandalf", scores: 99.0})
    rows[2].must_equal({ name: "Gandalf", scores: 0.001})
  end

  it "queries repeated records in legacy mode" do
    rows = bigquery.query "SELECT name, spells.name, spells.properties.name, spells.properties.power FROM [#{table.id}] WHERE id = 2", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 3
    rows[0].must_equal({ name: "Gandalf", spells_name: "Skydragon", spells_properties_name: "Flying",   spells_properties_power: 1.0 })
    rows[1].must_equal({ name: "Gandalf", spells_name: "Skydragon", spells_properties_name: "Creature", spells_properties_power: 1.0 })
    rows[2].must_equal({ name: "Gandalf", spells_name: "Skydragon", spells_properties_name: "Explodey", spells_properties_power: 11.0 })
  end

  it "modifies a nested schema via field" do
    empty_table_id = "#{table_id}_empty"
    empty_table = dataset.table empty_table_id
    empty_table.delete if empty_table

    empty_table = dataset.create_table empty_table_id do |schema|
      schema.integer "id", mode: :nullable
      schema.string "name", mode: :nullable
      schema.record "spells", mode: :repeated do |spells|
        spells.string "name", mode: :nullable
        spells.record "properties", mode: :repeated do |properties|
          properties.string "name", mode: :nullable
          properties.float "power", mode: :nullable
        end
      end
    end

    empty_table.schema.field("spells").headers.wont_include :score
    empty_table.schema.field("spells").headers.must_include :properties
    empty_table.schema.field(:spells).field(:properties).headers.wont_include :grade
    empty_table.schema do |schema|
      # adds to a nested field directly inline
      schema.field(:spells).integer :score, mode: :nullable
      # adds to a nested field in a block
      schema.field "spells" do |spells|
        spells.field "properties" do |properties|
          properties.float "grade", mode: :nullable
        end
      end
    end
    empty_table.schema.field("spells").headers.must_include :score
    empty_table.schema.field("spells").headers.must_include :properties
    empty_table.schema.field(:spells).field(:properties).headers.must_include :grade

    empty_table.delete
  end

  def assert_rows_equal returned_row, example_row
    returned_row[:id].must_equal example_row[:id]
    returned_row[:name].must_equal example_row[:name]
    returned_row[:age].must_equal example_row[:age]
    returned_row[:weight].must_equal example_row[:weight]
    returned_row[:is_magic].must_equal example_row[:is_magic]
    returned_row[:scores].must_equal example_row[:scores]
    returned_row[:spells].zip example_row[:spells] do |row_spell, example_spell|
      row_spell[:name].must_equal example_spell[:name]
      row_spell[:discovered_by].must_equal example_spell[:discovered_by]
      row_spell[:properties].zip example_spell[:properties] do |row_properties, example_properties|
        row_properties[:name].must_equal example_properties[:name]
        row_properties[:power].must_equal example_properties[:power]
      end
    end
    returned_row[:tea_time].must_equal example_row[:tea_time]
    returned_row[:next_vacation].must_equal example_row[:next_vacation]
    returned_row[:favorite_time].must_equal example_row[:favorite_time]
  end

  def get_or_create_example_table dataset, table_id
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.integer "id", mode: :nullable
        schema.string "name", mode: :nullable
        schema.integer "age", mode: :nullable
        schema.float "weight", mode: :nullable
        schema.boolean "is_magic", mode: :nullable
        schema.float "scores", mode: :repeated
        schema.record "spells", mode: :repeated do |spells|
          spells.string "name", mode: :nullable
          spells.string "discovered_by", mode: :nullable
          spells.record "properties", mode: :repeated do |properties|
            properties.string "name", mode: :nullable
            properties.float "power", mode: :nullable
          end
          spells.bytes "icon", mode: :nullable
          spells.timestamp "last_used", mode: :nullable
        end
        schema.time "tea_time", mode: :nullable
        schema.date "next_vacation", mode: :nullable
        schema.datetime "favorite_time", mode: :nullable
      end
      t.insert example_table_rows
    end
    t
  end

  def example_table_rows
    [
      { id: 1,
        name: "Bilbo",
        age: 111,
        weight: 67.2,
        is_magic: false,
        scores: [],
        spells: [],
        tea_time: Google::Cloud::Bigquery::Time.new("10:00:00"),
        next_vacation: Date.parse("2017-09-22"),
        favorite_time: Time.parse("2031-04-01T05:09:27").utc.to_datetime
      }, {
        id: 2,
        name: "Gandalf",
        age: 1000,
        weight: 198.6,
        is_magic: true,
        scores: [100.0, 99.0, 0.001],
        spells: [
          { name: "Skydragon",
            discovered_by: "Firebreather",
            properties: [
              { name: "Flying", power: 1.0 },
              { name: "Creature", power: 1.0 },
              { name: "Explodey", power: 11.0 }
            ],
            icon: File.open("acceptance/data/kitten-test-data.json", "rb"),
            last_used: Time.parse("2015-10-31 23:59:56 UTC")
          }
        ],
        tea_time: Google::Cloud::Bigquery::Time.new("15:00:00"),
        next_vacation: Date.parse("2666-06-06"),
        favorite_time: Time.parse("2001-12-19T23:59:59").utc.to_datetime
      }, {
        id: 3,
        name: "Sabrina",
        age: 17,
        weight: 128.3,
        is_magic: true,
        scores: [],
        spells: [
          { name: "Talking cats",
            icon: StringIO.new("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAAAgAAAAKAAAACAAAAAgAAABxj2CfowAAAGSSURBVHgB7Jc9TsNAEIX3JDkCPUV6KlpKFHEGlD4nyA04ACUXQKTgCEipUnKGNEbP0otentayicZ24SlWs7tjO/N9u/5J2b2+NUtuZcnwYE8BuQPyGZAPwXwLLPk5kG+BJa9+fgfkh1B+CeancL4F8i2Q/wWm/S/w+XFoTseftn0dvhu0OXfhpM+AGvzcEiYVAFisPqE9zrETJhHAlXfg2lglMK9z0f3RBfB+ZyRUV3x+erzsEIjjOBqc1xtNAIrvguybV3A9lkVHxlEE6GrrPb/ZvAySwlUnfCmlPQ+R8JCExvGtcRQBLFwj4FGkznX1VYDKPG/f2/MjwCksXACgdNUxJjwK9xwl4JihOwTFR0kIF+CABEPRnvsvPFctMoYKqAFSAFaMwB4pp3Y+bodIYL9WmIAaIOHxo7W8wiHvAjTvhUeNwwSgeAeAABbqOewC5hBdwFD4+9+7puzXV9fS6/b1wwT4tsaYAhwOOQdUQch5vgZCeAhAv3ZM31yYAAUgvApQQQ6n5w6FB/RVe1jdJOAPAAD//1eMQwoAAAGQSURBVO1UMU4DQQy8X9AgWopIUINEkS4VlJQo4gvwAV7AD3gEH4iSgidESpWSXyyZExP5lr0c7K5PsXBhec/2+jzjuWtent9CLdtu1mG5+gjz+WNr7IsY7eH+tvO+xfuqk4vz7CH91edFaF5v9nb6dBKm13edvrL+0Lk5lMzJkQDeJSkkgHF6mR8CHwMHCQR/NAQQGD0BAlwK4FCefQiefq+A2Vn29tG7igLAfmwcnJu/nJy3BMQkMN9HEPr8AL3bfBv7Bp+7/SoExMDjZwKEJwmyhnnmQIQEBIlz2x0iKoAvJkAC6TsTIH6MqRrEWUMSZF2zAwqT4Eu/e6pzFAIkmNSZ4OFT+VYBIIF//UqbJwnF/4DU0GwOn8r/JQYCpPGufEfJuZiA37ycQw/5uFeqPq4pfR6FADmkBCXjfWdZj3NfXW58dAJyB9W65wRoMWulryvAyqa05nQFaDFrpa8rwMqmtOZ0BWgxa6WvK8DKprTmdAVoMWulryvAyqa05nQFaDFrpa8rwMqmtOb89wr4AtQ4aPoL6yVpAAAAAElFTkSuQmCC"),
            discovered_by: "Salem",
            properties: [{ name: "Makes you look crazy", power: 1 }],
            last_used: Time.parse("2017-02-14 12:07:23 UTC")
          }
        ],
        tea_time: Google::Cloud::Bigquery::Time.new("12:00:00"),
        next_vacation: Date.parse("2017-03-14"),
        favorite_time: Time.parse("2000-10-31T23:27:46").utc.to_datetime
      }
    ]
  end
end
