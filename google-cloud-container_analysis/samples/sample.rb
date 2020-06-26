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


def create_note note_id:, project_id:
  # [START containeranalysis_create_note]
  # note_id    = "A user-specified identifier for the note"
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  parent = client.project_path project: project_id
  note = {
    vulnerability: {
      details: [
        {
          affected_cpe_uri:       "your-uri-here",
          affected_package:       "your-package-here",
          affected_version_start: { kind: :MINIMUM },
          fixed_version:          { kind: :MAXIMUM }
        }
      ]
    }
  }
  response = client.create_note parent: parent, note_id: note_id, note: note
  puts response.name
  ## [END containeranalysis_create_note]
  response
end

def delete_note note_id:, project_id:
  # [START containeranalysis_delete_note]
  # note_id    = "The identifier for the note to delete"
  # project_id = "The Google Cloud project ID of the note to delete"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  name = client.note_path project: project_id, note: note_id
  client.delete_note name: name
  # [END containeranalysis_delete_note]
end

def create_occurrence resource_url:, note_id:, occurrence_project:, note_project:
  # [START containeranalysis_create_occurrence]
  # resource_url       = "The URL of the resource associated with the occurrence."
  #                      # e.g. https://gcr.io/project/image@sha256:123
  # note_id            = "The identifier of the note associated with the occurrence"
  # occurrence_project = "The Google Cloud project ID for the new occurrence"
  # note_project       = "The Google Cloud project ID of the associated note"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client
  note_path = client.note_path project: note_project, note: note_id
  project_path = client.project_path project: occurrence_project

  occurrence = {
    note_name:     note_path,
    resource_uri:  resource_url,
    vulnerability: {
      package_issue: [
        {
          affected_cpe_uri: "your-uri-here:",
          affected_package: "your-package-here",
          affected_version: { kind: :MINIMUM },
          fixed_version:    { kind: :MAXIMUM }
        }
      ]
    }
  }

  response = client.create_occurrence parent: project_path, occurrence: occurrence
  puts response.name
  # [END containeranalysis_create_occurrence]
  response
end

def delete_occurrence occurrence_id:, project_id:
  # [START containeranalysis_delete_occurrence]
  # occurrence_id = "The API-generated ID associated with the occurrence"
  # project_id    = "The Google Cloud project ID of the occurrence to delete"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  name = client.occurrence_path project: project_id, occurrence: occurrence_id
  client.delete_occurrence name: name
  # [END containeranalysis_delete_occurrence]
end

def get_note note_id:, project_id:
  # [START containeranalysis_get_note]
  # note_id    = "The identifier for the note to retrieve"
  # project_id = "The Google Cloud project ID of the note to retrieve"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  name = client.note_path project: project_id, note: note_id
  response = client.get_note name: name
  puts response.name
  # [END containeranalysis_get_note]
  response
end

def get_occurrence occurrence_id:, project_id:
  # [START containeranalysis_get_occurrence]
  # occurrence_id = "The API-generated ID associated with the occurrence"
  # project_id    = "The Google Cloud project ID of the occurrence to retrieve"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  name = client.occurrence_path project: project_id, occurrence: occurrence_id
  response = client.get_occurrence name: name
  puts response.name
  # [END containeranalysis_get_occurrence]
  response
end

def get_occurrences_for_image resource_url:, project_id:
  # [START containeranalysis_occurrences_for_image]
  # resource_url = "The URL of the resource associated with the occurrence."
  #                # e.g. https://gcr.io/project/image@sha256:123"
  # project_id   = "The Google Cloud project ID of the occurrences to retrieve"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  parent = client.project_path project: project_id
  filter = "resourceUrl = \"#{resource_url}\""
  count = 0
  client.list_occurrences(parent: parent, filter: filter).each do |occurrence|
    # Process occurrence here
    puts occurrence
    count += 1
  end
  puts "Found #{count} occurrences"
  # [END containeranalysis_occurrences_for_image]
  count
end

def get_occurrences_for_note note_id:, project_id:
  # [START containeranalysis_occurrences_for_note]
  # note_id    = "The identifier for the note to query"
  # project_id = "The Google Cloud project ID of the occurrences to retrieve"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  name = client.note_path project: project_id, note: note_id
  count = 0
  client.list_note_occurrences(name: name).each do |occurrence|
    # Process occurrence here
    puts occurrence
    count += 1
  end
  puts "Found #{count} occurrences"
  # [END containeranalysis_occurrences_for_image]
  count
end

def get_discovery_info resource_url:, project_id:
  # [START containeranalysis_discovery_info]
  # resource_url = "The URL of the resource associated with the occurrence."
  #                # e.g. https://gcr.io/project/image@sha256:123
  # project_id   = "The Google Cloud project ID of the occurrences to retrieve"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  parent = client.project_path project: project_id
  filter = "kind = \"DISCOVERY\" AND resourceUrl = \"#{resource_url}\""
  client.list_occurrences(parent: parent, filter: filter).each do |occurrence|
    # Process discovery occurrence here
    puts occurrence
  end
  # [END containeranalysis_discovery_info]
