# Copyright 2019 Google LLC
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

class SignedUrlConformanceTest < MockStorage
  def setup
    account_file_path = File.expand_path "../../../../../../conformance/v1/test_service_account.not-a-test.json", __dir__
    account = JSON.parse File.read(account_file_path)
    credentials.issuer = account["client_email"]
    credentials.signing_key = OpenSSL::PKey::RSA.new account["private_key"]
    @test_data = nil # not thread safe
  end

  def teardown
    if !passed? && @test_data
      test = @test_data[0]
      puts "\ntest_#{@test_data[1]}_#{@test_data[2]}: #{test.description}:\n"
      puts "CanonicalRequest\n\nexpected:\n\n#{test.expectedCanonicalRequest}\n\n"
      puts "StringToSign\n\nexpected:\n\n#{test.expectedStringToSign}\n\n"
    end
  end

  def self.signer_v4_test_for test, index
    define_method("test_signer_v4_#{index}: #{test.description}") do
      @test_data = [test, "signer_v4", index]
      signer = Google::Cloud::Storage::File::SignerV4.new test.bucket,
                                                          test.object,
                                                          storage.service
      Time.stub :now, timestamp_to_time(test.timestamp) do
        # sut
        signed_url = signer.signed_url **kwargs(test)

        _(signed_url).must_equal test.expectedUrl
      end
    end
  end

  def self.project_test_for test, index
    define_method("test_project_#{index}: #{test.description}") do
      @test_data = [test, "project", index]
      Time.stub :now, timestamp_to_time(test.timestamp) do
        # sut
        signed_url = storage.signed_url test.bucket, test.object, **kwargs(test).merge({version: :v4})

        _(signed_url).must_equal test.expectedUrl
      end
    end
  end

  def self.bucket_test_for test, index
    define_method("test_bucket_#{index}: #{test.description}") do
      @test_data = [test, "bucket", index]
      bucket_gapi = Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: test.bucket).to_json
      bucket = Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service
      Time.stub :now, timestamp_to_time(test.timestamp) do
        # sut
        signed_url = bucket.signed_url test.object, **kwargs(test).merge({version: :v4})

        _(signed_url).must_equal test.expectedUrl
      end
    end
  end

  def self.file_test_for test, index
    define_method("test_file_#{index}: #{test.description}") do
      @test_data = [test, "file", index]
      bucket_gapi = Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: test.bucket).to_json
      bucket = Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service
      file_gapi = Google::Apis::StorageV1::Object.from_json random_file_hash(test.bucket, test.object).to_json
      file = Google::Cloud::Storage::File.from_gapi file_gapi, storage.service
      Time.stub :now, timestamp_to_time(test.timestamp) do
        # sut
        signed_url = file.signed_url **kwargs(test).merge({version: :v4})

        _(signed_url).must_equal test.expectedUrl
      end
    end
  end

  # Build kwargs hash from test fixtures.
  # Convert some arguments from protobuf maps and default "" strings.
  def kwargs test
    method = test["method"] unless test["method"]&.empty?
    headers = test.headers.to_h if test.headers
    query = test.query_parameters.to_h if test.query_parameters
    bucket_bound_hostname = test.bucketBoundHostname unless test.bucketBoundHostname&.empty?
    {
      method: method,
      expires: test.expiration,
      headers: headers,
      query: query,
      scheme: test.scheme,
      virtual_hosted_style: (test.urlStyle == :VIRTUAL_HOSTED_STYLE),
      bucket_bound_hostname: bucket_bound_hostname
    }
  end

  def timestamp_to_time timestamp
    ::Time.at(timestamp.nanos * 10**-9 + timestamp.seconds)
  end
end

file_path = File.expand_path "../../../../../../conformance/v1/v4_signatures.json", __dir__
test_file = Google::Cloud::Conformance::Storage::V1::TestFile.decode_json File.read(file_path)
test_file.signing_v4_tests.each_with_index do |test, index|
  SignedUrlConformanceTest.signer_v4_test_for test, index
  SignedUrlConformanceTest.project_test_for test, index
  SignedUrlConformanceTest.bucket_test_for test, index
  SignedUrlConformanceTest.file_test_for test, index
end
