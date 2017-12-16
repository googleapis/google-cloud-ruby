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


require "helper"
require "google/cloud/env"


describe Google::Cloud::Env do
  let(:instance_name) { "instance-a1b2" }
  let(:instance_description) { "" }
  let(:instance_zone) { "us-west99-z" }
  let(:instance_machine_type) { "z9999-really-really-huge" }
  let(:instance_tags) { ["erlang", "elixir"] }
  let(:project_id) { "my-project-123" }
  let(:numeric_project_id) { 1234567890 }
  let(:gae_service) { "default" }
  let(:gae_version) { "20170214t123456" }
  let(:gae_memory_mb) { 640 }
  let(:gke_cluster) { "my-cluster" }
  let(:gke_namespace) { "my-namespace" }

  let :gae_env do
    {
      "GAE_INSTANCE" => instance_name,
      "GCLOUD_PROJECT" => project_id,
      "GAE_SERVICE" => gae_service,
      "GAE_VERSION" => gae_version,
      "GAE_MEMORY_MB" => gae_memory_mb
    }
  end
  let :gke_env do
    {
      "GKE_NAMESPACE_ID" => gke_namespace
    }
  end
  let :cloud_shell_env do
    {
      "DEVSHELL_PROJECT_ID" => project_id,
      "DEVSHELL_GCLOUD_CONFIG" => "cloudshell-1234"
    }
  end
  let(:gce_env) { {} }
  let(:ext_env) { {} }

  def gce_stubs
    ::Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("") { |env| [200, {"Metadata-Flavor" => "Google"}, ""] }
      stub.get("/computeMetadata/v1/project/project-id") { |env|
        [200, {}, project_id]
      }
      stub.get("/computeMetadata/v1/project/numeric-project-id") { |env|
        [200, {}, numeric_project_id.to_s]
      }
      stub.get("/computeMetadata/v1/instance/name") { |env|
        [200, {}, instance_name]
      }
      stub.get("/computeMetadata/v1/instance/zone") { |env|
        [200, {}, "/project/#{project_id}/zone/#{instance_zone}"]
      }
      stub.get("/computeMetadata/v1/instance/description") { |env|
        [200, {}, instance_description]
      }
      stub.get("/computeMetadata/v1/instance/machine-type") { |env|
        [200, {}, "/project/#{project_id}/zone/#{instance_machine_type}"]
      }
      stub.get("/computeMetadata/v1/instance/tags") { |env|
        [200, {}, JSON.dump(instance_tags)]
      }
    end
  end

  let :gce_conn do
    Faraday::Connection.new do |builder|
      builder.adapter :test, gce_stubs do |stub|
        stub.get(//) { |env| [404, {}, "not found"] }
      end
    end
  end

  let :gke_conn do
    Faraday::Connection.new do |builder|
      builder.adapter :test, gce_stubs do |stub|
        stub.get("/computeMetadata/v1/instance/attributes/cluster-name") { |env|
          [200, {}, gke_cluster]
        }
        stub.get(//) { |env| [404, {}, "not found"] }
      end
    end
  end

  let :ext_conn do
    Faraday::Connection.new do |builder|
      builder.adapter :test do |stub|
        stub.get(//) { |env| [404, {}, "not found"] }
      end
    end
  end

  it "returns correct values when running on app engine" do
    env = ::Google::Cloud::Env.new env: gae_env, connection: gce_conn

    env.app_engine?.must_equal true
    env.container_engine?.must_equal false
    env.cloud_shell?.must_equal false
    env.compute_engine?.must_equal true
    env.raw_compute_engine?.must_equal false

    env.project_id.must_equal project_id
    env.numeric_project_id.must_equal numeric_project_id
    env.instance_name.must_equal instance_name
    env.instance_description.must_equal instance_description
    env.instance_machine_type.must_equal instance_machine_type
    env.instance_tags.must_equal instance_tags

    env.app_engine_service_id.must_equal gae_service
    env.app_engine_service_version.must_equal gae_version
    env.app_engine_memory_mb.must_equal gae_memory_mb

    env.container_engine_cluster_name.must_be_nil
    env.container_engine_namespace_id.must_be_nil
  end

  it "returns correct values when running on container engine" do
    env = ::Google::Cloud::Env.new env: gke_env, connection: gke_conn

    env.app_engine?.must_equal false
    env.container_engine?.must_equal true
    env.cloud_shell?.must_equal false
    env.compute_engine?.must_equal true
    env.raw_compute_engine?.must_equal false

    env.project_id.must_equal project_id
    env.numeric_project_id.must_equal numeric_project_id
    env.instance_name.must_equal instance_name
    env.instance_description.must_equal instance_description
    env.instance_machine_type.must_equal instance_machine_type
    env.instance_tags.must_equal instance_tags

    env.app_engine_service_id.must_be_nil
    env.app_engine_service_version.must_be_nil
    env.app_engine_memory_mb.must_be_nil

    env.container_engine_cluster_name.must_equal gke_cluster
    env.container_engine_namespace_id.must_equal gke_namespace
  end

  it "returns correct values when running on cloud shell" do
    env = ::Google::Cloud::Env.new env: cloud_shell_env, connection: gce_conn

    env.app_engine?.must_equal false
    env.container_engine?.must_equal false
    env.cloud_shell?.must_equal true
    env.compute_engine?.must_equal true
    env.raw_compute_engine?.must_equal false

    env.project_id.must_equal project_id
    env.numeric_project_id.must_be_nil
    env.instance_name.must_equal instance_name
    env.instance_description.must_equal instance_description
    env.instance_machine_type.must_equal instance_machine_type
    env.instance_tags.must_equal instance_tags

    env.app_engine_service_id.must_be_nil
    env.app_engine_service_version.must_be_nil
    env.app_engine_memory_mb.must_be_nil

    env.container_engine_cluster_name.must_be_nil
    env.container_engine_namespace_id.must_be_nil
  end

  it "returns correct values when running on compute engine" do
    env = ::Google::Cloud::Env.new env: gce_env, connection: gce_conn

    env.app_engine?.must_equal false
    env.container_engine?.must_equal false
    env.cloud_shell?.must_equal false
    env.compute_engine?.must_equal true
    env.raw_compute_engine?.must_equal true

    env.project_id.must_equal project_id
    env.numeric_project_id.must_equal numeric_project_id
    env.instance_name.must_equal instance_name
    env.instance_description.must_equal instance_description
    env.instance_machine_type.must_equal instance_machine_type
    env.instance_tags.must_equal instance_tags

    env.app_engine_service_id.must_be_nil
    env.app_engine_service_version.must_be_nil
    env.app_engine_memory_mb.must_be_nil

    env.container_engine_cluster_name.must_be_nil
    env.container_engine_namespace_id.must_be_nil
  end

  it "returns correct values when not running on gcp" do
    env = ::Google::Cloud::Env.new env: ext_env, connection: ext_conn

    env.app_engine?.must_equal false
    env.container_engine?.must_equal false
    env.cloud_shell?.must_equal false
    env.compute_engine?.must_equal false
    env.raw_compute_engine?.must_equal false

    env.project_id.must_be_nil
    env.numeric_project_id.must_be_nil
    env.instance_name.must_be_nil
    env.instance_description.must_be_nil
    env.instance_machine_type.must_be_nil
    env.instance_tags.must_be_nil

    env.app_engine_service_id.must_be_nil
    env.app_engine_service_version.must_be_nil
    env.app_engine_memory_mb.must_be_nil

    env.container_engine_cluster_name.must_be_nil
    env.container_engine_namespace_id.must_be_nil
  end

end
