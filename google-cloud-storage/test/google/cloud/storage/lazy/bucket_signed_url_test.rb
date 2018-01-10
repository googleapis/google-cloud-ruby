# Copyright 2017 Google LLC
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

describe Google::Cloud::Storage::Bucket, :signed_url, :lazy, :mock_storage do
  let(:bucket_name) { "bucket" }
  let(:bucket) { Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service }

  let(:file_path) { "file.ext" }

  it "uses the credentials' issuer and signing_key to generate signed_url" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url file_path

      signed_url_params = CGI::parse(URI(signed_url).query)
      signed_url_params["GoogleAccessId"].must_equal ["native_client_email"]
      signed_url_params["Signature"].must_equal [Base64.strict_encode64("native-signature").delete("\n")]

      signing_key_mock.verify
    end
  end

  it "allows issuer and signing_key to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]

      signed_url = bucket.signed_url file_path, issuer: "option_issuer",
                                                signing_key: signing_key_mock

      signed_url_params = CGI::parse(URI(signed_url).query)
      signed_url_params["GoogleAccessId"].must_equal ["option_issuer"]
      signed_url_params["Signature"].must_equal [Base64.strict_encode64("option-signature").delete("\n")]

      signing_key_mock.verify
    end
  end

  it "allows client_email and private to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]

      OpenSSL::PKey::RSA.stub :new, signing_key_mock do

        signed_url = bucket.signed_url file_path, client_email: "option_client_email",
                                                  private_key: "option_private_key"

        signed_url_params = CGI::parse(URI(signed_url).query)
        signed_url_params["GoogleAccessId"].must_equal ["option_client_email"]
        signed_url_params["Signature"].must_equal [Base64.strict_encode64("option-signature").delete("\n")]

      end

      signing_key_mock.verify
    end
  end

  it "allows headers to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\nx-goog-acl:public-read\nx-goog-meta-foo:bar,baz\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url file_path, headers: { "X-Goog-Meta-FOO" => "bar,baz",
                                                           "X-Goog-ACL" => "public-read" }

      signed_url_params = CGI::parse(URI(signed_url).query)
      signed_url_params["GoogleAccessId"].must_equal ["native_client_email"]
      signed_url_params["Signature"].must_equal [Base64.strict_encode64("native-signature").delete("\n")]

      signing_key_mock.verify
    end
  end

  it "raises when missing issuer" do
    credentials.issuer = nil
    credentials.signing_key = PoisonSigningKey.new

    expect {
      bucket.signed_url file_path
    }.must_raise Google::Cloud::Storage::SignedUrlUnavailable
  end

  it "raises when missing signing_key" do
    credentials.issuer = "native_issuer"
    credentials.signing_key = nil

    expect {
      bucket.signed_url file_path
    }.must_raise Google::Cloud::Storage::SignedUrlUnavailable
  end

  describe "Files with spaces in them" do
    let(:file_path) { "hello world.txt" }

    it "properly escapes the path when generating signed_url" do
      Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
        signing_key_mock = Minitest::Mock.new
        signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/hello+world.txt"]
        credentials.issuer = "native_client_email"
        credentials.signing_key = signing_key_mock

        signed_url = bucket.signed_url file_path

        signed_uri = URI signed_url
        signed_uri.path.must_equal "/bucket/hello+world.txt"

        signed_url_params = CGI::parse signed_uri.query
        signed_url_params["GoogleAccessId"].must_equal ["native_client_email"]
        signed_url_params["Signature"].must_equal [Base64.strict_encode64("native-signature").delete("\n")]

        signing_key_mock.verify
      end
    end
  end

  it "allows query params to be passed in" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url file_path,
                                     query: { "response-content-disposition" => "attachment; filename=\"google-cloud.png\"" }

      signed_url_params = CGI::parse(URI(signed_url).query)
      signed_url_params["GoogleAccessId"].must_equal ["native_client_email"]
      signed_url_params["Signature"].must_equal [Base64.strict_encode64("native-signature").delete("\n")]
      signed_url_params["response-content-disposition"].must_equal ["attachment; filename=\"google-cloud.png\""]

      signing_key_mock.verify
    end
  end

  class PoisonSigningKey
    def sign kind, sig
      raise "The wrong signing_key was used"
    end
  end
end
