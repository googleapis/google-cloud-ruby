# Copyright 2016 Google LLC
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

describe Google::Cloud::Logging::Entry, :severity, :mock_logging do
  let(:entry_json) { random_entry_hash.to_json }
  let(:entry_grpc) { Google::Logging::V2::LogEntry.decode_json entry_json }
  let(:entry) { Google::Cloud::Logging::Entry.from_grpc entry_grpc }

  it "has the correct helpers for DEFAULT" do
    entry.severity = :DEFAULT
    entry.must_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for DEBUG" do
    entry.severity = :DEBUG
    entry.wont_be :default?
    entry.must_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for INFO" do
    entry.severity = :INFO
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.must_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for NOTICE" do
    entry.severity = :NOTICE
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.must_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for WARNING" do
    entry.severity = :WARNING
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.must_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for ERROR" do
    entry.severity = :ERROR
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.must_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for CRITICAL" do
    entry.severity = :CRITICAL
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.must_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for ALERT" do
    entry.severity = :ALERT
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.must_be :alert?
    entry.wont_be :emergency?
  end

  it "has the correct helpers for EMERGENCY" do
    entry.severity = :EMERGENCY
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.must_be :emergency?
  end

  it "allows DEFAULT to be set" do
    entry.severity = :DEBUG
    entry.wont_be :default?
    entry.default!
    entry.must_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "allows DEBUG to be set" do
    entry.wont_be :debug?
    entry.debug!
    entry.wont_be :default?
    entry.must_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "allows INFO to be set" do
    entry.wont_be :info?
    entry.info!
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.must_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "allows NOTICE to be set" do
    entry.wont_be :notice?
    entry.notice!
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.must_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "allows WARNING to be set" do
    entry.wont_be :warning?
    entry.warning!
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.must_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "allows ERROR to be set" do
    entry.wont_be :error?
    entry.error!
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.must_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "allows CRITICAL to be set" do
    entry.wont_be :critical?
    entry.critical!
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.must_be :critical?
    entry.wont_be :alert?
    entry.wont_be :emergency?
  end

  it "allows ALERT to be set" do
    entry.wont_be :alert?
    entry.alert!
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.must_be :alert?
    entry.wont_be :emergency?
  end

  it "allows EMERGENCY to be set" do
    entry.wont_be :emergency?
    entry.emergency!
    entry.wont_be :default?
    entry.wont_be :debug?
    entry.wont_be :info?
    entry.wont_be :notice?
    entry.wont_be :warning?
    entry.wont_be :error?
    entry.wont_be :critical?
    entry.wont_be :alert?
    entry.must_be :emergency?
  end
end
