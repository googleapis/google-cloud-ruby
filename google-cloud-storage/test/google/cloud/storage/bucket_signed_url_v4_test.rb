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

describe Google::Cloud::Storage::Bucket, :signed_url, :v4, :mock_storage do
  let(:bucket_name) { "bucket" }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: bucket_name).to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:file_path) { "file.ext" }

  it "accepts missing path argument to return URL for listing objects in bucket" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\nc709544abd06ec8c09e9825c9a786a8759cd089bf7c64534ccef6058c0b0f88a"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url version: :v4

      signed_uri = URI(signed_url)
      _(signed_uri.path).must_equal "/bucket"
      signed_url_params = CGI::parse(signed_uri.query)
      _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
      _(signed_url_params["X-Goog-Credential"]).must_equal  ["native_client_email/20120101/auto/storage/goog4_request"]
      _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
      _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
      _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host"]
      _(signed_url_params["X-Goog-Signature"]).must_equal  ["6e61746976652d7369676e6174757265"]

      signing_key_mock.verify
    end
  end

  it "uses the credentials' issuer and signing_key to generate signed_url" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\ndefeee4e2131c1e8e39d4bd739b856297e93b20265a427c5a70a2fd65c4cfd0a"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url file_path, version: :v4

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
      _(signed_url_params["X-Goog-Credential"]).must_equal  ["native_client_email/20120101/auto/storage/goog4_request"]
      _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
      _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
      _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host"]
      _(signed_url_params["X-Goog-Signature"]).must_equal  ["6e61746976652d7369676e6174757265"]

      signing_key_mock.verify
    end
  end

  it "allows issuer and signing_key to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n743e0f302812fbc80545275f54593e9186adee22752444edeeaf50cafe2c02d3"]

      signed_url = bucket.signed_url file_path,
                                     issuer: "option_issuer",
                                     signing_key: signing_key_mock, version: :v4

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
      _(signed_url_params["X-Goog-Credential"]).must_equal  ["option_issuer/20120101/auto/storage/goog4_request"]
      _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
      _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
      _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host"]
      _(signed_url_params["X-Goog-Signature"]).must_equal  ["6f7074696f6e2d7369676e6174757265"]

      signing_key_mock.verify
    end
  end

  it "allows issuer and signer to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signer_mock = Minitest::Mock.new
      signer_mock.expect :is_a?, true, [Proc]
      signer_mock.expect :call, "option-signature", ["GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n743e0f302812fbc80545275f54593e9186adee22752444edeeaf50cafe2c02d3"]

      signed_url = bucket.signed_url file_path, issuer: "option_issuer",
                                                signer: signer_mock, version: :v4

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
      _(signed_url_params["X-Goog-Credential"]).must_equal  ["option_issuer/20120101/auto/storage/goog4_request"]
      _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
      _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
      _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host"]
      _(signed_url_params["X-Goog-Signature"]).must_equal  ["6f7074696f6e2d7369676e6174757265"]

      signer_mock.verify
    end
  end

  it "allows client_email and private to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\nf02f56367165cb2745d426eabaf709f7c3d015ac9cd75158017a0f4fa72ca3d2"]

      OpenSSL::PKey::RSA.stub :new, signing_key_mock do

        signed_url = bucket.signed_url file_path,
                                       client_email: "option_client_email",
                                       private_key: "option_private_key", version: :v4

        signed_url_params = CGI::parse(URI(signed_url).query)
        _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
        _(signed_url_params["X-Goog-Credential"]).must_equal  ["option_client_email/20120101/auto/storage/goog4_request"]
        _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
        _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
        _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host"]
        _(signed_url_params["X-Goog-Signature"]).must_equal  ["6f7074696f6e2d7369676e6174757265"]

      end

      signing_key_mock.verify
    end
  end

  it "allows headers to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\nbf06932c7e0573d8ee8c4b7638a4043f7265c4e019694156a68773ad4d7ee25c"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url file_path,
                                     headers: { "X-Goog-Meta-FOO" => "bar,baz",
                                                "X-Goog-ACL" => "public-read" }, version: :v4

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
      _(signed_url_params["X-Goog-Credential"]).must_equal  ["native_client_email/20120101/auto/storage/goog4_request"]
      _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
      _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
      _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host;x-goog-acl;x-goog-meta-foo"]
      _(signed_url_params["X-Goog-Signature"]).must_equal  ["6e61746976652d7369676e6174757265"]

      signing_key_mock.verify
    end
  end

  it "raises when missing issuer" do
    credentials.issuer = nil
    credentials.signing_key = PoisonSigningKey.new

    expect {
      bucket.signed_url file_path, version: :v4
    }.must_raise Google::Cloud::Storage::SignedUrlUnavailable
  end

  it "raises when missing signing_key" do
    credentials.issuer = "native_issuer"
    credentials.signing_key = nil

    expect {
      bucket.signed_url file_path, version: :v4
    }.must_raise Google::Cloud::Storage::SignedUrlUnavailable
  end

  it "raises with issuer and lambda with incorrect argument count" do
    credentials.issuer = "native_client_email"
    credentials.signing_key = PoisonSigningKey.new

    signer = lambda { puts "should raise an ArgumentError"}

    expect {
      bucket.signed_url file_path, issuer: "option_client_email",
                                   signer: signer, version: :v4
    }.must_raise ArgumentError
  end

  it "allows query params to be passed in" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n3411dfa972b175ec287a97876a29c2652f633698eba7e4e6930b197812131ba3"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url file_path,
                                     query: { "response-content-disposition" => "attachment; filename=\"google-cloud.png\"" }, version: :v4

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
      _(signed_url_params["X-Goog-Credential"]).must_equal  ["native_client_email/20120101/auto/storage/goog4_request"]
      _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
      _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
      _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host"]
      _(signed_url_params["X-Goog-Signature"]).must_equal  ["6e61746976652d7369676e6174757265"]
      signing_key_mock.verify
    end
  end

  it "allows query params to be passed in as symbols" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\na7f06df47c14c9806213f0580c0490c862476820cd668f322850edb89d14484d"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = bucket.signed_url file_path,
                                     query: { disposition: :inline }, version: :v4

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["X-Goog-Algorithm"]).must_equal  ["GOOG4-RSA-SHA256"]
      _(signed_url_params["X-Goog-Credential"]).must_equal  ["native_client_email/20120101/auto/storage/goog4_request"]
      _(signed_url_params["X-Goog-Date"]).must_equal  ["20120101T000000Z"]
      _(signed_url_params["X-Goog-Expires"]).must_equal  ["604800"]
      _(signed_url_params["X-Goog-SignedHeaders"]).must_equal  ["host"]
      _(signed_url_params["X-Goog-Signature"]).must_equal  ["6e61746976652d7369676e6174757265"]

      signing_key_mock.verify
    end
  end

  class PoisonSigningKey
    def sign kind, sig
      raise "The wrong signing_key was used"
    end
  end
end
