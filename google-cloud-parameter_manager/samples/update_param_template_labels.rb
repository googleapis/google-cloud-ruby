# Copyright 2026 Google LLC
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

# [START parametermanager_update_param_template_labels]
require "google/cloud/parameter_manager"

##
# Update the labels of a template
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param template_id [String] The template name (e.g. "my-template")
# @param label_key [String] The label key (e.g. "my-key")
# @param label_value [String] The label value (e.g. "my-value")
#
def update_param_template_labels project_id:, template_id:, label_key:, label_value:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the template.
  name = client.template_path project: project_id, location: "global", template: template_id

  template = {
    name: name,
    labels: {
      label_key => label_value
    }
  }

  update_mask = {
    paths: ["labels"]
  }

  # Update the template.
  client.update_template template: template, update_mask: update_mask

  # Get the updated template.
  updated = client.get_template name: name

  # Print the updated labels.
  puts "Updated template #{updated.name} with labels #{updated.labels.to_h}"
end
# [END parametermanager_update_param_template_labels]

if $PROGRAM_NAME == __FILE__
  update_param_template_labels(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    template_id: ARGV.shift,
    label_key: ARGV.shift,
    label_value: ARGV.shift
  )
end
