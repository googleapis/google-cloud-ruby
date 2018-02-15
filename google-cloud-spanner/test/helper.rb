# Copyright 2016 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/spanner"
require "grpc"

##
# Monkey-Patch CallOptions to support Mocks
class Google::Gax::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout === other.timeout &&
      retry_options === other.retry_options &&
      page_token === other.page_token &&
      kwargs === other.kwargs
  end
  def == other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout == other.timeout &&
      retry_options == other.retry_options &&
      page_token == other.page_token &&
      kwargs == other.kwargs
  end
end

class MockSpanner < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:spanner) { Google::Cloud::Spanner::Project.new(Google::Cloud::Spanner::Service.new(project, credentials)) }

  # Register this spec type for when :spanner is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_spanner
  end

  def shutdown_client! client
    # extract the pool
    pool = client.instance_variable_get :@pool
    # remove all sessions so we don't have to handle the calls to session_delete
    pool.all_sessions = []

    # close the client
    client.close

    # close the client
    shutdown_pool! pool
  end

  def shutdown_pool! pool
    # ensure the pool's thread pool is also shut down
    thread_pool = pool.instance_variable_get :@thread_pool
    thread_pool.shutdown
    thread_pool.wait_for_termination 60
  end

  def instance_configs_hash
    {
      instanceConfigs: [
        { name: "projects/#{project}/instanceConfigs/regional-europe-west1",
          displayName: "EU West 1"},
        { name: "projects/#{project}/instanceConfigs/regional-us-west1",
          displayName: "US West 1"},
        { name: "projects/#{project}/instanceConfigs/regional-us-central1",
          displayName: "US Central 1"}
      ]
    }
  end

  def instance_config_hash
    instance_configs_hash[:instanceConfigs].last
  end

  def instances_hash
    { instances: 3.times.map { instance_hash } }
  end

  def instance_hash name: "instance-#{rand(9999)}", nodes: 1, state: "READY", labels: {}
    {
      name: "projects/#{project}/instances/#{name}",
      config: "projects/#{project}/instanceConfigs/regional-us-central1",
      displayName: name.split("-").map(&:capitalize).join(" "),
      nodeCount: nodes,
      state: state,
      labels: labels
    }
  end

  def databases_hash instance_id: "my-instance-id"
    { databases: 3.times.map { database_hash(instance_id: instance_id) } }
  end

  def database_hash instance_id: "my-instance-id", database_id: "database-#{rand(9999)}", state: "READY"
    {
      name: "projects/#{project}/instances/#{instance_id}/databases/#{database_id}",
      state: state
    }
  end

  def project_path
    Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path project
  end

  def instance_path name
    return name if name.to_s.include? "/"
    Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path(
      project, name)
  end

  def database_path instance, name
    Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path(
      project, instance, name)
  end

  def instance_config_path name
    return name if name.to_s.include? "/"
    Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_config_path(
      project, name)
  end

  def session_path instance_id, database_id, session_id
    Google::Cloud::Spanner::V1::SpannerClient.session_path(
      project, instance_id, database_id, session_id)
  end

  def paged_enum_struct response
    OpenStruct.new page: OpenStruct.new(response: response)
  end
end

# This is used to raise errors in an enumerator
class RaiseableEnumerator
  def initialize enum
    @enum = enum
  end

  def next
    v = @enum.next
    raise v if v.is_a? Class
    v
  end

  def method_missing method, *args
    @enum.send method, *args
  end

  def inspect
    "<#{self.class}>"
  end
end
