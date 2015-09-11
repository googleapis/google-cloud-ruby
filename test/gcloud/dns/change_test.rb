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
  let(:zone_name) { "example-zone" }
  let(:zone_dns) { "example.com." }
  let(:zone_hash) { random_zone_hash zone_name, zone_dns }
  let(:zone) { Gcloud::Dns::Zone.from_gapi zone_hash, dns.connection }
  let(:change) { Gcloud::Dns::Change.from_gapi done_change_hash, zone }

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
    pending_change = Gcloud::Dns::Change.from_gapi pending_change_hash, zone

    pending_change.id.must_equal "dns-change-1234567890"
    pending_change.additions.must_be :empty?
    pending_change.deletions.must_be :empty?
    pending_change.status.must_equal "pending"
    pending_change.wont_be :done?
    pending_change.must_be :pending?

    start_time = Time.new 2015, 1, 1, 0, 0, 0, 0
    pending_change.started_at.must_equal start_time
  end

  it "can reload itself" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       pending_change_json(change.id)]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       done_change_json(change.id)]
    end

    change.must_be :done?
    change.reload!
    change.must_be :pending?
    change.reload!
    change.must_be :done?
  end

  it "can reload itself with refresh alias" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       pending_change_json(change.id)]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       done_change_json(change.id)]
    end

    change.must_be :done?
    change.refresh!
    change.must_be :pending?
    change.refresh!
    change.must_be :done?
  end

  it "can wait until done" do
    pending_change = Gcloud::Dns::Change.from_gapi pending_change_hash, zone

    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       pending_change_json(pending_change.id)]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       pending_change_json(pending_change.id)]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       pending_change_json(pending_change.id)]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       pending_change_json(pending_change.id)]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{change.id}" do |env|
      [200, {"Content-Type" => "application/json"},
       done_change_json(pending_change.id)]
    end

    # mock out the sleep method so the test doesn't actually block
    def pending_change.sleep *args
    end

    pending_change.must_be :pending?
    pending_change.wait_until_done!
    pending_change.must_be :done?
  end

  def done_change_hash change_id = nil
    hash = random_change_hash
    hash["id"] = change_id if change_id
    hash
  end

  def pending_change_hash change_id = nil
    hash = done_change_hash change_id
    hash["status"] = "pending"
    hash
  end

  def done_change_json change_id = nil
    done_change_hash(change_id).to_json
  end

  def pending_change_json change_id = nil
    pending_change_hash(change_id).to_json
  end
end
