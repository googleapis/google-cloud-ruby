# Copyright 2024 Google LLC
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
require_relative "../event_driven_gcs_transfer"
require "google/cloud/pubsub"


describe "Storage Transfer Service Event Driven Gcs Transfer" do
  let(:project) { Google::Cloud::Storage.new }
  let(:source_bucket) { create_bucket_helper random_bucket_name }
  let(:sink_bucket) { create_bucket_helper random_bucket_name }
  let :pubsub do
    Google::Cloud::Pubsub.new
  end
  let :topic do
    pubsub.create_topic "ruby_storagetransfer_topic_#{SecureRandom.hex}"
  end
  let(:subscription) { topic.subscribe "ruby_storagetransfer_subscription_#{SecureRandom.hex}" }
  let :destroy_topic do
    topic.subscriptions.each(&:delete)
    topic.delete
    puts "Destroy topic #{topic.name}"
  end
  let(:dummy_file_name) { "ruby_storagetransfer_samples_dummy_#{SecureRandom.hex}.txt" }
  let(:create_dummy_file) {
    source_bucket.create_file StringIO.new("this is dummy"), dummy_file_name
  }
  let(:custom_attrs) { { "foo" => "bar" } }
  let(:event_types) { ["OBJECT_FINALIZE"] }
  let(:filename_prefix) { "my-prefix" }
  let(:payload) { "NONE" }
  before do
    grant_pubsub_permissions project_id: project.project_id, topic: topic, subscription: subscription
    create_dummy_file
    grant_sts_permissions project_id: project.project_id, bucket_name: source_bucket.name
    grant_sts_permissions project_id: project.project_id, bucket_name: sink_bucket.name

    source_bucket.create_notification topic.name, custom_attrs: custom_attrs,
                                                            event_types: event_types,
                                                            prefix: filename_prefix,
                                                            payload: payload
  end
  after do
    destroy_topic
    delete_bucket_helper source_bucket.name
    delete_bucket_helper sink_bucket.name
  end

  it "creates a transfer job" do
    out, _err = capture_io do
      create_event_driven_gcs_transfer project_id: project.project_id, gcs_source_bucket: source_bucket.name, gcs_sink_bucket: sink_bucket.name, pubsub_id: subscription.name
    end
    assert_includes out, "transferJobs"
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end
end
