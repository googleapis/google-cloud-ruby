# Copyright 2025 Google LLC
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

require "bigquery_helper"
require "securerandom"
require "json"
require "httpclient"

describe "BigQuery Large JSON", :bigquery do
  let(:dataset_id) { "ruby_acceptance_#{SecureRandom.hex(4)}" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id, location: "US"
    end
    d
  end
  let(:table_id) { "large_json_test_#{SecureRandom.hex(4)}" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.string "id", mode: :required
        schema.json "data", mode: :required
      end
    end
    t
  end

  after do
    dataset.delete force: true
  end

  it "inserts a large JSON object successfully" do
    # Generate a 8MB JSON object
    large_string = "a" * (8 * 1024 * 1024)
    json_data = { "large_string" => large_string }.to_json
    puts "Generated JSON size: #{json_data.bytesize / (1024 * 1024)} MB"

    row = { "id" => SecureRandom.uuid, "data" => json_data }
    
    begin
      table.insert [row]
    rescue Google::Cloud::Error => e
      puts "Google::Cloud::Error encountered: #{e.message}"
      puts "Error body: #{e.body}"
      raise
    end
  end
end
