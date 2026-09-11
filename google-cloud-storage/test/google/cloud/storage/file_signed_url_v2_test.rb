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
require "google/cloud/storage/iam_signer"

describe Google::Cloud::Storage::File, :signed_url, :mock_storage do
  let(:bucket_name) { "bucket" }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: bucket_name).to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:file_name) { "file.ext" }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json random_file_hash(bucket.name, file_name).to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
  let(:custom_universe_domain) { "mydomain1.com" }
  let(:custom_endpoint) { "https://storage.#{custom_universe_domain}/" }

  it "uses the credentials' issuer and signing_key to generate signed_url" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = file.signed_url

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["GoogleAccessId"]).must_equal ["native_client_email"]
      _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("native-signature").delete("\n")]

      signing_key_mock.verify
    end
  end

  it "allows issuer and signing_key to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]

      signed_url = file.signed_url issuer: "option_issuer",
                                   signing_key: signing_key_mock

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["GoogleAccessId"]).must_equal ["option_issuer"]
      _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("option-signature").delete("\n")]

      signing_key_mock.verify
    end
  end

  it "allows issuer and signer to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signer_mock = Minitest::Mock.new
      signer_mock.expect :is_a?, true, [Proc]
      signer_mock.expect :call, "option-signature", ["GET\n\n\n1325376300\n/bucket/file.ext"]

      signed_url = file.signed_url issuer: "option_client_email",
                                   signer: signer_mock

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["GoogleAccessId"]).must_equal ["option_client_email"]
      _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("option-signature").delete("\n")]

      signer_mock.verify
    end
  end

  it "allows client_email and private to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_client_email"
      credentials.signing_key = PoisonSigningKey.new

      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :sign, "option-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]

      OpenSSL::PKey::RSA.stub :new, signing_key_mock do

        signed_url = file.signed_url client_email: "option_client_email",
                                     private_key: "option_private_key"

        signed_url_params = CGI::parse(URI(signed_url).query)
        _(signed_url_params["GoogleAccessId"]).must_equal ["option_client_email"]
        _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("option-signature").delete("\n")]

      end

      signing_key_mock.verify
    end
  end

  it "allows headers to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\nx-goog-acl:public-read\nx-goog-meta-foo:bar,baz\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = file.signed_url headers: { "X-Goog-Meta-FOO" => "bar,baz",
                                              "X-Goog-ACL" => "public-read" }

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["GoogleAccessId"]).must_equal ["native_client_email"]
      _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("native-signature").delete("\n")]

      signing_key_mock.verify
    end
  end

  it "allows response content type and disposition to be passed in as options" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = file.signed_url query: { "response-content-disposition" => "attachment; filename=\"test.png\"" }

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["GoogleAccessId"]).must_equal ["native_client_email"]
      _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("native-signature").delete("\n")]
      _(signed_url_params["response-content-disposition"]).must_equal ["attachment; filename=\"test.png\""]

      signing_key_mock.verify
    end
  end

  it "raises SignedUrlUnavailable when missing both signing_key and issuer" do
    credentials.issuer = nil
    credentials.signing_key = nil

    Google::Cloud.env.stub :compute_engine?, false do
      expect {
        file.signed_url
      }.must_raise Google::Cloud::Storage::SignedUrlUnavailable
    end
  end

  it "falls back to IAMSigner when missing signing_key" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = "native_issuer@email.com"
      credentials.signing_key = nil

      iam_signer_mock = Minitest::Mock.new
      iam_signer_mock.expect :sign, "iam-signature", ["native_issuer@email.com", "GET\n\n\n1325376300\n/bucket/file.ext"]

      Google::Cloud.env.stub :compute_engine?, false do
        Google::Cloud::Storage::IAMSigner.stub :new, iam_signer_mock do
          signed_url = file.signed_url

          signed_url_params = CGI::parse(URI(signed_url).query)
          _(signed_url_params["GoogleAccessId"]).must_equal ["native_issuer@email.com"]
          _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("iam-signature").delete("\n")]
        end
      end

      iam_signer_mock.verify
    end
  end

  it "uses IAMSigner and auto-detects issuer if compute_engine? is true" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      credentials.issuer = nil
      credentials.signing_key = nil

      iam_signer_mock = Minitest::Mock.new
      iam_signer_mock.expect :sign, "iam-signature", ["metadata_issuer@email.com", "GET\n\n\n1325376300\n/bucket/file.ext"]

      Google::Cloud.env.stub :compute_engine?, true do
        Google::Cloud.env.stub :lookup_metadata, "metadata_issuer@email.com" do
          Google::Cloud::Storage::IAMSigner.stub :new, iam_signer_mock do
            signed_url = file.signed_url

            signed_url_params = CGI::parse(URI(signed_url).query)
            _(signed_url_params["GoogleAccessId"]).must_equal ["metadata_issuer@email.com"]
            _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("iam-signature").delete("\n")]
          end
        end
      end

      iam_signer_mock.verify
    end
  end

  it "raises with issuer and lambda with incorrect argument count" do
    credentials.issuer = "native_client_email"
    credentials.signing_key = PoisonSigningKey.new

    signer = lambda { puts "should raise an ArgumentError"}

    expect {
      file.signed_url issuer: "option_client_email",
                      signer: signer
    }.must_raise ArgumentError
  end

  describe "Files with spaces and hashes in them" do
    let(:file_name) { "hello world #1.txt" }

    it "properly escapes the path when generating signed_url" do
      Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
        signing_key_mock = Minitest::Mock.new
        signing_key_mock.expect :is_a?, false, [Proc]
        signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/hello%20world%20%231.txt"]
        credentials.issuer = "native_client_email"
        credentials.signing_key = signing_key_mock

        signed_url = file.signed_url

        signed_uri = URI signed_url
        _(signed_uri.path).must_equal "/bucket/hello%20world%20%231.txt"

        signed_url_params = CGI::parse signed_uri.query
        _(signed_url_params["GoogleAccessId"]).must_equal ["native_client_email"]
        _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("native-signature").delete("\n")]

        signing_key_mock.verify
      end
    end
  end

  it "allows query params to be passed in" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = file.signed_url query: { "response-content-disposition" => "attachment; filename=\"google-cloud.png\"" }

      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["GoogleAccessId"]).must_equal ["native_client_email"]
      _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("native-signature").delete("\n")]
      _(signed_url_params["response-content-disposition"]).must_equal ["attachment; filename=\"google-cloud.png\""]

      signing_key_mock.verify
    end
  end

  it "allows query params to be passed in as symbols" do
    Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
      signing_key_mock = Minitest::Mock.new
      signing_key_mock.expect :is_a?, false, [Proc]
      signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]
      credentials.issuer = "native_client_email"
      credentials.signing_key = signing_key_mock

      signed_url = file.signed_url query: { disposition: :inline }
      signed_url_params = CGI::parse(URI(signed_url).query)
      _(signed_url_params["GoogleAccessId"]).must_equal ["native_client_email"]
      _(signed_url_params["Signature"]).must_equal [Base64.strict_encode64("native-signature").delete("\n")]
      _(signed_url_params["disposition"]).must_equal ["inline"]

      signing_key_mock.verify
    end
  end

  describe "Supports custom endpoint" do

    it "returns signed_url with custom universe_domain" do
      service = Google::Cloud::Storage::Service.new project, credentials, universe_domain: custom_universe_domain
      file = Google::Cloud::Storage::File.from_gapi file_gapi, service

      Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
        signing_key_mock = Minitest::Mock.new
        signing_key_mock.expect :is_a?, false, [Proc]
        signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]

        credentials.issuer = "native_client_email"
        credentials.signing_key = signing_key_mock

        signed_url = file.signed_url

        signed_url = URI(signed_url)
        _(signed_url.host).must_equal URI(custom_endpoint).host
        signing_key_mock.verify
      end
    end

    it "returns signed_url with custom endpoint" do
      service = Google::Cloud::Storage::Service.new project, credentials, host: custom_endpoint
      file = Google::Cloud::Storage::File.from_gapi file_gapi, service

      Time.stub :now, Time.new(2012,1,1,0,0,0, "+00:00") do
        signing_key_mock = Minitest::Mock.new
        signing_key_mock.expect :is_a?, false, [Proc]
        signing_key_mock.expect :sign, "native-signature", [OpenSSL::Digest::SHA256, "GET\n\n\n1325376300\n/bucket/file.ext"]

        signed_url = file.signed_url issuer: "native_client_email", signing_key: signing_key_mock

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
