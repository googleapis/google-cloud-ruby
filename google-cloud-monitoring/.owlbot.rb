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

# Modify the gemspec so it includes the dashboard and metricsscope gems
OwlBot.modifier path: "google-cloud-monitoring.gemspec" do |content|
  content.sub(%r{\n  gem.add_dependency "google-cloud-monitoring-v3", "([^\n]+)"\n\n}m,
              "\n  gem.add_dependency \"google-cloud-monitoring-v3\", \"\\1\"\n" \
                "  gem.add_dependency \"google-cloud-monitoring-dashboard-v1\", \">= 0.5\", \"< 2.a\"\n" \
                "  gem.add_dependency \"google-cloud-monitoring-metrics_scope-v1\", \">= 0.0\", \"< 2.a\"\n\n")
end

# Modify the Gemfile so includes the dashboard and metricsscope gems
OwlBot.modifier path: "Gemfile" do |content|
  content.sub("\ngem \"google-cloud-monitoring-v3\", path: \"../google-cloud-monitoring-v3\"\n",
              "\ngem \"google-cloud-monitoring-v3\", path: \"../google-cloud-monitoring-v3\"\n" \
                "gem \"google-cloud-monitoring-dashboard-v1\", path: \"../google-cloud-monitoring-dashboard-v1\"\n" \
                "gem \"google-cloud-monitoring-metrics_scope-v1\", path: \"../google-cloud-monitoring-metrics_scope-v1\"\n")
end

# Modify the entrypoint so it requires dashboard and metricsscope
OwlBot.modifier path: "lib/google-cloud-monitoring.rb" do |content|
  content.sub("\nrequire \"google/cloud/monitoring\" unless defined? Google::Cloud::Monitoring::VERSION\n",
              "\nrequire \"google/cloud/monitoring\" unless defined? Google::Cloud::Monitoring::VERSION\n" \
                "require \"google/cloud/monitoring/dashboard\" unless defined? Google::Cloud::Monitoring::Dashboard::VERSION\n" \
                "require \"google/cloud/monitoring/metrics_scope\" unless defined? Google::Cloud::Monitoring::MetricsScope::VERSION\n")
end

OwlBot.move_files
