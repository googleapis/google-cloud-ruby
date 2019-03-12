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

class V4SignerTest < MockStorage
  def setup
    account = self.class.load_json "../../../../data/v4_signer_test_account.json"
    credentials.issuer = account["client_email"]
    credentials.signing_key = OpenSSL::PKey::RSA.new account["private_key"]
  end

  def headers_from_json headers
    return nil if headers.nil? || headers.empty?
    Hash[headers.map{ |k,v| [k, v.join(",")] } ]
  end

  def self.load_json rel_path
    json_file = File.expand_path rel_path, __dir__
    json_contents = File.read json_file
    JSON.parse json_contents
  end

  def self.build_test_for test, index
    define_method("test_#{index}: #{test["description"]}") do
      # start: test method body
      signer = Google::Cloud::Storage::File::V4Signer.new test["bucket"],
                                                          test["object"],
                                                          storage.service
      Time.stub :now, Time.parse(test["timestamp"]) do
        # method under test
        signed_url = signer.signed_url method: test["method"],
                                       expires: test["expiration"].to_i,
                                       headers: headers_from_json(test["headers"])

        signed_url.must_equal test["expectedUrl"]
      end
      # end: test method body
    end
  end
end

tests = V4SignerTest.load_json "../../../../data/v4_signer_test_data.json"
tests.each_with_index do |test, index|
  next if [6,8].include? index # TODO: Support multiple headers
  V4SignerTest.build_test_for test, index
end
