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

require "storage_helper"
require "google/apis/iamcredentials_v1"
require "net/http"
require "uri"

describe Google::Cloud::Storage::Bucket, :generate_signed_post_policy_v4, :storage do
  let(:bucket_name) { $bucket_names.first }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket bucket_name }
  end
  let(:uri) { URI.parse Google::Cloud::Storage::GOOGLEAPIS_URL }
  let(:data_file) { "logo.jpg" }
  let(:data) { File.expand_path("../data/#{data_file}", __dir__) }
  let(:data_csv_file) { "example.csv" } # < 1 KB
  let(:data_csv) { File.expand_path("../data/#{data_csv_file}", __dir__) }

  it "generates a signed post object v4 simple" do
    post_object = bucket.generate_signed_post_policy_v4 "test-object", expires: 10

    _(post_object.fields.keys.sort).must_equal [
      "key",
      "policy",
      "x-goog-algorithm",
      "x-goog-credential",
      "x-goog-date",
      "x-goog-signature"
    ]

    # For some weird (as yet unidentified) reason, keeping file as the first value
    # makes the http request fail intermittently with a 400 error.
    # Moving file as the last entry in the form_data array works fine.
    # Updating this in multiple places in this file.
    form_data= []
    post_object.fields.each do |key, value|
      form_data.push [key, value]
    end
    form_data.push ["file", File.open(data)]

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url
    request.set_form form_data, "multipart/form-data"

    response = http.request request

    _(response.code).must_equal "204"
    file = bucket.file(post_object.fields["key"])
    _(file).wont_be :nil?
    Tempfile.open ["google-cloud-logo", ".jpg"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile
      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(data, mode: "rb")
    end
  end

  it "generates a signed post object v4 using signBlob API" do
    iam_client = Google::Apis::IamcredentialsV1::IAMCredentialsService.new
    # Get the environment configured authorization
    iam_client.authorization = bucket.service.credentials.client

    # Only defined when using a service account
    issuer = iam_client.authorization.issuer
    signer = lambda do |string_to_sign|
      request = Google::Apis::IamcredentialsV1::SignBlobRequest.new(
        payload: string_to_sign
      )
      resource = "projects/-/serviceAccounts/#{issuer}"
      response = iam_client.sign_service_account_blob resource, request
      response.signed_blob
    end

    post_object = bucket.generate_signed_post_policy_v4 "test-object",
                                                        expires: 10,
                                                        issuer: issuer,
                                                        signer: signer

    _(post_object.fields.keys.sort).must_equal [
      "key",
      "policy",
      "x-goog-algorithm",
      "x-goog-credential",
      "x-goog-date",
      "x-goog-signature"
    ]

    form_data = []
    post_object.fields.each do |key, value|
      form_data.push [key, value]
    end
    form_data.push ["file", File.open(data)]

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url
    request.set_form form_data, "multipart/form-data"

    response = http.request request

    _(response.code).must_equal "204"
    file = bucket.file post_object.fields["key"]
    _(file).wont_be :nil?
    Tempfile.open ["google-cloud-logo", ".jpg"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile
      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(data, mode: "rb")
    end
  end

  it "generates a signed post object v4 virtual hosted style" do
    post_object = bucket.generate_signed_post_policy_v4 "test-object", expires: 10, virtual_hosted_style: true

    _(post_object.fields.keys.sort).must_equal [
      "key",
      "policy",
      "x-goog-algorithm",
      "x-goog-credential",
      "x-goog-date",
      "x-goog-signature"
    ]

    form_data= []
    post_object.fields.each do |key, value|
      form_data.push [key, value]
    end
    form_data.push ["file", File.open(data)]

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url
    request.set_form form_data, "multipart/form-data"

    response = http.request request
    _(response.code).must_equal "204"
    file = bucket.file(post_object.fields["key"])
    _(file).wont_be :nil?
    Tempfile.open ["google-cloud-logo", ".jpg"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile
      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(data, mode: "rb")
    end
  end

  it "generates a signed post object v4 with acl and cache-control file headers" do
    fields = {
      "acl" => "public-read",
      "cache-control" => "public,max-age=86400"
    }
    post_object = bucket.generate_signed_post_policy_v4 "test-object", expires: 10, fields: fields

    _(post_object.fields.keys.sort).must_equal [
      "acl",
      "cache-control",
      "key",
      "policy",
      "x-goog-algorithm",
      "x-goog-credential",
      "x-goog-date",
      "x-goog-signature"
    ]

    form_data = []
    post_object.fields.each do |key, value|
      form_data.push [key, value]
    end
    form_data.push ["file", File.open(data)]

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url
    request.set_form form_data, "multipart/form-data"

    response = http.request request

    _(response.code).must_equal "204"
    file = bucket.file(post_object.fields["key"])
    _(file).wont_be :nil?
    Tempfile.open ["google-cloud-logo", ".jpg"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile
      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(data, mode: "rb")
    end
  end

  it "generates a signed post object v4 with success_action_status" do
    fields = {
      "success_action_status" => "200"
    }
    post_object = bucket.generate_signed_post_policy_v4 "test-object", expires: 10, fields: fields

    _(post_object.fields.keys.sort).must_equal [
      "key",
      "policy",
      "success_action_status",
      "x-goog-algorithm",
      "x-goog-credential",
      "x-goog-date",
      "x-goog-signature"
    ]

    form_data = []
    post_object.fields.each do |key, value|
      form_data.push [key, value]
    end
    form_data.push ["file", File.open(data)]

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url
    request.set_form form_data, "multipart/form-data"

    response = http.request request

    _(response.code).must_equal "200"
    file = bucket.file(post_object.fields["key"])
    _(file).wont_be :nil?
    Tempfile.open ["google-cloud-logo", ".jpg"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile
      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(data, mode: "rb")
    end
  end

  it "generates a signed post object v4 with conditions" do
    conditions = [["starts-with", "$key", ""]]
    post_object = bucket.generate_signed_post_policy_v4 "${filename}", expires: 10, conditions: conditions

    _(post_object.fields.keys.sort).must_equal [
      "key",
      "policy",
      "x-goog-algorithm",
      "x-goog-credential",
      "x-goog-date",
      "x-goog-signature"
    ]

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url

    form_data = [
      ["key", post_object.fields["key"]],
      ["policy", post_object.fields["policy"]],
      ["x-goog-algorithm", post_object.fields["x-goog-algorithm"]],
      ["x-goog-credential", post_object.fields["x-goog-credential"]],
      ["x-goog-date", post_object.fields["x-goog-date"]],
      ["x-goog-signature", post_object.fields["x-goog-signature"]],
      ["file", File.open(data_csv)],
    ]

    request.set_form form_data, "multipart/form-data"

    response = http.request request
    puts response.body
    _(response.code).must_equal "204"
    file = bucket.file("example.csv")
    _(file).wont_be :nil?
    Tempfile.open ["example", ".csv"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile
      _(File.read(downloaded.path)).must_equal File.read(data_csv)
    end
  end

  def timestamp_to_time timestamp
    ::Time.parse timestamp
  end
end
