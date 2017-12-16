# Copyright 2016 Google LLC
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


require "google/cloud"

Gcloud = Google::Cloud

##
# # Gcloud
#
# #### The `gcloud` gem and `Gcloud` namespace are now deprecated.
#
# The current `gcloud` gem exists only to facilitate the timely transition of
# legacy code from the deprecated `Gcloud` namespace to the new `Google::Cloud`
# namespace. Please see the top-level project [README](../README.md) for current
# information about using the `google-cloud` umbrella gem and the individual
# service gems.
#
# This module exists to facilitate the transition of legacy code using the
# `Gcloud` namespace to the current `Google::Cloud` namespace.
#
# ## BigQuery Example
#
# ```ruby
# require "gcloud"
#
# gcloud = Gcloud.new
# bigquery = gcloud.bigquery
# dataset = bigquery.dataset "my-dataset"
# table = dataset.table "my-table"
# table.data.each do |row|
#   puts row
# end
# ```
#
module Gcloud
end
