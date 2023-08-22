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
  # Gems that have different names than expected, or are not present in this
  # repository (either because they are in a different repository, or because
  # they intentionally do not exist but should be treated as though they do.)
  #
  UNUSUAL_NAMES = {
    "google-cloud-run" => "google-cloud-run-client",
    "google-cloud-spanner" => :external,
    "google-iam" => :none
  }

  ##
  # Multi-wrappers, where the key is the normally expected wrapper name, and
  # the value is the actual multi-wrapper gem that covers it.
  #
  MULTI_WRAPPERS = {
    "google-cloud-beyond_corp-app_connections" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-app_connectors" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-app_gateways" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-client_connector_services" => "google-cloud-beyond_corp",
    "google-cloud-beyond_corp-client_gateways" => "google-cloud-beyond_corp",
    "google-cloud-bigtable-admin" => "google-cloud-bigtable",
    "google-cloud-datastore-admin" => "google-cloud-datastore",
    "google-cloud-firestore-admin" => "google-cloud-firestore",
    "google-cloud-monitoring-dashboard" => "google-cloud-monitoring",
    "google-cloud-monitoring-metrics_scope" => "google-cloud-monitoring",
    "google-cloud-spanner-admin-database" => "google-cloud-spanner",
    "google-cloud-spanner-admin-instance" => "google-cloud-spanner",
    "google-cloud-spanner" => "google-cloud-spanner",
    "google-cloud-workflows-executions" => "google-cloud-workflows",
    "google-iam" => "google-iam"
  }

  ##
  # Gems that are not clients (neither generated GAPICs, wrappers, or veneers)
  #
  SPECIAL_GEMS = [
    "gcloud",
    "google-cloud",
    "google-cloud-core",
    "google-cloud-errors",
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
