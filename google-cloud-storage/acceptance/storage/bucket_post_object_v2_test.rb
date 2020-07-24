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

require "storage_helper"
require "google/apis/iamcredentials_v1"
require "net/http"
require "uri"

describe Google::Cloud::Storage::Bucket, :post_object, :v2, :storage do
  let(:bucket_name) { $bucket_names.first }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:uri) { URI.parse Google::Cloud::Storage::GOOGLEAPIS_URL }
  let(:data_file) { "logo.jpg" }
  let(:data) { File.expand_path("../data/#{data_file}", __dir__) }
  let :policy do
    {
      expiration: (Time.now + 600).iso8601,
      conditions: [
        ["starts-with", "$key", ""]
      ]
    }
  end

  it "generates a signed post object V2" do
    file_name = "logo-#{SecureRandom.hex(4).downcase}.jpg"

    _(bucket.file(file_name)).must_be :nil?

    post_object = bucket.post_object file_name, policy: policy
    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url

    form_data = [
      ['file', File.open(data)],
      ['key', post_object.fields[:key]],
      ['GoogleAccessId', post_object.fields[:GoogleAccessId]],
      ['policy', post_object.fields[:policy]],
      ['signature', post_object.fields[:signature]]
    ]
    request.set_form form_data, 'multipart/form-data'

    response = http.request request

    _(response.code).must_equal "204"
    _(bucket.file(file_name)).wont_be :nil?
  end

  it "generates a signed post object using signBlob API" do
    file_name = "logo-#{SecureRandom.hex(4).downcase}.jpg"

    _(bucket.file(file_name)).must_be :nil?

    iam_credentials_client = Google::Apis::IamcredentialsV1::IAMCredentialsService.new
    # Get the environment configured authorization
    scopes =  ['https://www.googleapis.com/auth/cloud-platform']
    iam_credentials_client.authorization = Google::Auth.get_application_default(scopes)

    # Only defined when using a service account
    issuer = iam_credentials_client.authorization.issuer
    signer = lambda do |string_to_sign|
      request = {
           "payload": string_to_sign,
      }
      response = iam_credentials_client.sign_service_account_blob(
       "projects/-/serviceAccounts/#{issuer}",
       request,
       {}
      )
      response.signed_blob
    end

    post_object = bucket.post_object file_name, policy: policy,
                                                issuer: issuer,
                                                signer: signer
    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url

    form_data = [
      ['file', File.open(data)],
      ['key', post_object.fields[:key]],
      ['GoogleAccessId', post_object.fields[:GoogleAccessId]],
      ['policy', post_object.fields[:policy]],
      ['signature', post_object.fields[:signature]]
    ]
    request.set_form form_data, 'multipart/form-data'

    response = http.request request

    _(response.code).must_equal "204"
    _(bucket.file(file_name)).wont_be :nil?
  end

  it "generates a signed post object with special variable key ${filename}" do
    # "You can also use the ${filename} variable if a user is providing a file name."
    #  https://cloud.google.com/storage/docs/xml-api/post-object
    special_key = "${filename}"

    _(bucket.file(data_file)).must_be :nil?

    post_object = bucket.post_object special_key, policy: policy

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    request = Net::HTTP::Post.new post_object.url

    form_data = [
      ['file', File.open(data)],
      ['key', post_object.fields[:key]],
      ['GoogleAccessId', post_object.fields[:GoogleAccessId]],
      ['policy', post_object.fields[:policy]],
      ['signature', post_object.fields[:signature]]
    ]
    request.set_form form_data, 'multipart/form-data'

    response = http.request request

    _(response.code).must_equal "204"
    _(bucket.file(data_file)).wont_be :nil?
  end
end
