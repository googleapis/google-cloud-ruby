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
require "minitest/spec"
require "minitest/focus"
require "minitest/hooks/default"

require "google/cloud/monitoring"
require "google/cloud/monitoring/v3"

class MonitoringSpec < Minitest::Spec
  register_spec_type self do |_desc, *more_desc|
    more_desc.include? :monitoring
  end

  let(:client) { Google::Cloud::Monitoring.metric_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] }
  let(:project_path) { client.project_path project: project_id }
  let(:random_id) { rand(36**10).to_s(36) }

  def retry_block count
    secs = 1
    loop do
      begin
        return yield
      rescue StandardError => e
        raise e if secs >= count
      end
      sleep secs
      secs += 1
    end
  end
end
