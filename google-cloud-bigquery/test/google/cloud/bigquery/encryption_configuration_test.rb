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

describe Google::Cloud::Bigquery::EncryptionConfiguration do
  it "can be used for KMS keys" do
    config = Google::Cloud::Bigquery::EncryptionConfiguration.new.tap do |e|
      e.gapi.kms_key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    end
    config_gapi = Google::Apis::BigqueryV2::EncryptionConfiguration.new(
      kms_key_name: "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    )

    config.must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    config.kms_key_name.must_equal "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    config.to_gapi.to_h.must_equal config_gapi.to_h
  end

  it "can set KMS keys" do
    config = Google::Cloud::Bigquery::EncryptionConfiguration.new
    config.must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration

    config.kms_key_name =  "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    config.kms_key_name.must_equal "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    config.kms_key_name =  "projects/1/locations/2/keyRings/3/cryptoKeys/4"
    config.kms_key_name.must_equal "projects/1/locations/2/keyRings/3/cryptoKeys/4"
  end

  it "can be converted from gapi" do
    config_gapi = Google::Apis::BigqueryV2::EncryptionConfiguration.new(
      kms_key_name: "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    )
    config = Google::Cloud::Bigquery::EncryptionConfiguration.from_gapi config_gapi

    config.must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    config.kms_key_name.must_equal "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    config.to_gapi.to_h.must_equal config_gapi.to_h
  end

  it "can compare using equality" do
    config = Google::Cloud::Bigquery::EncryptionConfiguration.new
    config_other = Google::Cloud::Bigquery::EncryptionConfiguration.new
    config.kms_key_name =  "projects/a/locations/b/keyRings/c/cryptoKeys/d"
    config_other.kms_key_name =  "projects/a/locations/b/keyRings/c/cryptoKeys/d"

    config.must_equal config_other

    config_other.kms_key_name =  "projects/1/locations/2/keyRings/3/cryptoKeys/4"
    config.wont_equal config_other

    config.wont_equal "not a config"
  end
end
