# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "pp"

# [START bigtable_quickstart]
# Import google bigtable client lib
require "google-cloud-bigtable"

# The name of the Cloud Bigtable instance
INSTANCE_NAME = "my-bigtable-instance"

#  The name of the Cloud Bigtable table
TABLE_NAME = "my-table"

gcloud = Google::Cloud.new
bigtable = gcloud.bigtable

# Get table client
table = bigtable.table(INSTANCE_NAME, TABLE_NAME)

# Read and print row
pp table.read_row("user00000001")
# [END bigtable_quickstart]
