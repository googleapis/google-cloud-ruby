# Copyright 2025 Google LLC
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

OwlBot.modifier path: "lib/google/cloud/pubsub/v1/schema_service/client.rb" do |content|
  content.gsub! "#   @return [::Logger,:default,nil]",
                "#   @return [::Logger,::Google::Logging::GoogleSdkLoggerDelegator,:default,nil]"
end
OwlBot.modifier path: "lib/google/cloud/pubsub/v1/subscription_admin/client.rb" do |content|
  content.gsub! "#   @return [::Logger,:default,nil]",
                "#   @return [::Logger,::Google::Logging::GoogleSdkLoggerDelegator,:default,nil]"
end
OwlBot.modifier path: "lib/google/cloud/pubsub/v1/topic_admin/client.rb" do |content|
  content.gsub! "#   @return [::Logger,:default,nil]",
                "#   @return [::Logger,::Google::Logging::GoogleSdkLoggerDelegator,:default,nil]"
end
OwlBot.modifier path: "lib/google/cloud/pubsub/v1/schema_service/client.rb" do |content|
  content.gsub! "config_attr :logger, :default, ::Logger, nil, :default",
                "config_attr :logger, :default, [::Logger, ::Google::Logging::GoogleSdkLoggerDelegator], nil, :default"
end
OwlBot.modifier path: "lib/google/cloud/pubsub/v1/subscription_admin/client.rb" do |content|
  content.gsub! "config_attr :logger, :default, ::Logger, nil, :default",
                "config_attr :logger, :default, [::Logger, ::Google::Logging::GoogleSdkLoggerDelegator], nil, :default"
end
OwlBot.modifier path: "lib/google/cloud/pubsub/v1/topic_admin/client.rb" do |content|
  content.gsub! "config_attr :logger, :default, ::Logger, nil, :default",
                "config_attr :logger, :default, [::Logger, ::Google::Logging::GoogleSdkLoggerDelegator], nil, :default"
end

# Add google-logging-utils as a dependency
OwlBot.modifier path: "google-cloud-pubsub-v1.gemspec" do |content|
  content.gsub!(/
end\z/, "\n  gem.add_dependency \"google-logging-utils\", \"~> 0.3.0\"\nend")
end

OwlBot.move_files
