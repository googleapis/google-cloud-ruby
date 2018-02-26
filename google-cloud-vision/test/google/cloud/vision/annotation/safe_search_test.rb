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

describe Google::Cloud::Vision::Annotation::SafeSearch, :mock_vision do
  # Run through JSON to turn all keys to strings...
  let(:grpc) { safe_search_annotation_response }
  let(:safe_search) { Google::Cloud::Vision::Annotation::SafeSearch.from_grpc grpc }

  it "knows the given attributes" do
    safe_search.wont_be :nil?

    safe_search.wont_be :adult?
    safe_search.wont_be :spoof?
    safe_search.must_be :medical?
    safe_search.must_be :violence?

    safe_search.adult.must_equal :VERY_UNLIKELY
    safe_search.spoof.must_equal :UNLIKELY
    safe_search.medical.must_equal :POSSIBLE
    safe_search.violence.must_equal :LIKELY
  end

  it "can convert to a hash" do
    hash = safe_search.to_h
    hash.must_be_kind_of Hash
    hash[:adult].must_equal false
    hash[:spoof].must_equal false
    hash[:medical].must_equal true
    hash[:violence].must_equal true
  end

  it "can convert to a string" do
    safe_search.to_s.must_equal "(adult?: false, spoof?: false, medical?: true, violence?: true)"
    safe_search.inspect.must_include safe_search.to_s
  end
end
