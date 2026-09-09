# Copyright 2015 Google LLC
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
require "google/cloud/credentials"

##
# This test is testing the private class Google::Cloud::Credentials. We want to make
# sure that the passed in scope propogates to the Signet object. This means
# testing the private API, which is generally frowned on.
describe Google::Cloud::Credentials, :private do
  let(:default_keyfile_hash) do
    {
      "private_key_id"=>"testabc1234567890xyz",
      "private_key"=>"-----BEGIN RSA PRIVATE KEY-----\nMIIBOwIBAAJBAOyi0Hy1l4Ym2m2o71Q0TF4O9E81isZEsX0bb+Bqz1SXEaSxLiXM\nUZE8wu0eEXivXuZg6QVCW/5l+f2+9UPrdNUCAwEAAQJAJkqubA/Chj3RSL92guy3\nktzeodarLyw8gF8pOmpuRGSiEo/OLTeRUMKKD1/kX4f9sxf3qDhB4e7dulXR1co/\nIQIhAPx8kMW4XTTL6lJYd2K5GrH8uBMp8qL5ya3/XHrBgw3dAiEA7+3Iw3ULTn2I\n1J34WlJ2D5fbzMzB4FAHUNEV7Ys3f1kCIQDtUahCMChrl7+H5t9QS+xrn77lRGhs\nB50pjvy95WXpgQIhAI2joW6JzTfz8fAapb+kiJ/h9Vcs1ZN3iyoRlNFb61JZAiA8\nNy5NyNrMVwtB/lfJf1dAK/p/Bwd8LZLtgM6PapRfgw==\n-----END RSA PRIVATE KEY-----\n",
      "client_email"=>"credz-testabc1234567890xyz@developer.gserviceaccount.com",
      "client_id"=>"credz-testabc1234567890xyz.apps.googleusercontent.com",
      "type"=>"service_account"
    }
  end

  it "uses a default scope" do
    mocked_signet = Minitest::Mock.new
    mocked_signet.expect :fetch_access_token!, true

    stubbed_signet = ->(options, scope: nil) {
      _(options[:token_credential_uri]).must_equal "https://oauth2.googleapis.com/token"
      _(options[:audience]).must_equal "https://oauth2.googleapis.com/token"
      _(options[:scope]).must_equal []
      _(options[:issuer]).must_equal default_keyfile_hash["client_email"]
      _(options[:signing_key]).must_be_kind_of OpenSSL::PKey::RSA

      mocked_signet
    }

    Signet::OAuth2::Client.stub :new, stubbed_signet do
      Google::Cloud::Credentials.new default_keyfile_hash
    end

    mocked_signet.verify
  end

  it "uses a custom scope" do
    mocked_signet = Minitest::Mock.new
    mocked_signet.expect :fetch_access_token!, true

    stubbed_signet = ->(options, scope: nil) {
      _(options[:token_credential_uri]).must_equal "https://oauth2.googleapis.com/token"
      _(options[:audience]).must_equal "https://oauth2.googleapis.com/token"
      _(options[:scope]).must_equal ["http://example.com/scope"]
      _(options[:issuer]).must_equal default_keyfile_hash["client_email"]
      _(options[:signing_key]).must_be_kind_of OpenSSL::PKey::RSA

      mocked_signet
    }

    Signet::OAuth2::Client.stub :new, stubbed_signet do
      Google::Cloud::Credentials.new default_keyfile_hash, scope: "http://example.com/scope"
    end

    mocked_signet.verify
  end
end
