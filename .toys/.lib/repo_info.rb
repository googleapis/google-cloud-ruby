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
  UNUSUAL_WRAPPERS = {
    "google-cloud-bigtable-admin-v2" => "google-cloud-bigtable",
    "google-cloud-datastore-admin-v1" => "google-cloud-datastore",
    "google-cloud-firestore-admin-v1" => "google-cloud-firestore",
    "google-cloud-monitoring-dashboard-v1" => "google-cloud-monitoring",
    "google-cloud-spanner-admin-database-v1" => "google-cloud-spanner",
    "google-cloud-spanner-admin-instance-v1" => "google-cloud-spanner",
    "google-cloud-workflows-executions-v1beta" => "google-cloud-workflows"
  }

  SPECIAL_GEMS = [
    "gcloud",
    "google-cloud",
    "google-cloud-core",
    "google-cloud-errors",
    "grafeas-client",
    "stackdriver",
    "stackdriver-core"
  ]
end
