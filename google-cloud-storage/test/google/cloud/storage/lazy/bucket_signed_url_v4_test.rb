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

describe Google::Cloud::Storage::Bucket, :signed_url, :v4, :lazy, :mock_storage do
  let(:bucket_name) { "bucket" }
  let(:bucket) { Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service }
  let(:file_path) { "file.ext" }
  let(:custom_universe_domain) { "mydomain1.com" }
  let(:custom_endpoint) { "https://storage.#{custom_universe_domain}/" }

  it "uses the credentials' issuer and signing_key to generate signed_url" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n252fee6a927ec9b0546bb9b224a2db37834e32c71dd8ea9702cc0e9efda75d10"]
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
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n5fa39815ca7f8547b8f9e23dce41d856444d111f0c6dbbf5cf53b86788f2ee00"]

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

  it "allows client_email and private to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n84e760a9c6483d6c37a98f4ab99e1a9a208e111ad7381297dea05774e99b0fbc"]

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
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n69d4a99930b6778335b72f716aee5a44ee3fcb20d19980d4419ea6c58b6e015f"]
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

  it "allows query params to be passed in" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n89185f10c0e52e1bf904e270cdcaa0d6915f6c1efdc37b621681ebb0075b33a5"]
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
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n6890375b93ef0f2474757e2d1b49c061f9d0c3024a89934633c9b397a49884be"]
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

  describe "Supports custom endpoint" do
    after do
      Google::Cloud.configure.reset!
    end

    it "returns signed_url with custom universe_domain" do
      service = Google::Cloud::Storage::Service.new project, credentials, universe_domain: custom_universe_domain
      bucket = Google::Cloud::Storage::Bucket.new_lazy bucket_name, service

      Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
        signing_key_mock = Minitest::Mock.new
        signing_key_mock.expect :is_a?, false, [Proc]
        signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\ne1e43b11fd8237bbc9aa341fdc80a01d0b06197ebaf3c6fc0cf76f93decacbac"]

        credentials.issuer = "native_client_email"
        credentials.signing_key = signing_key_mock

        signed_url = bucket.signed_url version: :v4

        signed_url = URI(signed_url)
        _(signed_url.host).must_equal URI(custom_endpoint).host
        signing_key_mock.verify
      end
    end

    it "returns signed_url with custom endpoint" do
      Google::Cloud::Storage.configure do |config|
        config.endpoint = custom_endpoint
      end
      storage = Google::Cloud::Storage.new(project_id: project)
      bucket = Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service

      Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
        signing_key_mock = Minitest::Mock.new
        signing_key_mock.expect :is_a?, false, [Proc]
        signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GOOG4-RSA-SHA256\n20120101T000000Z\n20120101/auto/storage/goog4_request\n252fee6a927ec9b0546bb9b224a2db37834e32c71dd8ea9702cc0e9efda75d10"]

        signed_url = bucket.signed_url file_path, issuer: "native_client_email", signing_key: signing_key_mock, version: :v4

        signed_url = URI(signed_url)
        _(signed_url.host).must_equal URI(custom_endpoint).host
        signing_key_mock.verify
      end
    end
  end

  class PoisonSigningKey
    def sign kind, sig
      raise "The wrong signing_key was used"
    end
  end
end
