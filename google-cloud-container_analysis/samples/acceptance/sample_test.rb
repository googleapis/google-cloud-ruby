# Copyright 2020 Google LLC
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
require_relative "../sample"

require "pathname"
require "securerandom"

describe "Container Analysis API samples" do
  let(:client) { Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client }

  def new_note_id
    test_name = name.gsub(/\W/, "-")
    uuid = SecureRandom.uuid
    note_id = "note-#{uuid}-#{test_name}"
    @note_ids_to_delete << note_id
    note_id
  end

  before do
    test_name = name.tr " ", "-"
    uuid = SecureRandom.uuid
    @image_url = "https://gcr.io/#{test_name}/#{uuid}"
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @try_limit = 10
    @sleep_time = 1
    @subscription_id = "occurrence-subscription-#{uuid}"
    @uuid = uuid
    @note_ids_to_delete = []
  end

  after do
    @note_ids_to_delete.each do |note_id|
      delete_note project_id: @project_id, note_id: note_id
    rescue StandardError
      puts "Failed to delete #{note_id}"
    end
  end

  it "runs get_note and delete_note" do
    note_id = new_note_id
    note_obj = create_note project_id: @project_id, note_id: note_id

    result_note = get_note project_id: @project_id, note_id: note_id
    _(result_note.name).must_equal note_obj.name

    delete_note project_id: @project_id, note_id: note_id
    assert_raises Google::Cloud::Error do
      get_note project_id: @project_id, note_id: note_id
    end
  end

  it "runs create_occurrence and delete_occurrence" do
    note_id = new_note_id
    create_note project_id: @project_id, note_id: note_id

    result = create_occurrence resource_url:       @image_url,
                               note_id:            note_id,
                               occurrence_project: @project_id,
                               note_project:       @project_id
    _(result).wont_be_nil
    _(result.resource_uri).must_equal @image_url

    occurrence_id = Pathname.new(result.name).basename.to_s
    retrieved = get_occurrence occurrence_id: occurrence_id, project_id: @project_id
    _(retrieved).wont_be_nil
    _(retrieved.name).must_equal result.name

    delete_occurrence occurrence_id: occurrence_id, project_id: @project_id
    assert_raises Google::Cloud::Error do
      get_occurrence occurrence_id: occurrence_id, project_id: @project_id
    end
  end

  it "runs get_occurrences_for_image" do
    count = get_occurrences_for_image resource_url: @image_url, project_id: @project_id
    _(count).must_equal 0

    note_id = new_note_id
    create_note project_id: @project_id, note_id: note_id
    create_occurrence resource_url:       @image_url,
                      note_id:            note_id,
                      occurrence_project: @project_id,
                      note_project:       @project_id
    try = 0
    while count != 1 && try < @try_limit
      sleep @sleep_time
      count = get_occurrences_for_image resource_url: @image_url, project_id: @project_id
      try += 1
    end
    _(count).must_equal 1
  end

  it "runs get_occurrences_for_note" do
    note_id = new_note_id
    create_note project_id: @project_id, note_id: note_id

    count = get_occurrences_for_note note_id: note_id, project_id: @project_id
    _(count).must_equal 0

    create_occurrence resource_url:       @image_url,
                      note_id:            note_id,
                      occurrence_project: @project_id,
                      note_project:       @project_id
    try = 0
    while count != 1 && try < @try_limit
      sleep @sleep_time
      count = get_occurrences_for_note note_id: note_id, project_id: @project_id
      try += 1
    end
    _(count).must_equal 1
  end

  it "runs occurrence_pubsub" do
    # create topic if needed
    pubsub = Google::Cloud::Pubsub.new project: @project_id
    topic_name = "container-analysis-occurrences-v1"
    topic = pubsub.topic topic_name
    pubsub.create_topic topic_name unless topic&.exists?

    try = 0
    count = -1
    # empty the pubsub queue
    while count != 0 && try < @try_limit
      count = occurrence_pubsub subscription_id: @subscription_id, timeout_seconds: 5, project_id: @project_id
      try += 1
    end
    _(count).must_equal 0

    note_id = new_note_id
    create_note project_id: @project_id, note_id: note_id

    # test pubsub while creating occurrences
    try = 0
    total_num = 3
    while count < total_num && try < @try_limit
      # start the pubsub function listening in its own thread
      t2 = Thread.new do
        timeout = (total_num * @sleep_time) + 10
        Thread.current[:output] = occurrence_pubsub subscription_id: @subscription_id,
                                                    timeout_seconds: timeout,
                                                    project_id:      @project_id
      end
      sleep 5
      # create a number of test occurrences
      total_num.times do
        created = create_occurrence resource_url:       @image_url,
                                    note_id:            note_id,
                                    occurrence_project: @project_id,
                                    note_project:       @project_id
        sleep @sleep_time
        occurrence_id = Pathname.new(created.name).basename.to_s
        delete_occurrence occurrence_id: occurrence_id, project_id: @project_id
      end
      # check to ensure the numbers match
      # Note: because it is possible multiple tests may be running at a time,
      # we check that we received pubsub messages for AT LEAST the number of
      # occurrences created, rather than exactly the number.
      t2.join
      count = t2[:output]
    end
    _(count).must_be :>=, total_num
  end

  it "runs poll_discovery_finished" do
    assert_raises RuntimeError do
      poll_discovery_finished resource_url:    @image_url,
                              project_id:      @project_id,
                              timeout_seconds: 5
    end

    # create discovery occurrence
    parent = client.project_path project: @project_id
    note = {
      discovery: {
        analysis_kind: :DISCOVERY
      }
    }
    note_id = new_note_id
    client.create_note parent: parent, note_id: note_id, note: note
    formatted_note = client.note_path project: @project_id, note: note_id
    occurrence = {
      note_name:    formatted_note,
      resource_uri: @image_url,
      discovery:    {
        analysis_status: :FINISHED_SUCCESS
      }
    }
    created = client.create_occurrence parent: parent, occurrence: occurrence

    # poll again
    found = poll_discovery_finished resource_url:    @image_url,
                                    project_id:      @project_id,
                                    timeout_seconds: 5
    _(found.name).must_equal created.name
    _(found.discovery.analysis_status).must_equal :FINISHED_SUCCESS
  end

  it "runs find_vulnerabilities_for_image" do
    result_list = find_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
    c = result_list.count
    _(c).must_equal 0

    # create vulnerability occurrence
    note_id = new_note_id
    create_note project_id: @project_id, note_id: note_id
    create_occurrence resource_url:       @image_url,
                      note_id:            note_id,
                      occurrence_project: @project_id,
                      note_project:       @project_id
    try = 0
    while c != 1 && try < @try_limit
      sleep @sleep_time
      result_list = find_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
      c = result_list.count
      try += 1
    end
    _(c).must_equal 1
  end

  it "runs find_high_severity_vulnerabilities_for_image" do
    result_list = find_high_severity_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
    _(result_list).must_be_empty
    sleep 1

    # create vulnerability occurrence
    note_id = new_note_id
    create_note project_id: @project_id, note_id: note_id
    create_occurrence resource_url:       @image_url,
                      note_id:            note_id,
                      occurrence_project: @project_id,
                      note_project:       @project_id
    result_list = find_high_severity_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
    _(result_list).must_be_empty
    sleep 1

    # create critical severity occurrence
    critical_note_id = new_note_id
    parent = client.project_path project: @project_id
    note = {
      vulnerability: {
        severity: :CRITICAL,
        details:  [
          {
            affected_cpe_uri:       "your-uri-here",
            affected_package:       "your-package-here",
            affected_version_start: { kind: :MINIMUM },
            fixed_version:          { kind: :MAXIMUM }
          }
        ]
      }
    }
    client.create_note parent: parent, note_id: critical_note_id, note: note
    note_name = client.note_path project: @project_id, note: critical_note_id
    occurrence = {
      note_name:     note_name,
      resource_uri:  @image_url,
      vulnerability: {
        effective_severity: :CRITICAL,
        package_issue:      [
          {
            affected_cpe_uri: "your-uri-here",
            affected_package: "your-package-here",
            affected_version: { kind: :MINIMUM },
            fixed_version:    { kind: :MAXIMUM }
          }
        ]
      }
    }
    client.create_occurrence parent: parent, occurrence: occurrence

    # Retry until we find an image with a high severity vulnerability
    retry_count = 0
    vulnerability_count = 0
    while vulnerability_count != 1 && retry_count < @try_limit
      sleep @sleep_time
      result_list = find_high_severity_vulnerabilities_for_image resource_url: @image_url, project_id: @project_id
      vulnerability_count = result_list.count
      retry_count += 1
    end
    _(vulnerability_count).must_equal 1
  end
end
