# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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
      { rowType:
        { fields:
          [{ type:
             { code: :ARRAY,
               arrayElementType:
               { code: :STRUCT,
                 structType:
                 { fields:
                   [{ name: "name", type: { code: "STRING"}},
                    { name: "numbers", type: { code: :ARRAY, arrayElementType: { code: :INT64 }}},
                    { name: "strings", type: { code: :ARRAY, arrayElementType: { code: :STRING }}}] }}}}] }},
    }
  end
  let :results_values1 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ stringValue: "foo"},
                 { listValue:
                   { values:
                     [{ stringValue: "111"},
                      { stringValue: "222"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values2 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ listValue:
                   { values:
                     [{ stringValue: "333"}] }},
                 { listValue:
                   { values:
                     [{ stringValue: "foo"},
                      { stringValue: "bar"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values3 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ listValue:
                   { values:
                     [{ stringValue: "baz"}] }}] }},
            { listValue:
              { values:
                [{ stringValue: "bar"},
                 { listValue:
                   { values:
                     [{ stringValue: "444"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values4 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                 [{ listValue:
                    { values:
                      [{ stringValue: "555"},
                       { stringValue: "666"}] }},
                  { listValue:
                    { values:
                      [{ stringValue: "foo"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values5 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ listValue:
                   { values:
                     [{ stringValue: "bar"},
                      { stringValue: "baz"}] }}] }},
            { listValue:
              { values:
                [{ stringValue: "baz"},
                 { listValue:
                   { values:
                     [{ stringValue: "777"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values6 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ listValue:
                   { values:
                     [{ stringValue: "888"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values7 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ listValue:
                   { values:
                     [{ stringValue: "999"}] }},
                 { listValue:
                   { values:
                     [{ stringValue: "foo"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values8 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ listValue:
                   { values:
                     [{ stringValue: "bar"}] }}] }}
      ] }}],
    chunkedValue: true }
  end
  let :results_values9 do
    { values:
      [{ listValue:
         { values:
           [{ listValue:
              { values:
                [{ listValue:
                   { values:
                     [{ stringValue: "baz"}] }}] }}
      ] }}] }
  end
  let(:results_enum) do
    [Google::Spanner::V1::PartialResultSet.decode_json(results_metadata.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values1.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values2.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values3.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values4.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values5.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values6.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values7.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values8.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values9.to_json)].to_enum
  end
  let(:results) { Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service }

  it "handles nested structs" do
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.must_equal [0]
    results.fields.to_a.must_equal [[{ name: :STRING, numbers: [:INT64], strings: [:STRING] }]]
    results.fields.to_h.must_equal({ 0 => [{ name: :STRING, numbers: [:INT64], strings: [:STRING] }] })

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [0]
    row.to_a.must_equal [[{ name: "foo", numbers: [111, 222333], strings: ["foo", "barbaz"] },
                          { name: "bar", numbers: [444555, 666], strings: ["foobar", "baz"] },
                          { name: "baz", numbers: [777888999], strings: ["foobarbaz"] }]]
    row.to_h.must_equal({ 0 => [{ name: "foo", numbers: [111, 222333], strings: ["foo", "barbaz"] },
                                { name: "bar", numbers: [444555, 666], strings: ["foobar", "baz"] },
                                { name: "baz", numbers: [777888999], strings: ["foobarbaz"] }] })
  end
end
