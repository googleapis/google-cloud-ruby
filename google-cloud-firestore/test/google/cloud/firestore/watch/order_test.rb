# Copyright 2018 Google LLC
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
require "bigdecimal"

class Google::Cloud::Firestore::DocumentReference
  def inspect
    path
  end
end

describe "Watch", :order, :mock_firestore do
  # Ruby integers are not fixed, so use these values instead
  FIXNUM_MAX = (2**(0.size * 8 -2) -1)
  FIXNUM_MIN = -(2**(0.size * 8 -2))

  def sorted_values
    [
      # Null
      nil,

      # Booleans
      false,
      true,

      # Numbers
      Float::NAN,
      -Float::INFINITY,
      -Float::MAX,
      FIXNUM_MIN - 1,
      FIXNUM_MIN,
      -1.1,
      -1,
      -Float::MIN,
      0,
      Float::MIN,
      Float::EPSILON,
      0.1,
      1,
      1.1,
      2,
      10,
      FIXNUM_MAX,
      FIXNUM_MAX + 1,
      Float::MAX,
      Float::INFINITY,

      # Timestamps
      Time.new(2016, 5, 20, 10, 20),
      Time.new(2016, 10, 21, 15, 32),

      # Strings
      "",
      "\u0000\ud7ff\ue000\uffff",
      "(╯°□°）╯︵ ┻━┻",
      "a",
      "abc def",
      # latin small letter e + combining acute accent + latin small letter b
      "e\u0301b",
      "æ",
      # latin small letter e with acute accent + latin small letter a
      "\u00e9a",

      StringIO.new(""),
      StringIO.new([0].map(&:chr).join),
      StringIO.new([0, 1, 2, 3, 4].map(&:chr).join),
      StringIO.new([0, 1, 2, 4, 3].map(&:chr).join),
      StringIO.new([127].map(&:chr).join),

      # Resource names
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p1/databases/d1/documents/c1/doc1", firestore),
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p1/databases/d1/documents/c1/doc2", firestore),
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p1/databases/d1/documents/c1/doc2/c2/doc1", firestore),
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p1/databases/d1/documents/c1/doc2/c2/doc2", firestore),
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p1/databases/d1/documents/c10/doc1", firestore),
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p1/databases/dkkkkklkjnjkkk1/documents/c2/doc1", firestore),
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p2/databases/d2/documents/c1/doc1", firestore),
      Google::Cloud::Firestore::DocumentReference.from_path("projects/p2/databases/d2/documents/c1-/doc1", firestore),

      # Geopoints
      { "latitude" => -90, "longitude" => -180 },
      { "latitude" => -90, "longitude" => 0 },
      { "latitude" => -90, "longitude" => 180 },
      { "latitude" => 0,   "longitude" => -180 },
      { "latitude" => 0,   "longitude" => 0 },
      { "latitude" => 0,   "longitude" => 180 },
      { "latitude" => 1,   "longitude" => -180 },
      { "latitude" => 1,   "longitude" => 0 },
      { "latitude" => 1,   "longitude" => 180 },
      { "latitude" => 90,  "longitude" => -180 },
      { "latitude" => 90,  "longitude" => 0 },
      { "latitude" => 90,  "longitude" => 180 },

      # Arrays
      [],
      ["bar"],
      ["foo"],
      ["foo", 0],
      ["foo", 1],
      ["foo", "0"],

      # Hashes
      { "bar" => 0 },
      { "bar" => 0, "foo" => 1 },
      { "bar" => 1 },
      { "bar" => 2 },
      { "bar" => "0" },
    ]
  end

  def equality_groups
    [
      [Float::NAN, BigDecimal::NAN],
      [0, -0.0, +0.0],
      [1, 1.0],
    ]
  end

  def comparison_indexes count
    Array.new(count - 1) { |i| [i, i+1] }
  end

  def compare_values a, b
    # This is currently implemented in QueryListener::Inventory.
    # This may move in the future, but for now this location is fine.
    @inventory ||= Google::Cloud::Firestore::QueryListener::Inventory.new nil
    @inventory.send :compare_values, a, b
  end

  it "compares unequal values" do
    comparison_indexes(sorted_values.count).each do |i, j|
      compare_values(sorted_values[i], sorted_values[j]).must_equal -1
      compare_values(sorted_values[j], sorted_values[i]).must_equal  1
    end
  end

  it "compares self to be equal" do
    sorted_values.each do |value|
      compare_values(value, value).must_equal 0
    end
  end

  it "compares equal values" do
    equality_groups.each do |equality_values|
      comparison_indexes(equality_values.count).each do |i, j|
        compare_values(equality_values[i], equality_values[j]).must_equal 0
        compare_values(equality_values[j], equality_values[i]).must_equal 0
      end
    end
  end
end
