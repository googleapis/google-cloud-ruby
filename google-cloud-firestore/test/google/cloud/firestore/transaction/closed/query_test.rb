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

describe Google::Cloud::Firestore::Transaction, :query, :closed, :mock_firestore do
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_client(firestore).tap do |b|
      b.instance_variable_set :@closed, true
    end
  end

  it "raises when running a query" do
    error = expect do
      query = firestore.col(:users).select(:name)
      transaction.run query
    end.must_raise RuntimeError
    error.message.must_equal "transaction is closed"
  end
end
