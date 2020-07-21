# Copyright 2016 Google LLC
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

describe Google::Cloud::Logging::Entry, :severity, :mock_logging do
  let(:entry_grpc) { Google::Cloud::Logging::V2::LogEntry.new random_entry_hash }
  let(:entry) { Google::Cloud::Logging::Entry.from_grpc entry_grpc }

  it "has the correct helpers for DEFAULT" do
    entry.severity = :DEFAULT
    _(entry).must_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for DEBUG" do
    entry.severity = :DEBUG
    _(entry).wont_be :default?
    _(entry).must_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for INFO" do
    entry.severity = :INFO
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).must_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for NOTICE" do
    entry.severity = :NOTICE
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).must_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for WARNING" do
    entry.severity = :WARNING
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).must_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for ERROR" do
    entry.severity = :ERROR
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).must_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for CRITICAL" do
    entry.severity = :CRITICAL
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).must_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for ALERT" do
    entry.severity = :ALERT
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).must_be :alert?
    _(entry).wont_be :emergency?
  end

  it "has the correct helpers for EMERGENCY" do
    entry.severity = :EMERGENCY
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).must_be :emergency?
  end

  it "allows DEFAULT to be set" do
    entry.severity = :DEBUG
    _(entry).wont_be :default?
    entry.default!
    _(entry).must_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows DEBUG to be set" do
    _(entry).wont_be :debug?
    entry.debug!
    _(entry).wont_be :default?
    _(entry).must_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows INFO to be set" do
    _(entry).wont_be :info?
    entry.info!
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).must_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows NOTICE to be set" do
    _(entry).wont_be :notice?
    entry.notice!
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).must_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows WARNING to be set" do
    _(entry).wont_be :warning?
    entry.warning!
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).must_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows ERROR to be set" do
    _(entry).wont_be :error?
    entry.error!
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).must_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows CRITICAL to be set" do
    _(entry).wont_be :critical?
    entry.critical!
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).must_be :critical?
    _(entry).wont_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows ALERT to be set" do
    _(entry).wont_be :alert?
    entry.alert!
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).must_be :alert?
    _(entry).wont_be :emergency?
  end

  it "allows EMERGENCY to be set" do
    _(entry).wont_be :emergency?
    entry.emergency!
    _(entry).wont_be :default?
    _(entry).wont_be :debug?
    _(entry).wont_be :info?
    _(entry).wont_be :notice?
    _(entry).wont_be :warning?
    _(entry).wont_be :error?
    _(entry).wont_be :critical?
    _(entry).wont_be :alert?
    _(entry).must_be :emergency?
  end
end
