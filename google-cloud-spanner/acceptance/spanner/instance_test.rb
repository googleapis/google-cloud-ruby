# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Instances", :spanner do
  it "creates, updates, and deletes an instance" do
    instance_id = "#{$spanner_prefix}-empty"
    name = "#{$spanner_prefix} Empty"
    config = "regional-us-central1"

    spanner.instance(instance_id).must_be :nil?

    job = spanner.create_instance instance_id, name: name, config: config, nodes: 1, labels: { env: :development }

    job.must_be_kind_of Google::Cloud::Spanner::Instance::Job
    job.wont_be :done?
    job.wait_until_done!

    job.must_be :done?
    raise Google::Cloud::Error.from_error(job.error) if job.error?
    instance = job.instance
    instance.wont_be :nil?
    instance.must_be_kind_of Google::Cloud::Spanner::Instance
    instance.instance_id.must_equal instance_id
    instance.name.must_equal name
    instance.config.instance_config_id.must_equal config
    instance.nodes.must_equal 1
    map_to_hash(instance.labels).must_equal({ "env" => "development" })

    spanner.instance(instance_id).wont_be :nil?

    new_name = instance.name.reverse
    instance.name = new_name
    instance.nodes = 2
    instance.labels["env"] = "production"
    instance.save

    instance.name.must_equal new_name
    instance.nodes.must_equal 2
    map_to_hash(instance.labels).must_equal({ "env" => "production" })

    instance.delete
    spanner.instance(instance_id).must_be :nil?
  end

  it "lists and gets instances" do
    all_instances = spanner.instances.all.to_a
    all_instances.wont_be :empty?
    all_instances.each do |instance|
      instance.must_be_kind_of Google::Cloud::Spanner::Instance
    end

    first_instance = spanner.instance all_instances.first.instance_id
    first_instance.must_be_kind_of Google::Cloud::Spanner::Instance
  end

  def map_to_hash map
    if map.respond_to? :to_h
      map.to_h
    else
      # Enumerable doesn't have to_h on ruby 2.0...
      Hash[map.to_a]
    end
  end
end
