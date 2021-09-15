require "minitest/autorun"

require "google/cloud/compute/v1/instance_group_managers"
require "google/cloud/compute/v1/instance_templates"

require "google/cloud/compute/v1/zone_operations"
require "google/cloud/compute/v1/global_operations"

class QueryParamsSmokeTest < Minitest::Test
  def setup
    @default_zone = "us-central1-a"
    @default_project = ENV["COMPUTE_TEST_PROJECT"]

    @templates_client = ::Google::Cloud::Compute::V1::InstanceTemplates::Rest::Client.new
    @igm_client = ::Google::Cloud::Compute::V1::InstanceGroupManagers::Rest::Client.new

    @zonal_ops_client = ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
    @global_ops_client = ::Google::Cloud::Compute::V1::GlobalOperations::Rest::Client.new

    @image_name =  "projects/debian-cloud/global/images/family/debian-10"
    skip "COMPUTE_TEST_PROJECT must be set before running this test" if @default_project.nil?
  end

  # Smoke-test the following behaviours: 
  #   1) set body field to nil
  #   2) set query param to nil
  def test_query_params
    template_name = "rbgapic#{rand 10_000}"
    igm_name = "rbgapic#{rand 10_000}"
    template_resource = {
      name: template_name,
      properties: {
        disks: [
          {
            initialize_params: {
              source_image: @image_name
            },
            boot: true,
            auto_delete: true,
            type: "PERSISTENT"
          }
        ],
        machine_type: "n1-standard-1",
        network_interfaces: [{ access_configs: [{ name: "default", type: "ONE_TO_ONE_NAT" }] }]
      }
    }

    begin
      $stdout.puts "inserting instance template #{template_name}"
      operation = @templates_client.insert project: @default_project, instance_template_resource: template_resource
      wait_for_global_op operation, "insert instance template #{template_name}"

      igm_resource = {
        base_instance_name: "rbgapicinst",
        target_size: 0,
        instance_template: operation.operation.target_link,
        name: igm_name
      }

      $stdout.puts "inserting instance_group_manager #{igm_resource[:name]}"
      op = @igm_client.insert project: @default_project, zone: @default_zone, instance_group_manager_resource: igm_resource
      wait_for_zonal_op op, "insert instance_group_manager #{igm_resource[:name]}"

      igm = @igm_client.get project: @default_project, zone: @default_zone, instance_group_manager: igm_name
      assert_equal igm.target_size, 0

      resize_op = @igm_client.resize project: @default_project, zone: @default_zone, instance_group_manager: igm_name, size: 1
      wait_for_zonal_op resize_op, "resize"

      igm = @igm_client.get project: @default_project, zone: @default_zone, instance_group_manager: igm_name
      assert_equal igm.target_size, 1

      resize_op = @igm_client.resize project: @default_project, zone: @default_zone, instance_group_manager: igm_name,
                                    size: 0
      wait_for_zonal_op resize_op, "resize"

      igm = @igm_client.get project: @default_project, zone: @default_zone, instance_group_manager: igm_name
      assert_equal igm.target_size, 0
    ensure
      $stdout.puts "deleting instance_group_manager #{igm_name}"
      del_op = @igm_client.delete project: @default_project, zone: @default_zone, instance_group_manager: igm_name
      wait_for_zonal_op del_op, "delete instance_group_manager #{igm_name}"

      @templates_client.delete project: @default_project, instance_template: template_name
    end
  end


  private


  def wait_for_global_op operation, op_type
    operation = operation.operation
    $stdout.puts "Waiting for global #{op_type} operation #{operation.name}."
    starttime = Time.now
    while (operation.status != :DONE) && (Time.now < starttime + 100)
      operation = @global_ops_client.get operation: operation.name, project: @default_project
      sleep 3
    end
  end

  def wait_for_zonal_op operation, op_type
    operation = operation.operation
    $stdout.puts "Waiting for zonal #{op_type} operation #{operation.name}."
    starttime = Time.now
    while (operation.status != :DONE) && (Time.now < starttime + 200)
      operation = @zonal_ops_client.get operation: operation.name, project: @default_project, zone: @default_zone
      sleep 3
    end
  end
end
