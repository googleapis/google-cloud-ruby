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

require "spanner_helper"

describe "Spanner Client", :large_data, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }

  def generate_bytes count = 2048
    StringIO.new(SecureRandom.random_bytes(count))
  end

  def generate_string count = 50
    count.times.map { "The quick brown fox jumps over the lazy dog." }.join("\n")
  end

  def random_small_bytes count = rand(1024..4096)
    generate_bytes(count)
  end

  def random_small_string count = rand(25..100)
    generate_string(count)
  end

  ##
  # Guarenteed to be at least 1 MB
  def random_big_bytes offset = rand(1..2048)
    generate_bytes(1024*1024 + offset)
  end

  ##
  # Guarenteed to be at least 1 MB
  def random_big_string offset = rand(1..500)
    generate_string(25000 + offset)
  end

  def random_row
    {
      id: SecureRandom.int64,
      string: random_big_string,
      strings: [random_big_string, random_small_string, random_big_string],
      byte: random_big_bytes,
      bytes: [random_big_bytes, random_small_bytes, random_big_bytes]
    }
  end

  it "writes and reads large random data" do
    my_row = random_row
    db.upsert table_name, my_row
    results = db.read table_name, [:id, :string, :byte, :strings, :bytes], keys: my_row[:id]

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, string: :STRING, byte: :BYTES, strings: [:STRING], bytes: [:BYTES] })
    returned_row = results.rows.first

    returned_row[:string].must_equal my_row[:string]

    returned_row[:strings].must_equal my_row[:strings]

    returned_row[:byte].must_be_kind_of StringIO
    my_row[:byte].rewind
    returned_row[:byte].read.must_equal my_row[:byte].read

    returned_row[:bytes].each do |byte|
      byte.must_be_kind_of StringIO
    end
    my_row[:bytes].each(&:rewind)
    returned_row[:bytes].each_with_index do |byte, index|
      byte.read.must_equal my_row[:bytes][index].read
    end
  end

  it "writes and queries bytes" do
    my_row = random_row
    db.upsert table_name, my_row
    results = db.execute "SELECT id, string, byte, strings, bytes FROM #{table_name} WHERE id = @id", params: { id: my_row[:id] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, string: :STRING, byte: :BYTES, strings: [:STRING], bytes: [:BYTES] })
    returned_row = results.rows.first

    returned_row[:string].must_equal my_row[:string]

    returned_row[:strings].must_equal my_row[:strings]

    returned_row[:byte].must_be_kind_of StringIO
    my_row[:byte].rewind
    returned_row[:byte].read.must_equal my_row[:byte].read

    returned_row[:bytes].each do |byte|
      byte.must_be_kind_of StringIO
    end
    my_row[:bytes].each(&:rewind)
    returned_row[:bytes].each_with_index do |byte, index|
      byte.read.must_equal my_row[:bytes][index].read
    end
  end
end
