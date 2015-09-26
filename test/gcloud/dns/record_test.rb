# Copyright 2015 Google Inc. All rights reserved.
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

require "helper"

describe Gcloud::Dns::Record, :mock_dns do
  # Create a record object with the project's mocked connection object
  let(:record_name) { "example.com." }
  let(:record_ttl)  { 86400 }
  let(:record_type) { "A" }
  let(:record_data) { ["1.2.3.4"] }
  let(:record_hash) { random_record_hash record_name, record_type, record_ttl, record_data }
  let(:record) { Gcloud::Dns::Record.from_gapi record_hash }

  it "knows its attributes" do
    record.name.must_equal record_name
    record.ttl.must_equal  record_ttl
    record.type.must_equal record_type
    record.data.must_equal record_data
  end
end
