# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "helper"

describe "#remove_param_kms_key", :parameter_manager_snippet do
  before do
    setup_remove_param_kms_keys
  end

  it "Removes a parameter kms_key" do
    sample = SampleLoader.load "remove_param_kms_key.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, parameter_id: parameter_id
    end

    assert_equal "Removed kms_key for parameter projects/#{project_id}/locations/global/" \
                 "parameters/#{parameter_id}\n",
                 out
  end
end

def setup_remove_param_kms_keys
  key = {
    purpose:          :ENCRYPT_DECRYPT,
    version_template: {
      algorithm:        :GOOGLE_SYMMETRIC_ENCRYPTION,
      protection_level: :HSM
    }
  }

  begin
    kms_client.get_key_ring name: key_ring_name
  rescue Google::Cloud::NotFoundError
    kms_client.create_key_ring parent: location_name, key_ring_id: key_ring_id, key_ring: {}
  end

  begin
    kms_client.get_crypto_key name: crypt_key_id1_name
  rescue Google::Cloud::NotFoundError
    kms_client.create_crypto_key parent: key_ring_name, crypto_key_id: crypt_key_id1, crypto_key: key
  end

  parameter = {
    kms_key: crypt_key_id1_name
  }

  client.create_parameter parent: location_name, parameter_id: parameter_id, parameter: parameter
end