end

def occurrence_pubsub subscription_id:, timeout_seconds:, project_id:
  # [START containeranalysis_pubsub]
  # subscription_id = "A user-specified identifier for the new subscription"
  # timeout_seconds = "The number of seconds to listen for new Pub/Sub messages"
  # project_id      = "Your Google Cloud project ID"

  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id
  topic = pubsub.topic "container-analysis-occurrences-v1"
  subscription = topic.subscribe subscription_id

  count = 0
  subscriber = subscription.listen do |received_message|
    count += 1
    # Process incoming occurrence here
    puts "Message #{count}: #{received_message.data}"
    received_message.acknowledge!
  end
  subscriber.start
  # Wait for incomming occurrences
  sleep timeout_seconds
  subscriber.stop.wait!
  subscription.delete
  # Print and return the total number of Pub/Sub messages received
  puts "Total Messages Received: #{count}"
  count
  # [END containeranalysis_pubsub]
end

# rubocop:disable Metrics/MethodLength

def poll_discovery_finished resource_url:, timeout_seconds:, project_id:
  # [START containeranalysis_poll_discovery_occurrence_finished]
  # resource_url    = "The URL of the resource associated with the occurrence."
  #                   # e.g. https://gcr.io/project/image@sha256:123
  # timeout_seconds = "The number of seconds to wait for the discovery occurrence"
  # project_id      = "Your Google Cloud project ID"

  require "google/cloud/container_analysis"

  deadline = Time.now + timeout_seconds

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client
  parent = client.project_path project: project_id

  # Find the discovery occurrence using a filter string
  discovery_occurrence = nil
  while discovery_occurrence.nil?
    begin
      filter = "resourceUrl=\"#{resource_url}\" " \
               'AND noteProjectId="goog-analysis" ' \
               'AND noteId="PACKAGE_VULNERABILITY"'
      # [END containeranalysis_poll_discovery_occurrence_finished]
      # The above filter isn't testable, since it looks for occurrences in a
      # locked down project. Fall back to a more permissive filter for testing
      filter = "kind = \"DISCOVERY\" AND resourceUrl = \"#{resource_url}\""
      # [START containeranalysis_poll_discovery_occurrence_finished]
      # Only the discovery occurrence should be returned for the given filter
      discovery_occurrence = client.list_occurrences(parent: parent, filter: filter).first
    rescue StandardError # If there is an error, keep trying until the deadline
      puts "discovery occurrence not yet found"
    ensure
      # check for timeout
      sleep 1
      raise "Timeout while retrieving discovery occurrence." if Time.now > deadline
    end
  end

  # Wait for the discovery occurrence to enter a terminal state
  status = Grafeas::V1::DiscoveryOccurrence::AnalysisStatus::PENDING
  until [:FINISHED_SUCCESS, :FINISHED_FAILED, :FINISHED_UNSUPPORTED].include? status
    # Update occurrence
    begin
      updated = client.get_occurrence name: discovery_occurrence.name
      status = updated.discovery.analysis_status
    rescue StandardError # If there is an error, keep trying until the deadline
      puts "discovery occurrence not yet in terminal state"
    ensure
      # check for timeout
      sleep 1
      raise "Timeout while retrieving discovery occurrence." if Time.now > deadline
    end
  end
  puts "Found discovery occurrence #{updated.name}."
  puts "Status: #{updated.discovery.analysis_status}"
  # [END containeranalysis_poll_discovery_occurrence_finished]
  updated
end

# rubocop:enable Metrics/MethodLength

def find_vulnerabilities_for_image resource_url:, project_id:
  # [START containeranalysis_vulnerability_occurrences_for_image]
  # resource_url = "The URL of the resource associated with the occurrence
  #                e.g. https://gcr.io/project/image@sha256:123"
  # project_id   = "The Google Cloud project ID of the vulnerabilities to find"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  parent = client.project_path project: project_id
  filter = "resourceUrl = \"#{resource_url}\" AND kind = \"VULNERABILITY\""
  client.list_occurrences parent: parent, filter: filter
  # [END containeranalysis_vulnerability_occurrences_for_image]
end

def find_high_severity_vulnerabilities_for_image resource_url:, project_id:
  # [START containeranalysis_filter_vulnerability_occurrences]
  # resource_url = "The URL of the resource associated with the occurrence,
  #                 e.g. https://gcr.io/project/image@sha256:123"
  # project_id   = "The Google Cloud project ID of the vulnerabilities to find"

  require "google/cloud/container_analysis"

  # Initialize the client
  client = Google::Cloud::ContainerAnalysis.container_analysis.grafeas_client

  parent = client.project_path project: project_id
  filter = "resourceUrl = \"#{resource_url}\" AND kind = \"VULNERABILITY\""
  vulnerability_list = client.list_occurrences parent: parent, filter: filter
  # Filter the list to include only "high" and "critical" vulnerabilities
  vulnerability_list.select do |item|
    [:HIGH, :CRITICAL].include? item.vulnerability.effective_severity
  end
  # [END containeranalysis_filter_vulnerability_occurrences]
end
