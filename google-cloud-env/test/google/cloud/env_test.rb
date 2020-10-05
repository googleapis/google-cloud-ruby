# Copyright 2017 Google LLC
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
  let(:gae_standard_runtime) { "ruby25" }

  let :knative_env do
    {
      "K_SERVICE" => gae_service,
      "K_REVISION" => gae_version
    }
  end
  let :gae_flex_env do
    {
      "GAE_INSTANCE" => instance_name,
      "GCLOUD_PROJECT" => project_id,
      "GAE_SERVICE" => gae_service,
      "GAE_VERSION" => gae_version,
      "GAE_MEMORY_MB" => gae_memory_mb
    }
  end
  let :gae_standard_env do
    {
      "GAE_INSTANCE" => instance_name,
      "GOOGLE_CLOUD_PROJECT" => project_id,
      "GAE_SERVICE" => gae_service,
      "GAE_VERSION" => gae_version,
      "GAE_ENV" => "standard",
      "GAE_RUNTIME" => gae_standard_runtime,
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

  def gce_stubs failure_count: 0
    ::Faraday::Adapter::Test::Stubs.new do |stub|
      failure_count.times do
        stub.get("") { |env| raise ::Errno::EHOSTDOWN }
      end
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

  def gce_conn failure_count: 0
    Faraday::Connection.new do |builder|
      builder.adapter :test, gce_stubs(failure_count: failure_count) do |stub|
        stub.get(//) { |env| [404, {}, "not found"] }
      end
    end
  end

  def gke_conn failure_count: 0
    Faraday::Connection.new do |builder|
      builder.adapter :test, gce_stubs(failure_count: failure_count) do |stub|
        stub.get("/computeMetadata/v1/instance/attributes/cluster-name") { |env|
          [200, {}, gke_cluster]
        }
        stub.get(//) { |env| [404, {}, "not found"] }
      end
    end
  end

  def ext_conn failure_count: 0
    Faraday::Connection.new do |builder|
      builder.adapter :test do |stub|
        stub.get(//) { |env| raise ::Errno::EHOSTDOWN }
      end
    end
  end

  it "returns correct values when running on cloud run" do
    env = ::Google::Cloud::Env.new env: knative_env, connection: gce_conn

    env.knative?.must_equal true
    env.app_engine?.must_equal false
    env.app_engine_flexible?.must_equal false
    env.app_engine_standard?.must_equal false
    env.kubernetes_engine?.must_equal false
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

    env.kubernetes_engine_cluster_name.must_be_nil
    env.kubernetes_engine_namespace_id.must_be_nil
  end

  it "returns correct values when running on app engine flex" do
    env = ::Google::Cloud::Env.new env: gae_flex_env, connection: gce_conn

    env.knative?.must_equal false
    env.app_engine?.must_equal true
    env.app_engine_flexible?.must_equal true
    env.app_engine_standard?.must_equal false
    env.kubernetes_engine?.must_equal false
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

    env.kubernetes_engine_cluster_name.must_be_nil
    env.kubernetes_engine_namespace_id.must_be_nil
  end

  it "returns correct values when running on app engine standard" do
    env = ::Google::Cloud::Env.new env: gae_standard_env, connection: gce_conn

    env.knative?.must_equal false
    env.app_engine?.must_equal true
    env.app_engine_flexible?.must_equal false
    env.app_engine_standard?.must_equal true
    env.kubernetes_engine?.must_equal false
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

    env.kubernetes_engine_cluster_name.must_be_nil
    env.kubernetes_engine_namespace_id.must_be_nil
  end

  it "returns correct values when running on kubernetes engine" do
    env = ::Google::Cloud::Env.new env: gke_env, connection: gke_conn

    env.knative?.must_equal false
    env.app_engine?.must_equal false
    env.app_engine_flexible?.must_equal false
    env.app_engine_standard?.must_equal false
    env.kubernetes_engine?.must_equal true
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

    env.kubernetes_engine_cluster_name.must_equal gke_cluster
    env.kubernetes_engine_namespace_id.must_equal gke_namespace
  end

  it "returns correct values when running on cloud shell" do
    env = ::Google::Cloud::Env.new env: cloud_shell_env, connection: gce_conn

    env.knative?.must_equal false
    env.app_engine?.must_equal false
    env.app_engine_flexible?.must_equal false
    env.app_engine_standard?.must_equal false
    env.kubernetes_engine?.must_equal false
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

    env.kubernetes_engine_cluster_name.must_be_nil
    env.kubernetes_engine_namespace_id.must_be_nil
  end

  it "returns correct values when running on compute engine" do
    env = ::Google::Cloud::Env.new env: gce_env, connection: gce_conn

    env.knative?.must_equal false
    env.app_engine?.must_equal false
    env.app_engine_flexible?.must_equal false
    env.app_engine_standard?.must_equal false
    env.kubernetes_engine?.must_equal false
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

    env.kubernetes_engine_cluster_name.must_be_nil
    env.kubernetes_engine_namespace_id.must_be_nil
  end

  it "returns correct values when not running on gcp" do
    env = ::Google::Cloud::Env.new env: gce_env, connection: ext_conn

    env.knative?.must_equal false
    env.app_engine?.must_equal false
    env.app_engine_flexible?.must_equal false
    env.app_engine_standard?.must_equal false
    env.kubernetes_engine?.must_equal false
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

    env.kubernetes_engine_cluster_name.must_be_nil
    env.kubernetes_engine_namespace_id.must_be_nil
  end

  it "fails if requests fail and there are not enough retries" do
    conn = gce_conn failure_count: 2
    env = ::Google::Cloud::Env.new env: gce_env, retry_count: 1,
                                   connection: conn
    env.compute_engine?.must_equal false
  end

  it "succeeds if requests fail and there are sufficient retries" do
    conn = gce_conn failure_count: 2
    env = ::Google::Cloud::Env.new env: gce_env, retry_count: 2,
                                   connection: conn
    env.compute_engine?.must_equal true
  end

  it "recognizes GCE_METADATA_HOST" do
    env_vars = { "GCE_METADATA_HOST" => "mymetadata.example.com" }
    callable = proc do |url:, **opts|
      assert_equal "http://mymetadata.example.com", url
      :callable
    end
    Faraday.stub :new, callable do
      env = ::Google::Cloud::Env.new env: env_vars
      assert_equal :callable, env.instance_variable_get(:@connection)
    end
  end
end
