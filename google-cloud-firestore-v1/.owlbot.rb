# Copyright 2023 Google LLC
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

# Fixes invalid request headers.
# See internal issue b/274072959.
OwlBot.modifier path: "lib/google/cloud/firestore/v1/firestore/client.rb" do |content|
  content.gsub(/metadata\[:"x-goog-request-params"\] \|\|= request_params_header/,
               "if @config&.metadata&.key? :\"google-cloud-resource-prefix\"
                metadata[:\"x-goog-request-params\"] ||= @config.metadata[:\"google-cloud-resource-prefix\"].split(\"/\").each_slice(2).to_h.map { |k, v| \"#\{k\}=#\{v\}\" }.join(\"&\")
              end
              metadata[:\"x-goog-request-params\"] ||= request_params_header")
end

OwlBot.move_files
