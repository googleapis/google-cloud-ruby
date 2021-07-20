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
# Send an instance creation request to the Compute Engine API and wait for it to complete.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] zone name of the zone you want to use. For example: “us-west3-b”
# @param [String] instance_name name of the new virtual machine.
# @param [String] machine_type machine type of the VM being created. This value uses the
#         following format: "zones/{zone}/machineTypes/{type_name}".
#         For example: "zones/europe-west3-c/machineTypes/f1-micro"
# @param [String] source_image path to the operating system image to mount on your boot
#         disk. This can be one of the public images
#         (like "projects/debian-cloud/global/images/family/debian-10")
#         or a private image you have access to.
# @param [String] network_name name of the network you want the new instance to use.
#         For example: "global/networks/default" represents the `default`
#         network interface, which is created automatically for each project.
# @return Instance object.
def create_instance project:, zone:, instance_name:,
                    machine_type: "n2-standard-2",
                    source_image: "projects/debian-cloud/global/images/family/debian-10",
                    network_name: "global/networks/default"
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new

  disk = ::Google::Cloud::Compute::V1::AttachedDisk.new
  initialize_params = ::Google::Cloud::Compute::V1::AttachedDiskInitializeParams.new
  initialize_params.source_image = source_image
  initialize_params.disk_size_gb = "10"
  disk.initialize_params = initialize_params
  disk.auto_delete = true
  disk.boot = true
  disk.type = ::Google::Cloud::Compute::V1::AttachedDisk::Type::PERSISTENT

  network_interface = ::Google::Cloud::Compute::V1::NetworkInterface.new
  network_interface.name = network_name

  instance = ::Google::Cloud::Compute::V1::Instance.new
  instance.name = instance_name
  instance.disks += [disk]
  full_machine_type_name = "zones/#{zone}/machineTypes/#{machine_type}"
  instance.machine_type = full_machine_type_name
  instance.network_interfaces += [network_interface]

  request = ::Google::Cloud::Compute::V1::InsertInstanceRequest.new
  request.zone = zone
  request.project = project
  request.instance_resource = instance

  puts "Creating the #{instance_name} instance in #{zone}..."
  begin
    operation = client.insert request
    if operation.status == :RUNNING
      operation_client = ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
      operation_client.wait operation: operation.name, project: project, zone: zone
    end
    warn "Error during creation:", operation.error unless operation.error.nil?
    warn "Warning during creation:", operation.warnings unless operation.warnings.empty?
    puts "Instance #{instance_name} created."
    instance
  rescue ::Google::Cloud::Error => e
    warn "Exception during creation:", e
  end
end
# [END compute_instances_create]

# [START compute_instances_list]

# List all instances in the given zone in the specified project.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] zone name of the zone you want to use. For example: “us-west3-b”
# @return Array of instances.
def list_instances project:, zone:
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new
  instance_list = client.list project: project, zone: zone

  puts "Instances found in zone #{zone}:"
  instance_list.items.each do |instance|
    puts " - #{instance.name} (#{instance.machine_type})"
  end
  instance_list.items
end

# [END compute_instances_list]

# [START compute_instances_list_all]
# Return a dictionary of all instances present in a project, grouped by their zone.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @return A hash with zone names as keys (in form of "zones/{zone_name}") and
#   arrays of instances as values.
def list_all_instances project:
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new
  agg_list = client.aggregated_list project: project
  all_instances = {}
  puts "Instances found:"
  agg_list.items.each do |zone, list|
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

# [BEGIN compute_instances_delete]

# Send an instance deletion request to the Compute Engine API and wait for it to complete.
#
# @param [String] project project ID or project number of the Cloud project you want to use.
# @param [String] zone name of the zone you want to use. For example: “us-west3-b”
# @param [String] instance_name name of the instance you want to delete.
def delete_instance project:, zone:, instance_name:
  client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new

  puts "Deleting #{instance_name} from #{zone}..."
  begin
    operation = client.delete project: project, zone: zone, instance: instance_name
    if operation.status == :RUNNING
      operation_client = ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
      operation_client.wait operation: operation.name, project: project, zone: zone
    end
    warn "Error during deletion:", operation.error unless operation.error.nil?
    warn "Warning during deletion:", operation.warnings unless operation.warnings.empty?
    puts "Instance #{instance_name} deleted."
  rescue ::Google::Cloud::Error => e
    warn "Exception during deletion:", e
  end
end

# [END compute_instances_delete]

# [START compute_instances_operation_check]
# This method waits for an operation to be completed. Calling this function
# will block until the operation is finished.
#
# @param [String] operation The Operation object representing the operation you want to wait on.
# @param [String] project project ID or project number of the Cloud project you want to use.
# @return Finished Operation object.
def wait_for_operation operation:, project:
  args = { operation: operation }
  if !operation.zone.nil?
    client = ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
    args[:zone] = operation.zone
  elsif !operation.region.nil?
    client = ::Google::Cloud::Compute::V1::RegionOperations::Rest::Client.new
    args[:region] = operation.region
  else
    client = ::Google::Cloud::Compute::V1::GlobalOperations::Rest::Client.new
  end
  client.wait(**args)
end

# [END compute_instances_operation_check]
