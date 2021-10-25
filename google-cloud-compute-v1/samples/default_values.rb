# frozen_string_literal: true

# Copyright 2021 Google LLC
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

# [START compute_usage_report_set]
# [START compute_usage_report_get]
# [START compute_usage_report_disable]

require "google/cloud/compute/v1"

# [END compute_usage_report_disable]
# [END compute_usage_report_get]
# [END compute_usage_report_set]

require_relative "quickstart"

# [START compute_usage_report_set]

# Sets Compute Engine usage export bucket for the Cloud project.
# This sample presents how to interpret the default value for the
# report name prefix parameter.
#
# @param [String] project project ID or project number of the project to update.
# @param [String] bucket_name Google Cloud Storage bucket used to store Compute Engine
#            usage reports. An existing Google Cloud Storage bucket is required.
# @param [String] report_name_prefix Prefix of the usage report name which defaults to an empty string
#            to showcase default values behaviour.
def set_usage_export_bucket project:, bucket_name:, report_name_prefix: ""
  export_location = { bucket_name: bucket_name, report_name_prefix: report_name_prefix }
  if report_name_prefix.empty?
    # Sending an empty value for report_name_prefix results in the
    # next usage report being generated with the default prefix value
    # "usage_gce". (ref: https://cloud.google.com/compute/docs/reference/rest/v1/projects/setUsageExportBucket)
    puts "Setting report_name_prefix to empty value causes the report " \
         "to have the default prefix of `usage_gce`."
  end
  projects_client = ::Google::Cloud::Compute::V1::Projects::Rest::Client.new
  operation = projects_client.set_usage_export_bucket project: project,
                                                      usage_export_location_resource: export_location
  wait_until_done project: project, operation: operation.operation
end

# [END compute_usage_report_set]

# [START compute_usage_report_get]

# Retrieves Compute Engine usage export bucket for the Cloud project.
# Replaces the empty value returned by the API with the default value used
# to generate report file names.
#
# @param [String] project project ID or project number of the project to get from.
# @return [::Google::Cloud::Compute::V1::UsageExportLocation] object describing the current usage
#   export settings for project.
def get_usage_export_bucket project:
  projects_client = ::Google::Cloud::Compute::V1::Projects::Rest::Client.new
  project_data = projects_client.get project: project
  export_location = project_data.usage_export_location

  if !export_location.nil? && export_location.report_name_prefix.empty?
    puts "Report name prefix not set, replacing with default value of `usage_gce`."
    export_location.report_name_prefix = "usage_gce"
  end
  export_location
end

# [END compute_usage_report_get]

# [START compute_usage_report_disable]

# Disables Compute Engine usage export bucket for the Cloud Project.
#
# @param [String] project project ID or project number of the project to update.
def disable_usage_export project:
  projects_client = ::Google::Cloud::Compute::V1::Projects::Rest::Client.new

  # Passing nil (default) to usage_export_location_resource disables the usage report generation.
  operation = projects_client.set_usage_export_bucket project: project
  wait_until_done project: project, operation: operation.operation
end

# [END compute_usage_report_disable]
