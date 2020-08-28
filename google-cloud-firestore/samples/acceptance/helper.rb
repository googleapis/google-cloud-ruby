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

require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "google/cloud/firestore"
require "securerandom"

def delete_collection_test collection_name:, project_id:
  firestore = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_name
  query = cities_ref
  query.get do |document_snapshot|
    document_ref = document_snapshot.ref
    document_ref.delete
  end
end

def random_name prefix
  "#{prefix}_#{SecureRandom.hex 4}"
end
