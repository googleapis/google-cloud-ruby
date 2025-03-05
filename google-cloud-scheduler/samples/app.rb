# frozen_string_literal: true

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$stdout.sync = true

# [START cloudscheduler_app]
require "sinatra"

set :environment, :production

# Define relative URI for job endpoint
post "/log_payload" do
  # Log the request payload
  data = request.body.read
  puts "Received job with payload: #{data}"
  "Printed job payload: #{data}"
end
# [END cloudscheduler_app]

get "/" do
  # Basic index to verify app is serving
  "Hello World!"
end
