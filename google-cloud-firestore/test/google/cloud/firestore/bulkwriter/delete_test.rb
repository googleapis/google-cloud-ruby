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

describe Google::Cloud::Firestore::BulkWriter, :delete, :mock_firestore do
  let(:bulk_writer) { firestore.bulk_writer }

  it "add a delete operation" do
    response = batch_write_pass_resp 1
    write_requests = [Google::Cloud::Firestore::Convert.write_for_delete("#{documents_path}/cities/NYC")]
    request = batch_write_args write_requests

    firestore_mock.expect :batch_write, response, request
    result = bulk_writer.delete "cities/NYC"
    bulk_writer.flush

    _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
  end

  it "retries a delete operation" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_delete("#{documents_path}/cities/NYC")]
    request = batch_write_args write_requests
    responses = [batch_write_fail_resp(1), batch_write_fail_resp(1), batch_write_pass_resp(1)]
    requests = [request] * responses.length

    stub = BatchWriteStub.new responses, requests
    firestore.service.instance_variable_set :@firestore, stub

    result = bulk_writer.delete "cities/NYC"
    bulk_writer.flush

    _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    _(stub.responses.length).must_equal 0
    _(stub.requests.length).must_equal 0
  end
end
