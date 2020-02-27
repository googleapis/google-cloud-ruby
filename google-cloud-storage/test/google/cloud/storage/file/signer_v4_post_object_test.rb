# Copyright 2020 Google LLC
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
require "json"
require_relative "../../../../../conformance/v1/proto/google/cloud/conformance/storage/v1/tests_pb.rb"

class SignerV4PostObjectTest < MockStorage
  def setup
    account_file_path = File.expand_path "../../../../../conformance/v1/test_service_account.not-a-test.json", __dir__
    account = JSON.parse File.read(account_file_path)
    credentials.issuer = account["client_email"]
    credentials.signing_key = OpenSSL::PKey::RSA.new account["private_key"]
    @test_data = nil # not thread safe
  end

  def teardown
    if !passed? && @test_data
      puts "\ntest_#{@test_data[0]}_#{@test_data[1]}: #{@test_data[2]}:\n"
      puts "policyOutput\n\nexpectedDecodedPolicy:\n\n#{@test_data[3]}\n\n"
      puts "policyOutput\n\nexpectedPolicy:\n\n#{Base64.strict_encode64(@test_data[3])}\n\n"
    end
  end

  def self.signer_v4_test_for description, input, output, index
    define_method("test_signer_v4_#{index}: #{description}") do
      @test_data = ["signer_v4", index, description, output.expectedDecodedPolicy]
      signer = Google::Cloud::Storage::File::SignerV4.new input.bucket, input.object, storage.service
      Time.stub :now, timestamp_to_time(input.timestamp) do
        # sut
        signed_url = signer.signed_url method: "POST", expires: input.expiration

        signed_url.must_equal output.url
      end
    end
  end

  def self.project_test_for description, input, output, index
    define_method("test_project_#{index}: #{description}") do
    @test_data = ["project", index, description, output.expectedDecodedPolicy]
      Time.stub :now, timestamp_to_time(input.timestamp) do
        # sut
        signed_url = storage.signed_url input.bucket, input.object, method: "POST", expires: input.expiration, version: :v4

        signed_url.must_equal output.url
      end
    end
  end

  def self.bucket_test_for description, input, output, index
    return unless [4].include? index
    focus
    define_method("test_bucket_#{index}: #{description}") do
    @test_data = ["bucket", index, description, output.expectedDecodedPolicy]
      bucket_gapi = Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(input.bucket).to_json
      bucket = Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service

      Time.stub :now, timestamp_to_time(input.timestamp) do
        # sut
        post_object = bucket.post_object input.object, issuer: credentials.issuer,
                                                       expires: input.expiration,
                                                       conditions: {"success_action_status" => input.conditions.successActionStatus},
                                                       version: :v4

        post_object.url.must_equal output.url
        post_object.fields["key"].must_equal output.fields["key"]
        post_object.fields["x-goog-algorithm"].must_equal output.fields["x-goog-algorithm"]
        post_object.fields["x-goog-credential"].must_equal output.fields["x-goog-credential"]
        post_object.fields["x-goog-date"].must_equal output.fields["x-goog-date"]
        post_object.fields["policy"].must_equal output.fields["policy"]
        post_object.fields["x-goog-signature"].must_equal output.fields["x-goog-signature"]
      end
    end
  end

  def self.file_test_for description, input, output, index
    define_method("test_file_#{index}: #{description}") do
    @test_data = ["file", index, description, output.expectedDecodedPolicy]
      bucket_gapi = Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(input.bucket).to_json
      bucket = Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service
      file_gapi = Google::Apis::StorageV1::Object.from_json random_file_hash(input.bucket, input.object).to_json
      file = Google::Cloud::Storage::File.from_gapi file_gapi, storage.service
      Time.stub :now, timestamp_to_time(input.timestamp) do
        # sut
        signed_url = file.signed_url method: "POST", expires: input.expiration, version: :v4

        signed_url.must_equal output.url
      end
    end
  end

  def timestamp_to_time timestamp
    ::Time.at(timestamp.nanos * 10**-9 + timestamp.seconds)
  end
end

file_path = File.expand_path "../../../../../conformance/v1/v4_signatures.json", __dir__
test_file = Google::Cloud::Conformance::Storage::V1::TestFile.decode_json File.read(file_path)
test_file.post_policy_v4_tests.each_with_index do |test, index|
  SignerV4PostObjectTest.signer_v4_test_for test.description, test.policyInput, test.policyOutput, index
  SignerV4PostObjectTest.project_test_for test.description, test.policyInput, test.policyOutput, index
  SignerV4PostObjectTest.bucket_test_for test.description, test.policyInput, test.policyOutput, index
  SignerV4PostObjectTest.file_test_for test.description, test.policyInput, test.policyOutput, index
end
