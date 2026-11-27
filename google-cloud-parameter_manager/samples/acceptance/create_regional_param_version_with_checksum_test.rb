# Copyright 2026 Google LLC
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

require "digest/crc32c"

require_relative "regional_helper"

describe "#create_regional_param_version_with_checksum", :regional_parameter_manager_snippet do
  before do
    client.create_parameter parent: location_name, parameter_id: parameter_id
  end

  it "creates a regional parameter version with a checksum" do
    sample = SampleLoader.load "create_regional_param_version_with_checksum.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, parameter_id: parameter_id, version_id: version_id
    end

    assert_equal "Created regional parameter version #{parameter_version_name}\nChecksum source: USER_SPECIFIED\n", out
  end

  it "rejects a regional parameter version with a mismatched checksum" do
    err = assert_raises Google::Cloud::InvalidArgumentError do
      client.create_parameter_version parent: parameter_name, parameter_version_id: version_id,
                                      parameter_version: { payload: { data: "hello world!", data_crc32c: 1 } }
    end
    assert_includes err.message, "The CRC32C checksum of the provided payload does not match the provided value"
  end
end
