# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require 'commander/import'

# Import google bigtable client lib
require "google-cloud-bigtable"

def create_prod_instance instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable

  puts "==> Check Instance Exists"
  # [START bigtable_check_instance_exists]
  if bigtable.instance(instance_id)
    puts "Instance #{instance_id} exists"
  # [END bigtable_check_instance_exists]
  else
    # [START bigtable_create_prod_instance]
    puts "==> Creating a PRODUCTION Instance"
    job = bigtable.create_instance(
      instance_id,
      display_name: "Sample production instance",
      labels: { "env": "production"},
      type: :PRODUCTION # Optional as default type is :PRODUCTION
    ) do |clusters|
      clusters.add(cluster_id, "us-central1-f", nodes: 3, storage_type: :SSD)
    end

    job.wait_until_done!
    instance = job.instance
    # [END bigtable_create_prod_instance]
    puts "Created Instance: #{instance.instance_id}"
  end

  puts "==> Listing Instances"
  # [START bigtable_list_instances]
  bigtable.instances.all do |instance|
    p instance.instance_id
  end
  # [END bigtable_list_instances]

  puts "==> Get Instance"
  # [START bigtable_get_instance]
  p bigtable.instance(instance_id)
  # [END bigtable_get_instance]

  puts "==> Listing Clusters of #{instance_id}" do
    # [START bigtable_get_clusters]
    bigtable.instance(instance_id).clusters.all do |cluster|
      p cluster.cluster_id
    end
    # [END bigtable_get_clusters]
  end
  puts "\n"
end

def create_dev_instance instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable

  puts "==> Creating a DEVELOPMENT Instance"

  # [START bigtable_create_dev_instance]
  job = bigtable.create_instance(
    instance_id,
    display_name: "Sample development instance",
    labels: { "env": "development"},
    type: :DEVELOPMENT
  ) do |clusters|
    clusters.add(cluster_id, "us-central1-f", storage_type: :HDD)
  end

  job.wait_until_done!

  instance = job.instance
  # [END bigtable_create_dev_instance]
  puts "==> Created development instance: #{instance.instance_id}"
end

def delete_instance instance_id
  bigtable = Google::Cloud.new.bigtable
  instance = bigtable.instance(instance_id)

  puts "==> Deleting Instance"
  # [START bigtable_delete_instance]
  instance.delete
  # [END bigtable_delete_instance]
  puts "==> Instance deleted: #{instance.instance_id}\n"
end

def add_cluster instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable

  instance = bigtable.instance(instance_id)

  unless instance
    puts "==> Instance does not exists"
    return
  end

  puts "==> Adding Cluster to Instance #{instance.instance_id}"

  # [START bigtable_create_cluster]
  job = instance.create_cluster(
    cluster_id,
    "us-central1-c",
    nodes: 3,
    storage_type: :SSD
  )

  job.wait_until_done!
  cluster = job.cluster
  # [END bigtable_create_cluster]
  puts "==> Cluster created: #{cluster.cluster_id}\n"
end

def delete_cluster instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable
  instance = bigtable.instance(instance_id)
  cluster = instance.cluster(cluster_id)

  puts "==> Deleting Cluster"
  # [START bigtable_delete_cluster]
  cluster.delete
  # [END bigtable_delete_cluster]

  puts "Cluster deleted: #{cluster.cluster_id}"
end

program :version, "0.0.1"
program :name, "instances"
program :description, <<-EOS
Perform Bigtable Instance management operations.

bundle exec ruby instances.rb <command> <instance_id> <cluster_id>
EOS

command "run" do |c|
  c.syntax = "run <instance_id> <cluster_id>"
  c.description = "Creates an Instance(type: PRODUCTION) and run basic instance-operations"
  c.action do |args, options|
    instance_id, cluster_id = args

    if instance_id && cluster_id
      create_prod_instance(instance_id, cluster_id)
    else
      command(:help).run
    end
  end
end

command "dev-instance" do |c|
  c.syntax = "dev-instance <instance_id>"
  c.description = "Create Development Instance"
  c.action do |args, options|
    instance_id, cluster_id = args

    if instance_id && cluster_id
      create_dev_instance(instance_id, cluster_id)
    else
      command(:help).run
    end
  end
end

command "del-instance" do |c|
  c.syntax = "del-instance <instance_id>"
  c.description = "Delete the Instance"
  c.action do |args, options|
    instance_id = args.first

    if instance_id
      delete_instance(instance_id)
    else
      command(:help).run
    end
  end
end

command "add-cluster" do |c|
  c.syntax = "add-cluster <instance_id> <cluster_id>"
  c.description = "Add Cluster"
  c.action do |args, options|
    instance_id, cluster_id = args

    if instance_id && cluster_id
      add_cluster(instance_id, cluster_id)
    else
      command(:help).run
    end
  end
end

command "del-cluster" do |c|
  c.syntax = "del-cluster <instance_id> <cluster_id>"
  c.description = "Delete the Cluster"
  c.action do |args, options|
    instance_id, cluster_id = args

    if instance_id && cluster_id
      delete_cluster(instance_id, cluster_id)
    else
      command(:help).run
    end
  end
end

default_command :help
