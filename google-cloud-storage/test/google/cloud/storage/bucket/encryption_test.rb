# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Storage::Bucket::Encryption do
  it "can be used for KMS keys" do
    encryption = Google::Cloud::Storage::Bucket::Encryption.new.tap do |e|
      e.gapi.default_kms_key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    end
    config_gapi = Google::Apis::StorageV1::Bucket::Encryption.new(
      default_kms_key_name: "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    )

    encryption.must_be_kind_of Google::Cloud::Storage::Bucket::Encryption
    encryption.default_kms_key.must_equal "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    encryption.to_gapi.to_h.must_equal config_gapi.to_h
  end

  it "can set KMS keys" do
    encryption = Google::Cloud::Storage::Bucket::Encryption.new
    encryption.must_be_kind_of Google::Cloud::Storage::Bucket::Encryption

    encryption.default_kms_key = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    encryption.default_kms_key.must_equal "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    encryption.default_kms_key = "projects/1/locations/2/keyRings/3/cryptoKeys/4"
    encryption.default_kms_key.must_equal "projects/1/locations/2/keyRings/3/cryptoKeys/4"
    encryption.default_kms_key.must_equal "projects/1/locations/2/keyRings/3/cryptoKeys/4"
  end

  it "can be converted from gapi" do
    config_gapi = Google::Apis::StorageV1::Bucket::Encryption.new(
      default_kms_key_name: "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    )
    encryption = Google::Cloud::Storage::Bucket::Encryption.from_gapi config_gapi

    encryption.must_be_kind_of Google::Cloud::Storage::Bucket::Encryption
    encryption.default_kms_key.must_equal "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    encryption.to_gapi.to_h.must_equal config_gapi.to_h
  end

  it "can compare using equality" do
    encryption = Google::Cloud::Storage::Bucket::Encryption.new
    config_other = Google::Cloud::Storage::Bucket::Encryption.new
    encryption.default_kms_key = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    config_other.default_kms_key = "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    encryption.must_equal config_other

    config_other.default_kms_key = "projects/1/locations/2/keyRings/3/cryptoKeys/4"
    encryption.wont_equal config_other

    encryption.wont_equal "not a encryption"
  end
end
