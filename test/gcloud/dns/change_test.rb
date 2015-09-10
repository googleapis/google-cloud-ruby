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

describe Gcloud::Dns::Change, :mock_dns do
  let(:change) { Gcloud::Dns::Change.from_gapi random_change_hash, dns.connection }

  it "knows its attributes" do
    change.id.must_equal "dns-change-1234567890"
    change.additions.must_be :empty?
    change.deletions.must_be :empty?
    change.status.must_equal "done"
    change.must_be :done?
    change.wont_be :pending?

    start_time = Time.new 2015, 1, 1, 0, 0, 0, 0
    change.started_at.must_equal start_time
  end

  it "can represent a pending change" do
    pending_change_hash = random_change_hash
    pending_change_hash["status"] = "pending"
    pending_change = Gcloud::Dns::Change.from_gapi pending_change_hash, dns.connection

    pending_change.id.must_equal "dns-change-1234567890"
    pending_change.additions.must_be :empty?
    pending_change.deletions.must_be :empty?
    pending_change.status.must_equal "pending"
    pending_change.wont_be :done?
    pending_change.must_be :pending?

    start_time = Time.new 2015, 1, 1, 0, 0, 0, 0
    pending_change.started_at.must_equal start_time
  end
end
