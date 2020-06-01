# Copyright 2019 Google, LLC
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

# [START vision_product_search_purge_orphan_products]
require "google/cloud/vision"

# Delete all products not in any product sets.
def product_search_purge_orphan_products project_id = "your-project-id",
                                         location   = "us-west1"

  client = Google::Cloud::Vision.product_search

  parent = client.location_path project: project_id, location: location

  # The operation is irreversible and removes multiple products.
  # The user is required to pass in force=true to actually perform the purge.
  # If force is not set to true, the service raises an exception.
  force = true

  # The purge operation is async.
  operation = client.purge_products parent:                 parent,
                                    force:                  force,
                                    delete_orphan_products: true

  puts "Processing operation name: #{operation.name}"
  operation.wait_until_done! # Waits for the operation to complete

  puts "Orphan products deleted."
end
# [END vision_product_search_purge_orphan_products]

product_search_purge_orphan_products(*ARGV) if $PROGRAM_NAME == __FILE__
