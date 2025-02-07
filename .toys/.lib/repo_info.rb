# Copyright 2021 Google LLC
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

module RepoInfo
  ##
  # Wrapper gems that are handwritten or live in a different repo.
  #
  NON_GENERATED_WRAPPERS = {
    "google-cloud-bigquery" => :handwritten,
    "google-cloud-bigtable" => :handwritten,
    "google-cloud-datastore" => :handwritten,
    "google-cloud-error_reporting" => :handwritten,
    "google-cloud-firestore" => :handwritten,
    "google-cloud-logging" => :handwritten,
    "google-cloud-pubsub" => :handwritten,
    "google-cloud-resource_manager" => :handwritten,
    "google-cloud-storage" => :handwritten,
    "google-cloud-trace" => :handwritten,
    "google-cloud-spanner" => :external
  }

  ##
  # Mapping from the normally expected wrapper name to the actual wrapper gem
  # that covers it.
  #
  WRAPPER_MAPPING = {
    "google-cloud-beyond_corp-app_connections" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-app_connectors" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-app_gateways" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-client_connector_services" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-client_gateways" => "google-cloud-beyond_corp",
    "google-cloud-bigtable" => "google-cloud-bigtable",
    "google-cloud-bigtable-admin" => "google-cloud-bigtable",
    "google-cloud-datastore" => "google-cloud-datastore",
    "google-cloud-datastore-admin" => "google-cloud-datastore",
    "google-cloud-firestore" => "google-cloud-firestore",
    "google-cloud-firestore-admin" => "google-cloud-firestore",
    "google-cloud-monitoring" => "google-cloud-monitoring",
    "google-cloud-monitoring-dashboard" => "google-cloud-monitoring",
    "google-cloud-monitoring-metrics_scope" => "google-cloud-monitoring",
    "google-cloud-run" => "google-cloud-run-client",
    "google-cloud-spanner-admin-database" => "google-cloud-spanner",
    "google-cloud-spanner-admin-instance" => "google-cloud-spanner",
    "google-cloud-spanner" => "google-cloud-spanner",
    "google-cloud-workflows" => "google-cloud-workflows",
    "google-cloud-workflows-executions" => "google-cloud-workflows",
    "google-iam" => "google-iam-client",
  }

  ##
  # Gems that are not normal clients (generated GAPICs, wrappers, or veneers
  # that wrap GAPICs) and should be treated specially.
  #
  SPECIAL_GEMS = [
    "gcloud",
    "google-cloud",
    "google-cloud-core",
    "google-cloud-dns",
    "google-cloud-errors",
    "google-cloud-location",
    "google-iam-v1",
    "google-iam-v1beta",
    "grafeas-client",
    "stackdriver",
    "stackdriver-core"
  ]

  ##
  # Gems that should be pinned to prerelease even though the service version
  # suggests GA status.
  #
  PINNED_PRERELEASE_GEMS = [
    "google-cloud-resource_manager",
    "google-cloud-trace",
    "google-iam-v2"
  ]
end
