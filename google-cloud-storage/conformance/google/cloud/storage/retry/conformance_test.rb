# Copyright 2022 Google LLC
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
require "net/http"
require "v1/proto/google/cloud/conformance/storage/v1/tests_pb"
require_relative "utils"

class ConformanceTest < MockStorage

  HOST = "http://localhost:9000/"

  def setup
    storage.service.service.root_url = HOST
    create_resources
  end

  def create_resources
    @bucket = storage.create_bucket random_bucket_name, acl: acl,
                                    default_acl: acl
    @hmac_key = storage.create_hmac_key storage.service_account_email
    @hmac_key.inactive!
    @notification = storage.service.insert_notification @bucket.name, pubsub_topic_name
    @object = @bucket.create_file file_obj, file_name
  end

  def self.run_tests test
    # Run test for each case
    test.cases.each do |c|
      # Run test for each method
      test["methods"].each_with_index do |method, index|
        test_name = [test.id, c.instructions, method.name, index].join("-")
        define_method(test_name) do
          run_test_case test, c.instructions
        end
      end
    end
  end

  def self.run_test_case test_name, scenario, instructions, method, lib_func
    define_method("test_#{test_name}") do
      expect_success = scenario.expectSuccess

      response = create_retry_test method.name, instructions
      test_id = JSON.parse(response.body)["id"]

      success_result = true
      begin
        run_retry_test test_id, lib_func, scenario.preconditionProvided, method.resources
      rescue => e
        success_result = false
      end

      assert_equal expect_success, success_result

      # Verify that all instructions were used up during the test
      # (indicates that the client sent the correct requests).
      status_response = get_retry_test test_id
      status_response_body = JSON.parse(status_response.body)
      assert_equal status_response_body["completed"], true

      # Clean up and close out test in testbench.
      delete_resources
      delete_retry_test test_id
    end

    def delete_resources
      storage.service.delete_hmac_key @hmac_key.access_id rescue nil
      files = @bucket.files rescue []
      files.each { |f| f.delete rescue nil }
      @bucket.delete rescue nil
    end
  end

###############################################################################
### Helper Methods for Testbench Retry Test API ###############################
###############################################################################

##
# The Retry Test API in the testbench is used to run the retry conformance tests.
# It offers a mechanism to describe more complex retry scenarios while sending
# a single, constant header through all the HTTP requests from a test program.
# The Retry Test API can be accessed by adding the path "/retry-test" to the host.
# See also: https://github.com/googleapis/storage-testbench
##

  # For each test case, initialize a Retry Test resource by loading a set of
  # instructions to the testbench host.
  # The instructions include an API method and a list of errors. An unique id
  # is created for each Retry Test resource.
  def create_retry_test method_name, instructions
    retry_test_uri = HOST + "retry_test"
    uri = URI.parse retry_test_uri
    headers = {"Content-Type" => "application/json"}
    data = {"instructions" => {method_name => instructions.to_a}}.to_json
    http = Net::HTTP.new uri.host, uri.port
    request = Net::HTTP::Post.new uri.request_uri, headers
    request.body = data
    http.request request
  end

  # Retrieve the state of the Retry Test resource, including the unique id,
  # instructions, and a boolean status "completed". This can be used to verify
  # if all instructions were used as expected.
  def get_retry_test id
    url = HOST + "retry_test/#{id}"
    uri = URI.parse url
    http = Net::HTTP.new uri.host, uri.port
    request = Net::HTTP::Get.new uri
    http.request request
  end

  # To execute tests against the list of instrucions sent to the Retry Test API,
  # create a client to send the retry test ID using the x-retry-test-id header
  # in each request. For incoming requests that match the test ID and API method,
  # the testbench will pop off the next instruction from the list and force the
  # listed failure case.
  def run_retry_test id, lib_func, preconditions, resources
    storage.service.service.request_options.header["x-retry-test-id"] = id
    MethodMapping.send(lib_func, storage.service, preconditions, 
                       bucket: @bucket, hmac_key: @hmac_key,
                       notification: @notification, object: @object)
  end

  # Delete the Retry Test resource by id.
  def delete_retry_test id
    uri = URI(HOST + "/retry_test/#{id}")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Delete.new(uri.path)
    http.request(req)
  end
end

file_path = File.expand_path "../../../../../conformance/v1/retry_tests.json", __dir__
test_file = Google::Cloud::Conformance::Storage::V1::RetryTests.decode_json File.read(file_path)
test_file.retryTests.each do |test|
  # Run test for each case
  test.cases.each do |c|
    # Run test for each method
    test["methods"].each do |method|
      method_name = method.name
      if MethodMapping.get[method_name].nil?
        puts "No tests for operation #{method_name}"
        next
      end

      MethodMapping.get[method_name].each_with_index do |lib_func, index|
        instructions = c.instructions.join("_")
        test_name = [test.id, instructions, method_name, index].join("-")
        ConformanceTest.run_test_case test_name, test, c.instructions, method, lib_func
      end
    end
  end
end
