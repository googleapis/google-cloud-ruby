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

require "firestore_helper"

describe "Batch", :firestore_acceptance do
  it "has create method" do
    rand_batch_col = firestore.col "#{root_path}/batch/#{SecureRandom.hex(4)}"
    doc_ref = rand_batch_col.doc
    doc_ref.get.wont_be :exists?

    firestore.batch do |b|
      b.create doc_ref, foo: "bar"
    end

    doc_snp = doc_ref.get
    doc_snp.must_be :exists?
    doc_snp[:foo].must_equal "bar"
  end

  it "has set method" do
    rand_batch_col = firestore.col "#{root_path}/batch/#{SecureRandom.hex(4)}"
    doc_ref = rand_batch_col.add foo: "bar"

    firestore.batch do |b|
      b.set doc_ref, foo: "baz"
    end

    doc_ref.get[:foo].must_equal "baz"
  end

  it "has update method" do
    rand_batch_col = firestore.col "#{root_path}/batch/#{SecureRandom.hex(4)}"
    doc_ref = rand_batch_col.add foo: "bar"

    firestore.batch do |b|
      b.update doc_ref, foo: "baz"
    end

    doc_ref.get[:foo].must_equal "baz"
  end

  it "enforces that updated document exists" do
    rand_batch_col = firestore.col "#{root_path}/batch/#{SecureRandom.hex(4)}"
    doc_ref = rand_batch_col.doc
    doc_ref.get.wont_be :exists?

    expect do
      firestore.batch do |b|
        b.update doc_ref, foo: "baz"
      end
    end.must_raise Google::Cloud::NotFoundError
  end

  it "has delete method" do
    rand_batch_col = firestore.col "#{root_path}/batch/#{SecureRandom.hex(4)}"
    doc_ref = rand_batch_col.doc
    doc_ref.create({foo: "bar"})

    firestore.batch do |b|
      b.delete doc_ref
    end

    doc_ref.get.wont_be :exists?
  end
end
