require "minitest/autorun"

require "google/cloud/compute/v1/instances"
require "google/cloud/compute/v1/instance_group_managers"
require "google/cloud/compute/v1/instance_templates"
require "google/cloud/compute/v1/zone_operations"
require "google/cloud/compute/v1/global_operations"

# Tests for GCE instances
class InstancesSmokeTest < Minitest::Test
  def setup
    @default_zone = "us-central1-a"
    @default_project = ENV["COMPUTE_TEST_PROJECT"]
    @machine_type = "zones/#{@default_zone}/machineTypes/n1-standard-1"
    @image =  "projects/debian-cloud/global/images/family/debian-10"
    @client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new
    @client_ops = ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
    @name = "rbgapic#{rand 10_000_000}"
    @instances = []
    skip "COMPUTE_TEST_PROJECT must be set before running this test" if @default_project.nil?
  end

  def teardown
    @instances.each do |instance|
      @client.delete project: @default_project, zone: @default_zone, instance: instance
    end
  end

  def test_create_instance
    insert_resource
    instance = read_instance
    assert_equal @name, instance.name
    assert_equal 1, instance.disks.length
    assert instance.machine_type.include?(@machine_type)
  end

  def test_aggregated_list
    insert_resource
    result = @client.aggregated_list project: @default_project
    instances = result.page.response.items["zones/#{@default_zone}"].instances
    names = instances.map(&:name)
    assert_includes names, @name
  end

  def test_list
    insert_resource
    names = @client.list(project: @default_project, zone: @default_zone).map(&:name)
    assert_includes names, @name
  end

  def test_patch
    resource = {
      enable_secure_boot: true
    }
    insert_resource
    @client.stop instance: @name, zone: @default_zone, project: @default_project
    $stdout.puts "Waiting for instance #{@name} to stop."
    instance = read_instance
    starttime = Time.now
    while (instance.status != :Terminated) && (Time.now < starttime + 200)
      instance = read_instance
      sleep 10
    end
    assert_equal false, instance.shielded_instance_config.enable_secure_boot
    operation = @client.update_shielded_instance_config(instance: @name, zone: @default_zone, project: @default_project,
                                                 shielded_instance_config_resource: resource)
    wait_for_zonal_op operation, "update"
    instance = read_instance
    assert_equal true, instance.shielded_instance_config.enable_secure_boot
  end

  def test_api_error_404
    exception = assert_raises Google::Cloud::NotFoundError do
      @client.get instance: "nonexists1123512345", zone: @default_zone, project: @default_project
    end

    assert_match(/The resource '[^']+' was not found/, exception.message)
  end

  def test_client_error_no_prj
    exception = assert_raises Google::Cloud::InvalidArgumentError do
      @client.get instance: "nonexists1123512345", zone: @default_zone
    end
    assert exception.message.include?("An error has occurred when making a REST request: Invalid resource field value in the request.")
  end

  def test_update_desc_to_empty
    # We test here: 1)set body field to empty string
    #               2)optional body field not set
    insert_resource
    instance = read_instance
    assert_equal "test", instance.description
    assert_equal 0, instance.scheduling.min_node_cpus
    instance.description = ""
    operation = @client.update instance: @name, instance_resource: instance, project: @default_project, zone: @default_zone
    wait_for_zonal_op operation, "update"
    fetched = read_instance
    assert_equal "", fetched.description
    assert_equal 0, fetched.scheduling.min_node_cpus
  end

  private

  def wait_for_zonal_op operation, op_type
    operation = operation.operation
    $stdout.puts "Waiting for zonal #{op_type} operation #{operation.name}."
    starttime = Time.now
    while (operation.status != :DONE) && (Time.now < starttime + 200)
      operation = @client_ops.get operation: operation.name, project: @default_project, zone: @default_zone
      sleep 3
    end
  end

  def read_instance
    @client.get project: @default_project, zone: @default_zone, instance: @name
  end

  def insert_resource
    instance_resource = {
      name: @name,
      description: "test",
      machine_type: @machine_type,
      network_interfaces: [
        {
          access_configs: [
            { name: "default" }
          ]
        }
      ],
      disks: [
        {
          initialize_params:
            {
              source_image: @image
            },
          boot: true,
          auto_delete: true,
          type: "PERSISTENT"
        }
      ]
    }
    operation = @client.insert project: @default_project, zone: @default_zone, instance_resource: instance_resource
    $stdout.puts "Inserting instance #{@name}."
    @instances.append @name
    wait_for_zonal_op operation, "insert"
    $stdout.puts "Operation to insert instance #{@name} completed."
  end
end
