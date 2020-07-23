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

describe Google::Cloud::Spanner::Results, :empty_fields, :mock_spanner do
  let :results_types do
    {
      metadata: {
        row_type: {
          fields: []
        }
      }
    }
  end
  let :results_values do
    {
      values: []
    }
  end
  let(:results_enum) do
    [Google::Cloud::Spanner::V1::PartialResultSet.new(results_types)].to_enum
  end
  let(:results) { Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service }

  it "handles empty field names" do
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    fields = results.fields
    _(fields).wont_be :nil?
    _(fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(fields.types).must_equal []
    _(fields.keys).must_equal []
    _(fields.pairs).must_equal []
    _(fields.to_a).must_equal []
    _(fields.to_h).must_equal({})

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 0
  end
end
