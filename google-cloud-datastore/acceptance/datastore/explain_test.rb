# frozen_string_literal: true

# Copyright 2024 Google LLC
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

require "datastore_helper"

describe "Datastore Query Explain", :datastore do
  let(:prefix) { "gcloud-explain-#{SecureRandom.hex 4}" }
  let(:kind) { "ExplainTask" }
  let(:tasks) do
    3.times.map do |i|
      dataset.entity "#{prefix}-#{kind}", "#{prefix}-task-#{i}" do |t|
        t["description"] = "explain task #{i}"
        t["done"] = false
      end
    end
  end

  before do
    dataset.save *tasks
    # Ensure the entities are created
    try_with_backoff "getting tasks" do
      entities = dataset.find_all tasks.map(&:key)
      raise "not all tasks created" if entities.count != tasks.count
    end
  end

  after do
    dataset.delete *tasks
  end

  it "returns explain_metrics when analyze is true" do
    query = dataset.query "#{prefix}-#{kind}"
    results = dataset.run query, explain_options: { analyze: true }

    all_results = []
    loop do
      results.each { |r| all_results << r }
      break unless results.next?
      results = results.next
    end

    _(all_results.count).must_equal tasks.count
    _(results.explain_metrics).must_be_kind_of Google::Cloud::Datastore::V1::ExplainMetrics
    _(results.explain_metrics.plan_summary).wont_be_nil
    _(results.explain_metrics.execution_stats.results_returned).must_equal tasks.count
  end

  it "does not return execution stats when analyze is false" do
    query = dataset.query "#{prefix}-#{kind}"
    results = dataset.run query, explain_options: { analyze: false }

    all_results = []
    loop do
      results.each { |r| all_results << r }
      break unless results.next?
      results = results.next
    end

    # If `analyze: false` is passed, the `run` returns no results, just a plan summary
    _(all_results.count).must_equal 0
    _(results.explain_metrics).must_be_kind_of Google::Cloud::Datastore::V1::ExplainMetrics
    _(results.explain_metrics.plan_summary).wont_be_nil
    _(results.explain_metrics.execution_stats).must_be :nil?
  end
end
