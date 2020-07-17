# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Results, :deeply_nested_list, :mock_spanner do
  let :results_metadata do
    { metadata:
      { row_type:
        { fields:
          [{ type:
             { code: :ARRAY,
               array_element_type:
               { code: :STRUCT,
                 struct_type:
                 { fields:
                   [{ name: "name", type: { code: :STRING}},
                    { name: "numbers", type: { code: :ARRAY, array_element_type: { code: :INT64 }}},
                    { name: "strings", type: { code: :ARRAY, array_element_type: { code: :STRING }}}] }}}}] }},
    }
  end
  let :results_values1 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ string_value: "foo"},
                 { list_value:
                   { values:
                     [{ string_value: "111"},
                      { string_value: "222"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values2 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ list_value:
                   { values:
                     [{ string_value: "333"}] }},
                 { list_value:
                   { values:
                     [{ string_value: "foo"},
                      { string_value: "bar"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values3 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ list_value:
                   { values:
                     [{ string_value: "baz"}] }}] }},
            { list_value:
              { values:
                [{ string_value: "bar"},
                 { list_value:
                   { values:
                     [{ string_value: "444"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values4 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                 [{ list_value:
                    { values:
                      [{ string_value: "555"},
                       { string_value: "666"}] }},
                  { list_value:
                    { values:
                      [{ string_value: "foo"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values5 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ list_value:
                   { values:
                     [{ string_value: "bar"},
                      { string_value: "baz"}] }}] }},
            { list_value:
              { values:
                [{ string_value: "baz"},
                 { list_value:
                   { values:
                     [{ string_value: "777"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values6 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ list_value:
                   { values:
                     [{ string_value: "888"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values7 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ list_value:
                   { values:
                     [{ string_value: "999"}] }},
                 { list_value:
                   { values:
                     [{ string_value: "foo"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values8 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ list_value:
                   { values:
                     [{ string_value: "bar"}] }}] }}
      ] }}],
    chunked_value: true }
  end
  let :results_values9 do
    { values:
      [{ list_value:
         { values:
           [{ list_value:
              { values:
                [{ list_value:
                   { values:
                     [{ string_value: "baz"}] }}] }}
      ] }}] }
  end
  let(:results_enum) do
    [Google::Cloud::Spanner::V1::PartialResultSet.new(results_metadata),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values1),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values2),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values3),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values4),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values5),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values6),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values7),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values8),
     Google::Cloud::Spanner::V1::PartialResultSet.new(results_values9)].to_enum
  end
  let(:results) { Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service }

  it "handles nested structs" do
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys).must_equal [0]
    _(results.fields.to_a).must_equal [[Google::Cloud::Spanner::Fields.new({ name: :STRING, numbers: [:INT64], strings: [:STRING] })]]
    _(results.fields.to_h).must_equal({ 0 => [Google::Cloud::Spanner::Fields.new({ name: :STRING, numbers: [:INT64], strings: [:STRING] })] })

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [0]
    _(row.to_a).must_equal [[{ name: "foo", numbers: [111, 222333], strings: ["foo", "barbaz"] },
                          { name: "bar", numbers: [444555, 666], strings: ["foobar", "baz"] },
                          { name: "baz", numbers: [777888999], strings: ["foobarbaz"] }]]
    _(row.to_h).must_equal({ 0 => [{ name: "foo", numbers: [111, 222333], strings: ["foo", "barbaz"] },
                                { name: "bar", numbers: [444555, 666], strings: ["foobar", "baz"] },
                                { name: "baz", numbers: [777888999], strings: ["foobarbaz"] }] })
  end
end
