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

require_relative "../notification"
require "google/cloud/errors"
require "google/cloud/security_center"

def retry_resource_exhaustion
  last_error = nil
  5.times do
    return yield
  rescue Google::Cloud::ResourceExhaustedError => e
    last_error = e
    puts "\n#{e} Gonna try again"
    sleep rand(1..5)
  end
  raise last_error
end
