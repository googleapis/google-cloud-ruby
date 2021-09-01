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

# [START compute_instances_create]
# [START compute_instances_delete]
# [START compute_instances_list]
# [START compute_instances_list_all]
# [START compute_instances_operation_check]

require "google/cloud/compute/v1"

# [END compute_instances_operation_check]
# [END compute_instances_list_all]
# [END compute_instances_list]
# [END compute_instances_delete]
# [END compute_instances_create]

# [START compute_instances_create]
# Sends an instance creation request to the Compute Engine API and waits for it to complete.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] zone name of the zone you want to use. For example: "us-west3-b"
# @param [String] instance_name name of the new virtual machine.
# @param [String] machine_type machine type of the VM being created. For example: "e2-standard-2"
#         See https://cloud.google.com/compute/docs/machine-types for more information
#         on machine types.
# @param [String] source_image path to the operating system image to mount on your boot
#         disk. This can be one of the public images
#         (like "projects/debian-cloud/global/images/family/debian-10")
#         or a private image you have access to.
#         See https://cloud.google.com/compute/docs/images for more information on available images.
# @param [String] network_name name of the network you want the new instance to use.
#         For example: "global/networks/default" represents the `default`
#         network interface, which is created automatically for each project.
def create_instance project:, zone:, instance_name:,
                    machine_type: "n2-standard-2",
                    source_image: "projects/debian-cloud/global/images/family/debian-10",
                    network_name: "global/networks/default"
  # Initialize client that will be used to send requests. This client only needs to be created
  # once, and can be reused for multiple requests.
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new

  # Construct the instance object.
  # It can be either a hash or ::Google::Cloud::Compute::V1::Instance instance.
  instance = {
    name: instance_name,
    machine_type: "zones/#{zone}/machineTypes/#{machine_type}",
    # Instance creation requires at least one persistent disk.
    disks: [{
      auto_delete: true,
      boot: true,
      type: :PERSISTENT,
      initialize_params: {
        source_image: source_image,
        disk_size_gb: 10
      }
    }],
    network_interfaces: [{ name: network_name }]
  }

  # Prepare a request to create the instance in the specified project and zone.
  request = { project: project, zone: zone, instance_resource: instance }

  puts "Creating the #{instance_name} instance in #{zone}..."
  begin
    # Send the insert request.
    operation = client.insert request
    # Wait for the create operation to complete.
    operation = wait_until_done operation: operation.operation, project: project

    if operation.error.nil?
      warn "Warning during creation:", operation.warnings unless operation.warnings.empty?
      puts "Instance #{instance_name} created."
    else
      warn "Error during creation:", operation.error
    end
  rescue ::Google::Cloud::Error => e
    warn "Exception during creation:", e
  end
end
# [END compute_instances_create]

# [START compute_instances_list]
# Lists all instances in the given zone in the specified project.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] zone name of the zone you want to use. For example: "us-west3-b"
# @return [Array<::Google::Cloud::Compute::V1::Instance>] Array of instances.
def list_instances project:, zone:
  # Initialize client that will be used to send requests. This client only needs to be created
  # once, and can be reused for multiple requests.
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new

  # Send the request to list all VM instances in the given zone in the specified project.
  instance_list = client.list project: project, zone: zone

  puts "Instances found in zone #{zone}:"
  instances = []
  instance_list.each do |instance|
    puts " - #{instance.name} (#{instance.machine_type})"
    instances << instance
  end
  instances
end
# [END compute_instances_list]

# [START compute_instances_list_all]
# Returns a dictionary of all instances present in a project, grouped by their zone.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @return [Hash<String, Array<::Google::Cloud::Compute::V1::Instance>>] A hash with zone names
#   as keys (in form of "zones/{zone_name}") and arrays of instances as values.
def list_all_instances project:
  # Initialize client that will be used to send requests. This client only needs to be created
  # once, and can be reused for multiple requests.
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new

  # Send the request to list all VM instances in a project.
  agg_list = client.aggregated_list project: project
  all_instances = {}
  puts "Instances found:"
  # The result contains a Map collection, where the key is a zone and the value
  # is a collection of instances in that zone.
  agg_list.each do |zone, list|
    next if list.instances.empty?
    all_instances[zone] = list.instances
    puts " #{zone}:"
    list.instances.each do |instance|
      puts " - #{instance.name} (#{instance.machine_type})"
    end
  end
  all_instances
end
# [END compute_instances_list_all]

# [START compute_instances_delete]
# Sends an instance deletion request to the Compute Engine API and waits for it to complete.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] zone name of the zone you want to use. For example: "us-west3-b"
# @param [String] instance_name name of the instance you want to delete.
def delete_instance project:, zone:, instance_name:
  # Initialize client that will be used to send requests. This client only needs to be created
  # once, and can be reused for multiple requests.
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new

  puts "Deleting #{instance_name} from #{zone}..."
  begin
    # Make the request to delete a VM instance.
    operation = client.delete project: project, zone: zone, instance: instance_name
    # Wait for the delete operation to complete.
    operation = wait_until_done operation: operation.operation, project: project

    if operation.error.nil?
      warn "Warning during deletion:", operation.warnings unless operation.warnings.empty?
      puts "Instance #{instance_name} deleted."
    else
      warn "Error during deletion:", operation.error
    end
  rescue ::Google::Cloud::Error => e
    warn "Exception during deletion:", e
  end
end
# [END compute_instances_delete]

# [START compute_instances_operation_check]
require "time"

# Waits for an operation to be completed. Calling this method
# will block until the operation is finished or timed out.
#
# @param [::Google::Cloud::Compute::V1::Operation] operation The operation to wait for.
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [Numeric] timeout seconds until timeout (default is 3 minutes)
# @return [::Google::Cloud::Compute::V1::Operation] Finished Operation object.
def wait_until_done operation:, project:, timeout: 3 * 60
  request = { operation: operation.name, project: project }
  if !operation.zone.empty?
    client = ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
    # Operation#zone returns a full URL address of a zone, so we need to extract just the name.
    request[:zone] = operation.zone.rpartition("/").last
  elsif !operation.region.empty?
    client = ::Google::Cloud::Compute::V1::RegionOperations::Rest::Client.new
    # Operation#region returns a full URL address of a region, so we need to extract just the name.
    request[:region] = operation.region.rpartition("/").last
  else
    client = ::Google::Cloud::Compute::V1::GlobalOperations::Rest::Client.new
  end
  deadline = Time.now + timeout
  # Wait until the operation is not RUNNING.
  # #wait is on a best-effort basis and does not guarantee to block until either
  # the operation is DONE or the deadline is reached.
  while operation.status == :RUNNING
    now = Time.now
    if now > deadline
      raise "operation timed out"
    end
    options = { timeout: deadline - now }
    operation = client.wait request, options
  end
  operation
end
# [END compute_instances_operation_check]
