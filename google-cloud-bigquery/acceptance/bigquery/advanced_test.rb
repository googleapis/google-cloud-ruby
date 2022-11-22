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

  let(:string_numeric) { "1.123456789" }
  let(:string_bignumeric) { "1.1234567890123456789012345678901234567" }
  let(:max_length_string) { 50 }
  let(:max_length_bytes) { 2048 }
  let(:precision_numeric) { 10 }
  let(:precision_bignumeric) { 38 }
  let(:scale_numeric) { 9 }
  let(:scale_bignumeric) { 37 }

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

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 1
    row = rows.first

    assert_rows_equal rows.first, example_table_rows[1]
  end

  it "queries repeated scalars in legacy mode" do
    rows = bigquery.query "SELECT name, scores FROM [#{table.id}] WHERE id = 2", legacy_sql: true

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 3
    _(rows[0]).must_equal({ name: "Gandalf", scores: 100.0})
    _(rows[1]).must_equal({ name: "Gandalf", scores: 99.0})
    _(rows[2]).must_equal({ name: "Gandalf", scores: 0.001})
  end

  it "queries repeated records in legacy mode" do
    rows = bigquery.query "SELECT name, spells.name, spells.properties.name, spells.properties.power FROM [#{table.id}] WHERE id = 2", legacy_sql: true

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 3
    _(rows[0]).must_equal({ name: "Gandalf", spells_name: "Skydragon", spells_properties_name: "Flying",   spells_properties_power: 1.0 })
    _(rows[1]).must_equal({ name: "Gandalf", spells_name: "Skydragon", spells_properties_name: "Creature", spells_properties_power: 1.0 })
    _(rows[2]).must_equal({ name: "Gandalf", spells_name: "Skydragon", spells_properties_name: "Explodey", spells_properties_power: 11.0 })
  end

  it "queries in session mode" do
    job = bigquery.query_job "CREATE TEMPORARY TABLE temptable AS SELECT 17 as foo", dataset: dataset, create_session: true
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.session_id).wont_be :nil?

    job_2 = bigquery.query_job "SELECT * FROM temptable", dataset: dataset, session_id: job.session_id
    job_2.wait_until_done!
    _(job_2).wont_be :failed?
    _(job_2.session_id).wont_be :nil?
    _(job_2.session_id).must_equal job.session_id
    _(job_2.data.first).wont_be :nil?
    _(job_2.data.first[:foo]).must_equal 17

    data = bigquery.query "SELECT * FROM temptable", dataset: dataset, session_id: job.session_id
    _(data.first).wont_be :nil?
    _(data.first[:foo]).must_equal 17
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

    _(empty_table.schema.field("spells").headers).wont_include :score
    _(empty_table.schema.field("spells").headers).must_include :properties
    _(empty_table.schema.field(:spells).field(:properties).headers).wont_include :grade
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
    _(empty_table.schema.field("spells").headers).must_include :score
    _(empty_table.schema.field("spells").headers).must_include :properties
    _(empty_table.schema.field(:spells).field(:properties).headers).must_include :grade

    empty_table.delete
  end

  it "converts all floats correctly" do
    rows = bigquery.query "SELECT CAST('NaN' as FLOAT64) as not_a_number, CAST('+inf' as FLOAT64) as positive_infinity, CAST('-inf' as FLOAT64) as negative_infinity"

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 1
    row = rows.first

    assert_predicate row[:not_a_number], :nan? # assert_equal won't work with Float::NAN
    assert_equal  Float::INFINITY, row[:positive_infinity]
    assert_equal -Float::INFINITY, row[:negative_infinity]
  end

  it "executes SQL with multiple statements in a transaction and creates child jobs with script_statistics and transaction_info" do
    multi_statement_sql = <<~SQL
      -- Declare a variable to hold names as an array.
      DECLARE top_names ARRAY<STRING>;
      BEGIN TRANSACTION;
      -- Build an array of the top 100 names from the year 2017.
      SET top_names = (
      SELECT ARRAY_AGG(name ORDER BY number DESC LIMIT 100)
      FROM `bigquery-public-data.usa_names.usa_1910_current`
      WHERE year = 2017
      );
      -- Which names appear as words in Shakespeare's plays?
      SELECT
      name AS shakespeare_name
      FROM UNNEST(top_names) AS name
      WHERE name IN (
      SELECT word
      FROM `bigquery-public-data.samples.shakespeare`
      );
      COMMIT TRANSACTION;
    SQL

    job = bigquery.query_job multi_statement_sql

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.num_child_jobs).must_equal 4
    _(job.parent_job_id).must_be :nil?

    _(job.script_statistics).must_be :nil?

    child_jobs = bigquery.jobs parent_job: job
    _(child_jobs.count).must_equal 4

    _(child_jobs[0].parent_job_id).must_equal job.job_id
    transaction_id = child_jobs[0].transaction_id
    _(transaction_id).must_be_instance_of String
    _(transaction_id).wont_be :empty?
    _(child_jobs[0].script_statistics).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStatistics
    _(child_jobs[0].script_statistics.evaluation_kind).must_equal "STATEMENT"
    _(child_jobs[0].script_statistics.stack_frames).wont_be :nil?
    _(child_jobs[0].script_statistics.stack_frames).must_be_kind_of Array
    _(child_jobs[0].script_statistics.stack_frames.count).must_equal 1
    _(child_jobs[0].script_statistics.stack_frames[0]).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStackFrame
    _(child_jobs[0].script_statistics.stack_frames[0].start_line).must_equal 18
    _(child_jobs[0].script_statistics.stack_frames[0].start_column).must_equal 1
    _(child_jobs[0].script_statistics.stack_frames[0].end_line).must_equal 18
    _(child_jobs[0].script_statistics.stack_frames[0].end_column).must_equal 19
    _(child_jobs[0].script_statistics.stack_frames[0].text).wont_be :empty?

    _(child_jobs[1].parent_job_id).must_equal job.job_id
    _(child_jobs[1].transaction_id).must_equal transaction_id
    _(child_jobs[1].script_statistics).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStatistics
    _(child_jobs[1].script_statistics.evaluation_kind).must_equal "STATEMENT"
    _(child_jobs[1].script_statistics.stack_frames).wont_be :nil?
    _(child_jobs[1].script_statistics.stack_frames).must_be_kind_of Array
    _(child_jobs[1].script_statistics.stack_frames.count).must_equal 1
    _(child_jobs[1].script_statistics.stack_frames[0]).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStackFrame
    _(child_jobs[1].script_statistics.stack_frames[0].start_line).must_equal 11
    _(child_jobs[1].script_statistics.stack_frames[0].start_column).must_equal 1
    _(child_jobs[1].script_statistics.stack_frames[0].end_line).must_equal 17
    _(child_jobs[1].script_statistics.stack_frames[0].end_column).must_equal 2
    _(child_jobs[1].script_statistics.stack_frames[0].text).wont_be :empty?

    _(child_jobs[2].parent_job_id).must_equal job.job_id
    _(child_jobs[2].transaction_id).must_equal transaction_id
    _(child_jobs[2].script_statistics).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStatistics
    _(child_jobs[2].script_statistics.evaluation_kind).must_equal "EXPRESSION"
    _(child_jobs[2].script_statistics.stack_frames).wont_be :nil?
    _(child_jobs[2].script_statistics.stack_frames).must_be_kind_of Array
    _(child_jobs[2].script_statistics.stack_frames.count).must_equal 1
    _(child_jobs[2].script_statistics.stack_frames[0]).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStackFrame
    _(child_jobs[2].script_statistics.stack_frames[0].start_line).must_equal 5
    _(child_jobs[2].script_statistics.stack_frames[0].start_column).must_equal 17
    _(child_jobs[2].script_statistics.stack_frames[0].end_line).must_equal 9
    _(child_jobs[2].script_statistics.stack_frames[0].end_column).must_equal 2
    _(child_jobs[2].script_statistics.stack_frames[0].text).wont_be :empty?

    _(child_jobs[3].parent_job_id).must_equal job.job_id
    _(child_jobs[3].transaction_id).must_equal transaction_id
    _(child_jobs[3].script_statistics).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStatistics
    _(child_jobs[3].script_statistics.evaluation_kind).must_equal "STATEMENT"
    _(child_jobs[3].script_statistics.stack_frames).wont_be :nil?
    _(child_jobs[3].script_statistics.stack_frames).must_be_kind_of Array
    _(child_jobs[3].script_statistics.stack_frames.count).must_equal 1
    _(child_jobs[3].script_statistics.stack_frames[0]).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStackFrame
    _(child_jobs[3].script_statistics.stack_frames[0].start_line).must_equal 3
    _(child_jobs[3].script_statistics.stack_frames[0].start_column).must_equal 1
    _(child_jobs[3].script_statistics.stack_frames[0].end_line).must_equal 3
    _(child_jobs[3].script_statistics.stack_frames[0].end_column).must_equal 18
    _(child_jobs[3].script_statistics.stack_frames[0].text).wont_be :empty?
  end

  it "queries max scale numeric and bignumeric values" do
    rows = bigquery.query "SELECT my_numeric, my_bignumeric FROM #{dataset_id}.#{table_id} WHERE id = 1"

    _(rows.count).must_equal 1
    _(rows[0][:my_numeric]).must_be_kind_of BigDecimal
    _(rows[0][:my_numeric]).must_equal BigDecimal(string_numeric)

    _(rows[0][:my_bignumeric]).must_be_kind_of BigDecimal
    _(rows[0][:my_bignumeric]).must_equal BigDecimal(string_bignumeric)
  end

  it "knows its schema max_length for string and bytes fields" do
    _(table.schema.field("age").max_length).must_be :nil?
    _(table.schema.field("name").max_length).must_equal max_length_string
    _(table.schema.field("spells").field("icon").max_length).must_equal max_length_bytes
  end

  it "knows its schema precision and scale for numeric and bignumeric fields" do
    _(table.schema.field("age").precision).must_be :nil?
    _(table.schema.field("age").scale).must_be :nil?

    _(table.schema.field("my_numeric").precision).must_equal precision_numeric
    _(table.schema.field("my_numeric").scale).must_equal scale_numeric
    _(table.schema.field("my_bignumeric").precision).must_equal precision_bignumeric
    _(table.schema.field("my_bignumeric").scale).must_equal scale_bignumeric

    _(table.schema.field("spells").field("my_nested_numeric").precision).must_equal precision_numeric
    _(table.schema.field("spells").field("my_nested_numeric").scale).must_equal scale_numeric
    _(table.schema.field("spells").field("my_nested_bignumeric").precision).must_equal precision_bignumeric
    _(table.schema.field("spells").field("my_nested_bignumeric").scale).must_equal scale_bignumeric
  end

  def assert_rows_equal returned_row, example_row
    _(returned_row[:id]).must_equal example_row[:id]
    _(returned_row[:name]).must_equal example_row[:name]
    _(returned_row[:age]).must_equal example_row[:age]
    _(returned_row[:weight]).must_equal example_row[:weight]
    _(returned_row[:is_magic]).must_equal example_row[:is_magic]
    _(returned_row[:scores]).must_equal example_row[:scores]
    returned_row[:spells].zip example_row[:spells] do |row_spell, example_spell|
      _(row_spell[:name]).must_equal example_spell[:name]
      _(row_spell[:discovered_by]).must_equal example_spell[:discovered_by]
      row_spell[:properties].zip example_spell[:properties] do |row_properties, example_properties|
        _(row_properties[:name]).must_equal example_properties[:name]
        _(row_properties[:power]).must_equal example_properties[:power]
      end
    end
    _(returned_row[:tea_time]).must_equal example_row[:tea_time]
    _(returned_row[:next_vacation]).must_equal example_row[:next_vacation]
    _(returned_row[:favorite_time]).must_equal example_row[:favorite_time]
  end

  def get_or_create_example_table dataset, table_id
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.integer "id", mode: :nullable
        schema.string "name", mode: :nullable, max_length: max_length_string
        schema.integer "age", mode: :nullable
        schema.float "weight", mode: :nullable
        schema.numeric "my_numeric", mode: :nullable, precision: precision_numeric, scale: scale_numeric
        schema.bignumeric "my_bignumeric", mode: :nullable, precision: precision_bignumeric, scale: scale_bignumeric
        schema.boolean "is_magic", mode: :nullable
        schema.float "scores", mode: :repeated
        schema.record "spells", mode: :repeated do |spells|
          spells.string "name", mode: :nullable
          spells.string "discovered_by", mode: :nullable
          spells.record "properties", mode: :repeated do |properties|
            properties.string "name", mode: :nullable
            properties.float "power", mode: :nullable
          end
          spells.bytes "icon", mode: :nullable, max_length: max_length_bytes
          spells.timestamp "last_used", mode: :nullable
          spells.numeric "my_nested_numeric", mode: :nullable, precision: precision_numeric, scale: scale_numeric
          spells.bignumeric "my_nested_bignumeric", mode: :nullable, precision: precision_bignumeric, scale: scale_bignumeric
        end
        schema.time "tea_time", mode: :nullable
        schema.date "next_vacation", mode: :nullable
        schema.datetime "favorite_time", mode: :nullable
      end
      insert_resp = t.insert example_table_rows
      raise "insert errors: #{insert_resp.insert_errors.inspect}" unless insert_resp.success?
    end
    t
  end

  def example_table_rows
    [
      {
        id: 1,
        name: "Bilbo",
        age: 111,
        weight: 67.2,
        my_numeric: BigDecimal(string_numeric),
        my_bignumeric: string_bignumeric, # BigDecimal would be rounded, use String instead!
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
            last_used: Time.parse("2015-10-31 23:59:56 UTC"),
            my_nested_numeric: BigDecimal(string_numeric),
            my_nested_bignumeric: string_bignumeric, # BigDecimal would be rounded, use String instead!
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
