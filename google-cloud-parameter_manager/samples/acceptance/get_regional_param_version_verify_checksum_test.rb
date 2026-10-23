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

describe "#get_regional_param_version_verify_checksum", :regional_parameter_manager_snippet do
  before do
    client.create_parameter parent: location_name, parameter_id: parameter_id
    client.create_parameter_version parent: parameter_name, parameter_version_id: version_id,
                                    parameter_version: { payload: { data: "hello world!", data_crc32c: Digest::CRC32c.checksum("hello world!") } }
  end

  it "gets a regional parameter version and verifies its checksum" do
    sample = SampleLoader.load "get_regional_param_version_verify_checksum.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, parameter_id: parameter_id, version_id: version_id
    end

    assert_equal "Verified checksum for regional parameter version #{parameter_version_name}\n" \
                 "Checksum source: USER_SPECIFIED\n",
                 out
  end
end
