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

describe Google::Cloud::Firestore::Promise::Future, :mock_firestore do
  it "correctly provides the status" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests
    responses_pass = [batch_write_pass_resp(1)]
    responses_fail = [batch_write_fail_resp(1)]
    requests = [request]

    bw = firestore.bulk_writer retries: 1

    stub = BatchWriteStub.new responses_pass, requests, 0.1
    firestore.service.instance_variable_set :@firestore, stub
    result_1 = bw.create "cities/NYC", { foo: "bar"}
    _(result_1.fulfilled?).must_equal false
    result_1.wait!
    _(result_1.fulfilled?).must_equal true

    bw.flush

    stub = BatchWriteStub.new responses_fail, requests, 0.1
    firestore.service.instance_variable_set :@firestore, stub
    result_2 = bw.create "cities/NYC", { foo: "bar"}
    _(result_2.rejected?).must_equal false
    bw.flush
    result_2.wait!
    puts result_2.rejected?
    _(result_2.rejected?).must_equal true

    bw.close
  end

  it "waits for the future to resolve" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests
    responses_pass = [batch_write_pass_resp(1)]
    requests = [request]

    bw = firestore.bulk_writer retries: 1

    stub = BatchWriteStub.new responses_pass, requests, 0.1
    firestore.service.instance_variable_set :@firestore, stub
    result_1 = bw.create "cities/NYC", { foo: "bar"}

    result_1.wait!

    _(result_1.fulfilled?).must_equal true

    bw.close
  end

  it "correctly returns the value if fulfilled" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests
    responses_pass = [batch_write_pass_resp(1)]
    requests = [request]
    stub = BatchWriteStub.new responses_pass, requests, 0.1

    bw = firestore.bulk_writer retries: 1

    firestore.service.instance_variable_set :@firestore, stub
    result_1 = bw.create "cities/NYC", { foo: "bar"}

    bw.close

    _(result_1.value).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
  end

  it "correctly returns the rejected reason" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests
    responses_fail = [batch_write_fail_resp(1)]
    requests = [request]
    stub = BatchWriteStub.new responses_fail, requests, 0.1

    bw = firestore.bulk_writer retries: 1

    firestore.service.instance_variable_set :@firestore, stub
    result_1 = bw.create "cities/NYC", { foo: "bar"}

    bw.close

    _(result_1.reason).must_be_kind_of Google::Cloud::Firestore::BulkWriterException
  end

  it "successfully adds callback on fulfillment" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests
    responses_pass = [batch_write_pass_resp(1)]
    requests = [request]
    stub = BatchWriteStub.new responses_pass, requests, 0.1

    bw = firestore.bulk_writer retries: 1

    firestore.service.instance_variable_set :@firestore, stub
    results = []
    result_1 = bw.create "cities/NYC", { foo: "bar"}
    future = result_1.then do |value|
      results << value
    end

    bw.close
    future.wait!

    _(results.first).must_be_kind_of Google::Cloud::Firestore::BulkWriterOperation::WriteResult
  end

  it "successfully adds callback on rejection" do
    write_requests = [Google::Cloud::Firestore::Convert.write_for_create("#{documents_path}/cities/NYC", { foo: "bar"})]
    request = batch_write_args write_requests
    responses_fail = [batch_write_fail_resp(1)]
    requests = [request]
    stub = BatchWriteStub.new responses_fail, requests, 0.1

    bw = firestore.bulk_writer retries: 1

    firestore.service.instance_variable_set :@firestore, stub
    reasons = []
    result_1 = bw.create "cities/NYC", { foo: "bar"}
    future = result_1.rescue do |reason|
      reasons << reason
    end

    bw.close
    future.wait!

    _(reasons.first).must_be_kind_of Google::Cloud::Firestore::BulkWriterException
  end
end
