# frozen_string_literal: true

# Copyright 2021 Google LLC
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

describe Google::Cloud::Bigtable::EncryptionInfo, :mock_bigtable do
  let(:kms_key_version) { "projects/my-proj/locations/my-loc/keyRings/my-ring/cryptoKeys/my-key/cryptoKeyVersions/1" }
  let(:status_code) { 0 }
  let(:encryption_info) do
    Google::Cloud::Bigtable::EncryptionInfo.from_grpc encryption_info_grpc
  end
  let(:encryption_info_full) do
    grpc = encryption_info_grpc type: :CUSTOMER_MANAGED_ENCRYPTION, status_code: status_code, kms_key_version: kms_key_version
    Google::Cloud::Bigtable::EncryptionInfo.from_grpc grpc
  end

  it "knows its minimum attributes" do
    _(encryption_info).must_be_kind_of Google::Cloud::Bigtable::EncryptionInfo
    _(encryption_info.encryption_type).must_equal :GOOGLE_DEFAULT_ENCRYPTION
    _(encryption_info.encryption_status).must_be :nil?
    _(encryption_info.kms_key_version).must_be :nil?
  end

  it "knows its full attributes" do
    _(encryption_info_full).must_be_kind_of Google::Cloud::Bigtable::EncryptionInfo
    _(encryption_info_full.encryption_type).must_equal :CUSTOMER_MANAGED_ENCRYPTION
    _(encryption_info_full.encryption_status).must_be_kind_of Google::Cloud::Bigtable::Status
    _(encryption_info_full.encryption_status.code).must_equal status_code
    _(encryption_info_full.encryption_status.description).must_equal "OK"
    _(encryption_info_full.kms_key_version).must_equal kms_key_version
  end
end
