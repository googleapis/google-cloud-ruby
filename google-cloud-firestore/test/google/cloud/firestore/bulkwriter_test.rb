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
require "google/cloud/firestore/errors"

describe Google::Cloud::Firestore::BulkWriter, :mock_firestore do
  let(:bulk_writer) { firestore.bulk_writer }

  it "can't add multiple mutations to same doc" do
    response = batch_write_pass_resp 1
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests

    firestore_mock.expect :batch_write, response, request
    bulk_writer.create "cities/NYC", { foo: "bar"}
    error = assert_raises Google::Cloud::Firestore::BulkWriterError do
      bulk_writer.create "cities/NYC", { foo: "bar"}
    end
    _(error.message).must_equal "BulkWriterError : Already contains mutations for this document"

    bulk_writer.flush
  end

  it "can add multiple mutations to same doc after flush" do
    response = batch_write_pass_resp 1
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

    error = assert_raises Google::Cloud::Firestore::BulkWriterError do
      bw.create "cities/NYC", { foo: "bar"}
    end
    _(error.message).must_equal "BulkWriterError : Not accepting responses for now. Either closed or in flush state"
  end

  it "cannot add operations when bulk writer is in closed state" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests
    responses = [batch_write_fail_resp(1), batch_write_pass_resp(1)]
    requests = [request] * responses.length
    stub = BatchWriteStub.new responses, requests
    firestore.service.instance_variable_set :@firestore, stub

    bw = firestore.bulk_writer

    bw.create "cities/NYC", { foo: "bar"}

    Concurrent::Promises.future do
      bw.flush
    end

    sleep 0.1
    error = assert_raises Google::Cloud::Firestore::BulkWriterError do
      bw.create "cities/NYC", { foo: "bar"}
    end
    _(error.message).must_equal "BulkWriterError : Not accepting responses for now. Either closed or in flush state"
  end

  describe "retry tests" do
    it "do not exceed the max retry attempts" do
      write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
      request = batch_write_args write_requests
      responses = [batch_write_fail_resp(1), batch_write_fail_resp(1), batch_write_fail_resp(1), batch_write_pass_resp(1)]
      requests = [request] * responses.length
      stub = BatchWriteStub.new responses, requests
      firestore.service.instance_variable_set :@firestore, stub

      bw = firestore.bulk_writer retries: 2

      result = bw.create "cities/NYC", { foo: "bar"}
      bw.flush
      bw.close

      assert_raises Google::Cloud::Firestore::BulkWriterException do
        result.wait!
      end
      _(result.rejected?).must_equal true
      _(result.reason).must_be_kind_of Google::Cloud::Firestore::BulkWriterException
      _(result.reason.status).must_equal 1
      _(result.reason.message).must_equal "Mock rejection"
      _(stub.responses.length).must_equal 2
      _(stub.requests.length).must_equal 2
    end

    it "retry operation in case of BulkCommitError" do
      write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
      request = batch_write_args write_requests
      responses = [nil, batch_write_pass_resp(1)]
      requests = [request] * responses.length
      stub = BatchWriteStub.new responses, requests
      firestore.service.instance_variable_set :@firestore, stub

      bw = firestore.bulk_writer

      result = bw.create "cities/NYC", { foo: "bar"}
      bw.flush
      bw.close

      _(result.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(stub.responses.length).must_equal 0
      _(stub.requests.length).must_equal 0
    end

    it "retry operations only after retry time" do
      request_1 = batch_write_args [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
      request_2 = batch_write_args [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/MTV", { foo: "bar"})]
      responses = [batch_write_fail_resp(1), batch_write_fail_resp(1), batch_write_pass_resp(1), batch_write_pass_resp(1)]
      requests = [request_1, request_2, request_1, request_2]
      stub = BatchWriteStub.new responses, requests
      firestore.service.instance_variable_set :@firestore, stub

      bw = firestore.bulk_writer

      result_1 = bw.create "cities/NYC", { foo: "bar"}
      sleep 0.1
      result_2 = bw.create "cities/MTV", { foo: "bar"}
      bw.flush
      bw.close

      _(result_1.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(result_2.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(stub.responses.length).must_equal 0
      _(stub.requests.length).must_equal 0
    end

    it "retry only the failed operation of a batch" do
      write_1 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})
      write_2 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/MTV", { foo: "bar"})
      request_1 = batch_write_args [write_1, write_2]
      request_2 = batch_write_args [write_2]
      responses = [batch_write_mix_resp(2), batch_write_pass_resp(1)]
      requests = [request_1, request_2]
      stub = BatchWriteStub.new responses, requests
      firestore.service.instance_variable_set :@firestore, stub

      bw = firestore.bulk_writer

      result_1 = bw.create "cities/NYC", { foo: "bar"}
      result_2 = bw.create "cities/MTV", { foo: "bar"}
      bw.flush
      bw.close

      _(result_1.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(result_2.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(stub.responses.length).must_equal 0
      _(stub.requests.length).must_equal 0
    end

    it "retry operations in correct order" do
      write_1 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})
      write_2 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/MTV", { foo: "bar"})
      request_1 = batch_write_args [write_1]
      request_2 = batch_write_args [write_2]
      responses = [batch_write_fail_resp(1), batch_write_fail_resp(1), batch_write_fail_resp(1), batch_write_pass_resp(1), batch_write_pass_resp(1)]
      requests = [request_1, request_1, request_2, request_2, request_1]
      stub = BatchWriteStub.new responses, requests
      firestore.service.instance_variable_set :@firestore, stub

      bw = firestore.bulk_writer

      result_1 = bw.create "cities/NYC", { foo: "bar"}
      sleep 1.5
      result_2 = bw.create "cities/MTV", { foo: "bar"}
      bw.flush
      bw.close

      _(result_1.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(result_2.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(stub.responses.length).must_equal 0
      _(stub.requests.length).must_equal 0
    end
  end

  describe "thread tests" do

    it "request threads tests" do
      write_1 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})
      write_2 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/MTV", { foo: "bar"})
      write_3 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/KIR", { foo: "bar"})
      requests = [batch_write_args([write_1, write_2, write_3])]
      responses = [batch_write_pass_resp(3)]
      stub = BatchWriteStub.new responses, requests, 1
      firestore.service.instance_variable_set :@firestore, stub

      thread_count = Thread.list.count
      bw = firestore.bulk_writer request_threads: 1, batch_threads: 2

      result_1 = bw.create "cities/NYC", { foo: "bar"}
      result_2 = bw.create "cities/MTV", { foo: "bar"}
      result_3 = bw.create "cities/KIR", { foo: "bar"}
      sleep 0.1
      thread_count_2 = Thread.list.count
      bw.flush
      bw.close

      _(thread_count_2 - thread_count).must_be :<=, 3
      _(result_1.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(result_2.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(result_3.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
      _(stub.responses.length).must_equal 0
      _(stub.requests.length).must_equal 0
    end

    it "batch threads tests" do
      stub = BatchWriteStub.new [], [], 1
      firestore.service.instance_variable_set :@firestore, stub

      thread_count = Thread.list.count
      bw = firestore.bulk_writer batch_threads: 3, request_threads: 1, retries: 1

      (1..100).each do
        bw.create "cities/#{SecureRandom.hex(4)}", { foo: "bar"}
      end
      sleep 0.3
      thread_count_2 = Thread.list.count
      bw.flush
      bw.close

      _(thread_count_2 - thread_count).must_be :<=, 4
    end
  end

  it "marks operation complete incase of BulkWriterOperationError when mutation was failure" do
    write_1 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})
    write_2 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/MTV", { foo: "bar"})
    request_1 = batch_write_args [write_1, write_2]
    response_1 = OpenStruct.new({
                                  write_results: [Google::Cloud::Firestore::V1::WriteResult.new]*2,
                                  status: [nil, Google::Rpc::Status.new]
                                })
    responses = [response_1]
    requests = [request_1]
    stub = BatchWriteStub.new responses, requests
    firestore.service.instance_variable_set :@firestore, stub

    bw = firestore.bulk_writer retries: 1

    result_1 = bw.create "cities/NYC", { foo: "bar"}
    result_2 = bw.create "cities/MTV", { foo: "bar"}
    bw.flush
    bw.close


    assert_nil result_1.value
    _(result_2.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    _(stub.responses.length).must_equal 0
    _(stub.requests.length).must_equal 0
  end

  it "marks operation complete incase of BulkWriterOperationError when mutation was success" do
    write_1 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})
    write_2 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/MTV", { foo: "bar"})
    request_1 = batch_write_args [write_1, write_2]
    response_1 = OpenStruct.new({
                                  write_results: [nil, Google::Cloud::Firestore::V1::WriteResult.new],
                                  status: [Google::Rpc::Status.new]*2
                                })
    responses = [response_1]
    requests = [request_1]
    stub = BatchWriteStub.new responses, requests
    firestore.service.instance_variable_set :@firestore, stub

    bw = firestore.bulk_writer retries: 1

    result_1 = bw.create "cities/NYC", { foo: "bar"}
    result_2 = bw.create "cities/MTV", { foo: "bar"}
    bw.flush
    bw.close


    assert_nil result_1.value
    _(result_2.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    _(stub.responses.length).must_equal 0
    _(stub.requests.length).must_equal 0
  end

  it "parses all responses incase of error " do
    write_1 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})
    write_2 = Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/MTV", { foo: "bar"})
    request_1 = batch_write_args [write_1, write_2]
    response_1 = OpenStruct.new({
                                  write_results: [nil, Google::Cloud::Firestore::V1::WriteResult.new],
                                  status: [Google::Rpc::Status.new]*2
                                })
    responses = [response_1]
    requests = [request_1]
    stub = BatchWriteStub.new responses, requests
    firestore.service.instance_variable_set :@firestore, stub

    bw = firestore.bulk_writer

    result_1 = bw.create "cities/NYC", { foo: "bar"}
    result_2 = bw.create "cities/MTV", { foo: "bar"}
    bw.flush
    bw.close


    assert_nil result_1.value
    _(result_2.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
    _(stub.responses.length).must_equal 0
    _(stub.requests.length).must_equal 0
  end


end
