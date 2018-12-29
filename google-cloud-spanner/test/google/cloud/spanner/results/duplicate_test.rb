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

describe Google::Cloud::Spanner::Results, :duplicate, :mock_spanner do
  let :results_types do
    {
      metadata: {
        rowType: {
          fields: [
            { name: "num", type: { code: "INT64" } },
            { name: "str", type: { code: "INT64" } },
            { name: "num", type: { code: "STRING" } },
            { name: "str", type: { code: "STRING" } }
          ]
        }
      }
    }
  end
  let :results_values do
    {
      values: [
        { stringValue: "1" },
        { stringValue: "2" },
        { stringValue: "hello" },
        { stringValue: "world" },
        { stringValue: "3" },
        { stringValue: "4" },
        { stringValue: "hola" },
        { stringValue: "mundo" }
      ]
    }
  end
  let(:results_enum) do
    [Google::Spanner::V1::PartialResultSet.decode_json(results_types.to_json),
     Google::Spanner::V1::PartialResultSet.decode_json(results_values.to_json)].to_enum
  end
  let(:results) { Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service }

  it "handles duplicate names" do
    results.must_be_kind_of Google::Cloud::Spanner::Results

    fields = results.fields
    fields.wont_be :nil?
    fields.must_be_kind_of Google::Cloud::Spanner::Fields
    fields.types.must_equal [:INT64, :INT64, :STRING, :STRING]
    fields.keys.must_equal [:num, :str, :num, :str]
    fields.pairs.must_equal [[:num, :INT64], [:str, :INT64], [:num, :STRING], [:str, :STRING]]
    fields.to_a.must_equal [:INT64, :INT64, :STRING, :STRING]
    assert_raises Google::Cloud::Spanner::DuplicateNameError do
      fields.to_h
    end

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 2
    rows.first.to_a.must_equal [1, 2, "hello", "world"]
    rows.last.to_a.must_equal [3, 4, "hola", "mundo"]
    assert_raises Google::Cloud::Spanner::DuplicateNameError do
      rows.first.to_h
    end
    rows.first.to_h skip_dup_check: true # does not raise
    assert_raises Google::Cloud::Spanner::DuplicateNameError do
      rows.last.to_h
    end
    rows.last.to_h skip_dup_check: true # does not raise
    rows.first.pairs.must_equal [[:num, 1], [:str, 2], [:num, "hello"], [:str, "world"]]
    rows.last.pairs.must_equal [[:num, 3], [:str, 4], [:num, "hola"], [:str, "mundo"]]
  end
end
