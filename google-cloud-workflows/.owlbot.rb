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

# Modify the gemspec so it includes the executions gem
OwlBot.modifier path: "google-cloud-workflows.gemspec" do |content|
  content.sub(%r{\n  gem.add_dependency "google-cloud-workflows-v1beta", "([^\n]+)"\n\n}m,
              "\n  gem.add_dependency \"google-cloud-workflows-v1beta\", \"\\1\"\n" \
                "  gem.add_dependency \"google-cloud-workflows-executions-v1\", \">= 0.0\", \"< 2.a\"\n" \
                "  gem.add_dependency \"google-cloud-workflows-executions-v1beta\", \">= 0.0\", \"< 2.a\"\n\n")
end

# Modify the Gemfile so includes the executions gems
OwlBot.modifier path: "Gemfile" do |content|
  content.sub("\ngem \"google-cloud-workflows-v1beta\", path: \"../google-cloud-workflows-v1beta\"\n",
              "\ngem \"google-cloud-workflows-v1beta\", path: \"../google-cloud-workflows-v1beta\"\n" \
                "gem \"google-cloud-workflows-executions-v1\", path: \"../google-cloud-workflows-executions-v1\"\n" \
                "gem \"google-cloud-workflows-executions-v1beta\", path: \"../google-cloud-workflows-executions-v1beta\"\n")
end

# Modify the entrypoint so it requires executions
OwlBot.modifier path: "lib/google-cloud-workflows.rb" do |content|
  content.sub("\nrequire \"google/cloud/workflows\" unless defined? Google::Cloud::Workflows::VERSION\n",
              "\nrequire \"google/cloud/workflows\" unless defined? Google::Cloud::Workflows::VERSION\n" \
                "require \"google/cloud/workflows/executions\" unless defined? Google::Cloud::Workflows::Executions::VERSION\n")
end

OwlBot.move_files
