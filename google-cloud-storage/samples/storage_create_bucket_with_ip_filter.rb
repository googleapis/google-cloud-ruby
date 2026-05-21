# Copyright 2024 Google LLC
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

# [START storage_create_bucket_with_ip_filter]
def create_bucket_with_ip_filter bucket_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  binding.pry

  # ip_filter = Google::Apis::StorageV1::Bucket::IpFilter.new(
  #   mode: "Enabled",
  #   public_network_source: Google::Apis::StorageV1::Bucket::IpFilter::PublicNetworkSource.new(
  #   allowed_ip_cidr_ranges: [
  #     "0.0.0.0/0", "::/0"
  #   ],
  #   vpc_network_sources: [
  #     {}
  #       network: "projects/storage-sdk-vendor/global/networks/default",
  #       allowed_ip_cidr_ranges: [
  #         "10.0.0.0/8"
  #       ]
  #     }
  #   ]
  # ),
  #  allow_all_service_agent_access: true
  # )
  ip_filter = {
  mode: "Disabled",
  public_network_source: {
    allowed_ip_cidr_ranges: [
      "0.0.0.0/0", "::/0"
    ]
  }
}

  bucket = storage.create_bucket bucket_name do |b|
    b.ip_filter = ip_filter
    b.uniform_bucket_level_access = true
  end

  binding.pry

  puts "Created bucket #{bucket_name} with IP filter enabled."
end

def removes_bucket_ip_filter bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  ip_filter = Google::Apis::StorageV1::Bucket::IpFilter.new(
    mode: "Disabled"
  )
  bucket.update do |b|
    b.ip_filter = ip_filter
  end

  puts "Updated IP filter for bucket #{bucket_name}."
end

def update_bucket_with_ip_filter bucket_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/resource_manager/v3"
  storage = Google::Cloud::Storage.new

  ip_filter = Google::Apis::StorageV1::Bucket::IpFilter.new(
    public_network_source: Google::Apis::StorageV1::Bucket::IpFilter::PublicNetworkSource.new(
    allowed_ip_cidr_ranges: [
      "0.0.0.3/0", "::/0"
    ]
  ))
  
# require "google/cloud/resource_manager"

# Direct client initialization
client = Google::Cloud::ResourceManager::V3::Projects::Client.new

project_id = storage.project
resource_name = "projects/#{project_id}"

# 1. Get the current polGoogle::Cloud::Iam::V1::IAM::Client.newicy
# binding.pry
policy = client.get_iam_policy resource: resource_name
# binding.pry

custom_role = "storage.buckets.exemptFromIpFilter"
custom_role_path = "#{resource_name}/roles/#{custom_role}"
service_account = "serviceAccount:#{storage.service_account_email}"
#{serviceAccount:storage-sdk-vendor@storage-sdk-vendor.iam.gserviceaccount.com}

binding.pry
custom_role_binding = Google::Iam::V1::Binding.new(
  role: custom_role_path,
    members: [service_account]
)
policy.bindings << custom_role_binding

client.set_iam_policy resource: resource_name, policy: policy
# Google::Cloud::PermissionDeniedError: 7:Permission 'resourcemanager.projects.setIamPolicy' denied on resource '//cloudresourcemanager.googleapis.com/projects/storage-sdk-vendor' (or it may not exist).. debug_error_string:{UNKNOWN:Error received from peer ipv4:74.125.23.95:443 {grpc_message:"Permission \'resourcemanager.projects.setIamPolicy\' denied on resource \'//cloudresourcemanager.googleapis.com/projects/storage-sdk-vendor\' (or it may not exist).", grpc_status:7}} (Google::Cloud::PermissionDeniedError)


#   # Optional: Log the change
#   puts "Updating project policy to include #{custom_role} for #{service_account}"
# end

puts "Project policy updated successfully."

  # project_id = "storage-sdk-vendor"
  # role_id    = "GcsIpExemptRole"
  # binding.pry

  # # Define the Custom Role
  # role = Google::Cloud::Iam::V1::Role.new(
  #   title: "GCS IP Exemption Role",
  #   included_permissions: ["storage.buckets.exemptFromIpFilter"],
  #   stage: :GA
  # )
  # resource = "projects/#{project_id}"
  # storage_project = storage.project
  # resource = "projects/#{storage_project}/roles/#{role_id}"
  # storage_project.policy do |p|
  #   p.add "roles/#{role}", member
  # end

  #   # Call test_iam_permissions. 
  #   # In Ruby, you can pass a Hash that matches the request structure.
  #   response = client.test_iam_permissions(
  #     resource: resource,
  #     permissions: ["storage.buckets.exemptFromIpFilter"]
  #   )

  #   # The response object contains a 'permissions' array of granted permissions
  #   puts "Granted permissions: #{response.permissions}"
    
  #   response.permissions

  #     # role   = "projects/#{storage.project}/roles/GcsIpExemptRole"
  #   member = "serviceAccount:insecure-cloudtop-shared-user@cloudtop-prod-asia-east.iam.gserviceaccount.com"

  #   bucket.policy requested_policy_version: 3 do |policy|
  #     policy.bindings.insert role: "roles/storage.buckets.exemptFromIpFilter", members: ["serviceAccount:insecure-cloudtop-shared-user@cloudtop-prod-asia-east.iam.gserviceaccount.com"]
  #   end
  #   # bucket = storage.create_bucket bucket_name 
  #   #    bucket.policy do |p|
  #   #     p.add "roles/storage.buckets.exemptFromIpFilter", "serviceAccount:insecure-cloudtop-shared-user@cloudtop-prod-asia-east.iam.gserviceaccount.com"
  #   #   end
  #   #   binding.pry

  bucket.update do |b|
    b.ip_filter = ip_filter
  end


  puts "Updated bucket #{bucket_name} with IP filter enabled."
end
# [END storage_create_bucket_with_ip_filter]

if $PROGRAM_NAME == __FILE__
  create_bucket_with_ip_filter bucket_name: ARGV.shift
end
