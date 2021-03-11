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

# Import google bigtable client lib
require "google/cloud/bigtable"

def create_prod_instance instance_id, cluster_id, cluster_location
  bigtable = Google::Cloud::Bigtable.new
  puts "Check Instance Exists"

  # [START bigtable_check_instance_exists]
  # instance_id = "my-instance"
  if bigtable.instance instance_id
    puts "Instance #{instance_id} exists"
    return
  end
  # [END bigtable_check_instance_exists]

  # [START bigtable_create_prod_instance]
  # instance_id      = "my-instance"
  # cluster_id       = "my-cluster"
  # cluster_location = "us-east1-b"
  puts "Creating a PRODUCTION Instance"
  job = bigtable.create_instance(
    instance_id,
    display_name: "Sample production instance",
    labels:       { "env": "production" },
    type:         :PRODUCTION # Optional as default type is :PRODUCTION
  ) do |clusters|
    clusters.add cluster_id, cluster_location, nodes: 3, storage_type: :SSD
  end

  job.wait_until_done!
  instance = job.instance
  puts "Created Instance: #{instance.instance_id}"
  # [END bigtable_create_prod_instance]

  puts "Listing Instances"
  # [START bigtable_list_instances]
  bigtable.instances.all do |instance|
    puts "Instance: #{instance.instance_id}"
  end
  # [END bigtable_list_instances]

  puts "Get Instance"
  # [START bigtable_get_instance]
  # instance_id = "my-instance"
  instance = bigtable.instance instance_id
  puts "Get Instance id: #{instance.instance_id}"
  # [END bigtable_get_instance]

  puts "Listing Clusters of #{instance_id}"
  # [START bigtable_get_clusters]
  # instance_id = "my-instance"
  bigtable.instance(instance_id).clusters.all do |cluster|
    puts "Cluster: #{cluster.cluster_id}"
  end
  # [END bigtable_get_clusters]
end

def create_dev_instance instance_id, cluster_id, cluster_location
  bigtable = Google::Cloud::Bigtable.new
  puts "Creating a DEVELOPMENT Instance"

  # [START bigtable_create_dev_instance]
  # instance_id      = "my-instance"
  # cluster_id       = "my-cluster"
  # cluster_location = "us-east1-b"
  job = bigtable.create_instance(
    instance_id,
    display_name: "Sample development instance",
    labels:       { "env": "development" },
    type:         :DEVELOPMENT
  ) do |clusters|
    clusters.add cluster_id, cluster_location, storage_type: :HDD
  end

  job.wait_until_done!
  instance = job.instance
  puts "Created development instance: #{instance_id}"
  # [END bigtable_create_dev_instance]
end

def delete_instance instance_id
  bigtable = Google::Cloud::Bigtable.new
  instance = bigtable.instance instance_id
  puts "Deleting Instance: #{instance.instance_id}"

  # [START bigtable_delete_instance]
  instance.delete
  # [END bigtable_delete_instance]
  puts "Instance deleted: #{instance.instance_id}"
end

def add_cluster instance_id, cluster_id, cluster_location
  bigtable = Google::Cloud::Bigtable.new
  instance = bigtable.instance instance_id

  unless instance
    puts "Instance does not exists"
    return
  end

  puts "Adding Cluster to Instance #{instance.instance_id}"

  # [START bigtable_create_cluster]
  # cluster_id       = "my-cluster"
  # cluster_location = "us-east1-b"
  job = instance.create_cluster(
    cluster_id,
    cluster_location,
    nodes:        3,
    storage_type: :SSD
  )

  job.wait_until_done!
  cluster = job.cluster
  # [END bigtable_create_cluster]
  puts "Cluster created: #{cluster.cluster_id}"
end

def delete_cluster instance_id, cluster_id
  bigtable = Google::Cloud::Bigtable.new
  instance = bigtable.instance instance_id
  cluster = instance.cluster cluster_id
  puts "Deleting Cluster: #{cluster_id}"

  # [START bigtable_delete_cluster]
  cluster.delete
  # [END bigtable_delete_cluster]

  puts "Cluster deleted: #{cluster.cluster_id}"
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "run"
    create_prod_instance ARGV.shift, ARGV.shift, ARGV.shift
  when "add-cluster"
    add_cluster ARGV.shift, ARGV.shift, ARGV.shift
  when "del-cluster"
    delete_cluster ARGV.shift, ARGV.shift
  when "del-instance"
    delete_instance ARGV.shift
  when "dev-instance"
    create_dev_instance ARGV.shift, ARGV.shift, ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby instanceadmin.rb [command] [arguments]
       Commands:
      run          <instance_id> <cluster_id> <cluster_location>   Creates an Instance(type: PRODUCTION) and run basic instance-operations
      add-cluster  <instance_id> <cluster_id> cluster_location     Add Cluster
      del-cluster  <instance_id> <cluster_id>                      Delete the Cluster
      del-instance <instance_id>                                   Delete the Instance
      dev-instance <instance_id> <cluster_id> <cluster_location>   Create Development Instance
       Environment variables:
       GOOGLE_CLOUD_BIGTABLE_PROJECT or GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
       Cluster Locations:
       https://cloud.google.com/bigtable/docs/locations
    USAGE
  end
end
