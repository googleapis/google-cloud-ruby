# Copyright 2017, Google Inc. All rights reserved.
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

describe Google::Cloud::Firestore::Snapshot, :get, :closed, :mock_firestore do
  let(:snapshot) do
    Google::Cloud::Firestore::Snapshot.from_database(firestore).tap do |b|
      b.instance_variable_set :@closed, true
    end
  end

  it "raises when getting a document (ref)" do
    doc = firestore.doc "users/mike"

    error = expect do
      snapshot.get doc
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end

  it "raises when getting a document (string)" do
    error = expect do
      snapshot.get "users/mike"
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end

  it "raises when getting a collection" do
    col = firestore.col :users

    error = expect do
      snapshot.get col
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end

  it "raises when getting a collection (string)" do
    error = expect do
      snapshot.get "users"
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end

  it "raises when getting a collection (symbol)" do
    error = expect do
      snapshot.get :users
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end

  it "raises when getting a simple query" do
    query = firestore.select(:name).from(:users)

    error = expect do
      snapshot.get query
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end

  it "raises when getting a complex query" do
    query = firestore.select(:name).from(:users).offset(3).limit(42).order(:name).order(:__name__, :desc).start_after(:foo).end_before(:bar)

    error = expect do
      snapshot.get query
    end.must_raise RuntimeError
    error.message.must_equal "snapshot is closed"
  end
end
