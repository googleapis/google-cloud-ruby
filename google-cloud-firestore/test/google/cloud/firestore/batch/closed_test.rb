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

describe Google::Cloud::Firestore::Batch, :closed, :mock_firestore do
  let(:batch) do
    Google::Cloud::Firestore::Batch.from_database(firestore).tap do |b|
      b.instance_variable_set :@closed, true
    end
  end
  let(:document_path) { "users/mike" }

  it "create raises when closed" do
    error = expect do
      batch.create(document_path, { name: "Mike" })
      batch.commit
    end.must_raise RuntimeError
    error.message.must_equal "batch is closed"
  end

  it "set raises when closed" do
    error = expect do
      batch.set(document_path, { name: "Mike" })
      batch.commit
    end.must_raise RuntimeError
    error.message.must_equal "batch is closed"
  end

  it "update raises when closed" do
    error = expect do
      batch.update(document_path, { name: "Mike" })
      batch.commit
    end.must_raise RuntimeError
    error.message.must_equal "batch is closed"
  end

  it "delete raises when closed" do
    error = expect do
      batch.delete document_path
      batch.commit
    end.must_raise RuntimeError
    error.message.must_equal "batch is closed"
  end

  it "get raises when closed" do
    error = expect do
      batch.get document_path
      batch.commit
    end.must_raise RuntimeError
    error.message.must_equal "batch is closed"
  end
end
