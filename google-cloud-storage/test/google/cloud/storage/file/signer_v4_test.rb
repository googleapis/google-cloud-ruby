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
require_relative "../../../../../conformance/v1/proto/google/cloud/conformance/storage/v1/tests_pb.rb"

class SignerV4Test < MockStorage
  def setup
    account_file_path = File.expand_path "../../../../../conformance/v1/test_service_account.not-a-test.json", __dir__
    account = JSON.parse File.read(account_file_path)
    credentials.issuer = account["client_email"]
    credentials.signing_key = OpenSSL::PKey::RSA.new account["private_key"]
    @test = nil
  end

  def teardown
    if !passed? && @test
      test = @test.first
      puts "\ntest_#{@test.last}: #{test.description}:\n"
      puts "test.expectedCanonicalRequest:\n\n#{test.expectedCanonicalRequest}\n\n"
      puts "test.expectedStringToSign:\n\n#{test.expectedStringToSign}\n\n"
    end
  end  

  def self.build_test_for test, index
    define_method("test_#{index}: #{test.description}") do

      @test = [test, index]
      # start: test method body
      signer = Google::Cloud::Storage::File::SignerV4.new test.bucket,
                                                          test.object,
                                                          storage.service
      Time.stub :now, SignerV4Test.timestamp_to_time(test.timestamp) do
        # method under test
        signed_url = signer.signed_url method: test["method"],
                                       expires: test.expiration,
                                       headers: test.headers
       
        signed_url.must_equal test.expectedUrl
      end
      # end: test method body
    end
  end

  def self.timestamp_to_time timestamp
    ::Time.at(timestamp.nanos * 10**-9 + timestamp.seconds)
  end
end

file_path = File.expand_path "../../../../../conformance/v1/v4_signatures.json", __dir__
test_file = Google::Cloud::Conformance::Storage::V1::TestFile.decode_json File.read(file_path)
test_file.signing_v4_tests.each_with_index do |test, index|
  SignerV4Test.build_test_for test, index
end
