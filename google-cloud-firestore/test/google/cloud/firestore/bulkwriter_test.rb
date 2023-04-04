# Copyright 2023 Google LLC
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
require "concurrent"

describe Google::Cloud::Firestore::BulkWriter, :mock_firestore do
  let(:bulk_writer) { firestore.bulk_writer }

  it "can't add multiple mutations to same doc" do
    response = batch_write_resp 1
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests

    firestore_mock.expect :batch_write, response, request
    bulk_writer.create "cities/NYC", { foo: "bar"}
    error = assert_raises StandardError do
      bulk_writer.create "cities/NYC", { foo: "bar"}
    end
    _(error.message).must_equal "BulkWriter already contains mutations for this document"

    bulk_writer.flush
  end

  it "can add multiple mutations to same doc after flush" do
    response = batch_write_resp 1
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests

    firestore_mock.expect :batch_write, response, request
    result = bulk_writer.create "cities/NYC", { foo: "bar"}
    bulk_writer.flush

    firestore_mock.expect :batch_write, response, request
    result_1 = bulk_writer.create "cities/NYC", { foo: "bar"}
    bulk_writer.flush

    _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    _(result_1.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
  end

  it "cannot add operations after bulkwriter is closed" do
    bw = firestore.bulk_writer
    bw.close

    error = assert_raises StandardError do
      bw.create "cities/NYC", { foo: "bar"}
    end
    _(error.message).must_equal "BulkWriter not accepting responses for now. Either closed or in flush state"
  end

  focus; it "cannot add operations when bulk writer is in closed state" do
    bw = firestore.bulk_writer

    puts batch_write_fail_resp 1

    bw.create "cities/NYC", { foo: "bar"}

    Concurrent::Promises.future do
      bw.flush
    end

    sleep 1
    error = assert_raises StandardError do
      bw.create "cities/NYC", { foo: "bar"}
    end
    _(error.message).must_equal "BulkWriter not accepting responses for now. Either closed or in flush state"
  end

end
