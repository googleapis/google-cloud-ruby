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
require_relative "../../../../../../conformance/v1/proto/google/cloud/conformance/storage/v1/tests_pb"

class PostObjectConformanceTest < MockStorage
  def setup
    account_file_path = File.expand_path "../../../../../../conformance/v1/test_service_account.not-a-test.json", __dir__
    account = JSON.parse File.read(account_file_path)
    credentials.issuer = account["client_email"]
    credentials.signing_key = OpenSSL::PKey::RSA.new account["private_key"]
    @test_data = nil # not thread safe
  end

  def teardown
    if !passed? && @test_data
      puts "\ntest_#{@test_data[0]}_#{@test_data[1]}: #{@test_data[2]}:\n"
      puts "policyOutput\n\nexpectedDecodedPolicy:\n\n#{@test_data[3]}\n\n"
    end
  end

  def self.signer_v4_test_for description, input, output, index
    define_method("test_signer_v4_#{index}: #{description}") do
      @test_data = ["signer_v4", index, description, output.expectedDecodedPolicy]
      signer = Google::Cloud::Storage::File::SignerV4.new input.bucket, input.object, storage.service
      bucket_bound_hostname = input.bucketBoundHostname unless input.bucketBoundHostname&.empty?
      fields = fields_hash input.fields

      Time.stub :now, timestamp_to_time(input.timestamp) do
        # sut
        post_object = signer.post_object issuer: credentials.issuer,
                                         expires: input.expiration,
                                         fields: fields,
                                         conditions: conditions_array(input.conditions),
                                         scheme: input.scheme,
                                         virtual_hosted_style: (input.urlStyle == :VIRTUAL_HOSTED_STYLE),
                                         bucket_bound_hostname: bucket_bound_hostname

        _(post_object.url).must_equal output.url

        _(post_object.fields.keys.sort).must_equal output.fields.keys.sort

        _(post_object.fields["key"]).must_equal output.fields["key"]
        _(post_object.fields["x-goog-algorithm"]).must_equal output.fields["x-goog-algorithm"]
        _(post_object.fields["x-goog-credential"]).must_equal output.fields["x-goog-credential"]
        _(post_object.fields["x-goog-date"]).must_equal output.fields["x-goog-date"]
        _(post_object.fields["policy"]).must_equal output.fields["policy"]
        _(post_object.fields["x-goog-signature"]).must_equal output.fields["x-goog-signature"]

        fields.each_pair do |k, v|
          _(post_object.fields[k]).must_equal v
        end
      end
    end
  end

  def self.bucket_test_for description, input, output, index
    define_method("test_bucket_#{index}: #{description}") do
      @test_data = ["bucket", index, description, output.expectedDecodedPolicy]
      bucket_gapi = Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: input.bucket).to_json
      bucket = Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service
      bucket_bound_hostname = input.bucketBoundHostname unless input.bucketBoundHostname&.empty?
      fields = fields_hash input.fields

      Time.stub :now, timestamp_to_time(input.timestamp) do
        # sut
        post_object = bucket.generate_signed_post_policy_v4 input.object,
                                                            issuer: credentials.issuer,
                                                            expires: input.expiration,
                                                            fields: fields,
                                                            conditions: conditions_array(input.conditions),
                                                            scheme: input.scheme,
                                                            virtual_hosted_style: (input.urlStyle == :VIRTUAL_HOSTED_STYLE),
                                                            bucket_bound_hostname: bucket_bound_hostname

        _(post_object.url).must_equal output.url

        _(post_object.fields.keys.sort).must_equal output.fields.keys.sort

        _(post_object.fields["key"]).must_equal output.fields["key"]
        _(post_object.fields["x-goog-algorithm"]).must_equal output.fields["x-goog-algorithm"]
        _(post_object.fields["x-goog-credential"]).must_equal output.fields["x-goog-credential"]
        _(post_object.fields["x-goog-date"]).must_equal output.fields["x-goog-date"]
        _(post_object.fields["policy"]).must_equal output.fields["policy"]
        _(post_object.fields["x-goog-signature"]).must_equal output.fields["x-goog-signature"]
      end
    end
  end

  # Return a hash from the proto Map, sorted by keys
  def fields_hash input_fields
    input_fields.keys.sort.inject({}) { |memo, k| memo[k] = input_fields[k]; memo }
  end

  def conditions_array conditions
    return nil unless conditions
    if !conditions.startsWith&.empty?
      [["starts-with"] + conditions.startsWith]
    elsif !conditions&.contentLengthRange&.empty?
      [["content-length-range"] + conditions.contentLengthRange]
    end
  end

  def timestamp_to_time timestamp
    ::Time.at(timestamp.nanos * 10**-9 + timestamp.seconds)
  end
end

file_path = File.expand_path "../../../../../../conformance/v1/v4_signatures.json", __dir__
test_file = Google::Cloud::Conformance::Storage::V1::TestFile.decode_json File.read(file_path)
test_file.post_policy_v4_tests.each_with_index do |test, index|
  PostObjectConformanceTest.signer_v4_test_for test.description, test.policyInput, test.policyOutput, index
  PostObjectConformanceTest.bucket_test_for test.description, test.policyInput, test.policyOutput, index
end
