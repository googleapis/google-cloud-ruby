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

describe Google::Cloud::Spanner::Results, :duplicate_struct, :mock_spanner do
  let :results_hash do
    {"metadata"=>
      {"rowType"=>
        {"fields"=>
          [{"type"=>
             {"code"=>"ARRAY",
              "arrayElementType"=>
               {"code"=>"STRUCT",
                "structType"=>
                 {"fields"=>
                   [{"name"=>"num", "type"=>{"code"=>"INT64"}},
                    {"name"=>"num", "type"=>{"code"=>"INT64"}}]}}}}]}},
     "values"=>
      [{"listValue"=>
         {"values"=>
           [{"listValue"=>
              {"values"=>[{"stringValue"=>"1"}, {"stringValue"=>"2"}]}}]}}]}
  end
  let(:results_enum) do
    [Google::Spanner::V1::PartialResultSet.decode_json(results_hash.to_json)].to_enum
  end
  let(:results) { Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service }

  it "handles duplicate structs" do
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.must_equal [0]
    results.fields.pairs.must_equal [[0, [Google::Cloud::Spanner::Fields.new([[:num, :INT64], [:num, :INT64]])]]]
    assert_raises Google::Cloud::Spanner::DuplicateNameError do
      results.fields.to_a
    end
    assert_raises Google::Cloud::Spanner::DuplicateNameError do
      results.fields.to_h
    end

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [0]
    row.values.must_equal [[Google::Cloud::Spanner::Fields.new([[:num, :INT64], [:num, :INT64]]).new([1, 2])]]
    row.pairs.must_equal [[0, [Google::Cloud::Spanner::Fields.new([[:num, :INT64], [:num, :INT64]]).new([1, 2])]]]
    assert_raises Google::Cloud::Spanner::DuplicateNameError do
      row.to_a
    end
    assert_raises Google::Cloud::Spanner::DuplicateNameError do
      row.to_h
    end
  end
end
