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

require "helper"

describe Google::Cloud::Spanner::Fields, :initializer do
  it "creates with an array of fields" do
    fields = Google::Cloud::Spanner::Fields.new [:INT64, :STRING, :BOOL, :JSON]

    _(fields.types).must_equal [:INT64, :STRING, :BOOL, :JSON]
    _(fields.keys).must_equal [0, 1, 2, 3]
    _(fields.pairs).must_equal [[0, :INT64], [1, :STRING], [2, :BOOL], [3, :JSON]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL, :JSON]
    _(fields.to_h).must_equal({ 0 => :INT64, 1 => :STRING, 2 => :BOOL, 3 => :JSON })
  end

  it "creates with an array of type pairs" do
    fields = Google::Cloud::Spanner::Fields.new [[:id, :INT64], [:name, :STRING], [:active, :BOOL]]

    _(fields.types).must_equal [:INT64, :STRING, :BOOL]
    _(fields.keys).must_equal [:id, :name, :active]
    _(fields.pairs).must_equal [[:id, :INT64], [:name, :STRING], [:active, :BOOL]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL]
    _(fields.to_h).must_equal({ id: :INT64, name: :STRING, active: :BOOL })
  end

  it "creates with a mixed array of fields" do
    fields = Google::Cloud::Spanner::Fields.new [:INT64, [:name, :STRING], :BOOL]

    _(fields.types).must_equal [:INT64, :STRING, :BOOL]
    _(fields.keys).must_equal [0, :name, 2]
    _(fields.pairs).must_equal [[0, :INT64], [:name, :STRING], [2, :BOOL]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL]
    _(fields.to_h).must_equal({ 0=>:INT64, name: :STRING, 2=>:BOOL })
  end

  it "creates with an unsorted mixed array of fields" do
    fields = Google::Cloud::Spanner::Fields.new [[:name, :STRING], :BOOL, [0, :INT64]]

    _(fields.types).must_equal [:INT64, :STRING, :BOOL]
    _(fields.keys).must_equal [0, :name, 2]
    _(fields.pairs).must_equal [[0, :INT64], [:name, :STRING], [2, :BOOL]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL]
    _(fields.to_h).must_equal({ 0=>:INT64, name: :STRING, 2=>:BOOL })
  end

  it "creates with a positional hash of fields" do
    fields = Google::Cloud::Spanner::Fields.new 0=>:INT64, 1=>:STRING, 2=>:BOOL

    _(fields.types).must_equal [:INT64, :STRING, :BOOL]
    _(fields.keys).must_equal [0, 1, 2]
    _(fields.pairs).must_equal [[0, :INT64], [1, :STRING], [2, :BOOL]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL]
    _(fields.to_h).must_equal({ 0=>:INT64, 1=>:STRING, 2=>:BOOL })
  end

  it "creates with named hash of fields" do
    fields = Google::Cloud::Spanner::Fields.new id: :INT64, name: :STRING, active: :BOOL

    _(fields.types).must_equal [:INT64, :STRING, :BOOL]
    _(fields.keys).must_equal [:id, :name, :active]
    _(fields.pairs).must_equal [[:id, :INT64], [:name, :STRING], [:active, :BOOL]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL]
    _(fields.to_h).must_equal({ id: :INT64, name: :STRING, active: :BOOL })
  end

  it "creates with mixed hash of fields" do
    fields = Google::Cloud::Spanner::Fields.new 0=>:INT64, name: :STRING, 2=>:BOOL

    _(fields.types).must_equal [:INT64, :STRING, :BOOL]
    _(fields.keys).must_equal [0, :name, 2]
    _(fields.pairs).must_equal [[0, :INT64], [:name, :STRING], [2, :BOOL]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL]
    _(fields.to_h).must_equal({ 0=>:INT64, name: :STRING, 2=>:BOOL })
  end

  it "creates with an unsorted mixed hash of fields" do
    fields = Google::Cloud::Spanner::Fields.new name: :STRING, 2=>:BOOL, 0=>:INT64

    _(fields.types).must_equal [:INT64, :STRING, :BOOL]
    _(fields.keys).must_equal [0, :name, 2]
    _(fields.pairs).must_equal [[0, :INT64], [:name, :STRING], [2, :BOOL]]
    _(fields.to_a).must_equal [:INT64, :STRING, :BOOL]
    _(fields.to_h).must_equal({ 0=>:INT64, name: :STRING, 2=>:BOOL })
  end

  it "raises when creating duplicate positions" do
    err = expect do
      fields = Google::Cloud::Spanner::Fields.new [[-1, :INT64], [:name, :STRING], [2, :BOOL]]
    end.must_raise ArgumentError
    _(err.message).must_equal "cannot specify position less than 0"
  end

  it "raises when creating duplicate positions" do
    err = expect do
      fields = Google::Cloud::Spanner::Fields.new [[0, :INT64], [:name, :STRING], [3, :BOOL]]
    end.must_raise ArgumentError
    _(err.message).must_equal "cannot specify position more than field count"
  end

  it "raises when creating duplicate positions" do
    err = expect do
      fields = Google::Cloud::Spanner::Fields.new [[0, :INT64], [:name, :STRING], [0, :BOOL]]
    end.must_raise ArgumentError
    _(err.message).must_equal "cannot specify position more than once"
  end
end
