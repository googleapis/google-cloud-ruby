require "minitest/autorun"

require "google/cloud/compute/v1/instances"
require "google/cloud/compute/v1/zone_operations"

# Tests for GCE instances
class TestUseComputeSmoke < Minitest::Test
  def setup
    @default_zone = "us-central1-a"
    @default_project = ENV["PROJECT_ID"]
    @machine_type = "zones/#{@default_zone}/machineTypes/n1-standard-1"
    @image =  "projects/debian-cloud/global/images/family/debian-10"
    @client = ::Google::Cloud::Compute::V1::Instances::Rest::Client.new
    @name = "rbgapic#{rand 10_000_000}"
    @instances = []
    skip "PROJECT_ID must be set before running this test" if @default_project.nil?
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
    instances = result.items["zones/#{@default_zone}"].instances
    names = instances.map(&:name)
    assert_includes names, @name
  end

  def test_list
    insert_resource
    result = @client.list(project: @default_project, zone: @default_zone)["items"]
    names = result.map(&:name)
    assert_includes names, @name
  end

  def test_patch
    skip "Post methods fail when body is empty"
    resource = {
      enable_secure_boot: true
    }
    insert_resource
    @client.stop instance: @name, zone: @default_zone, project: @default_project
    instance = read_instance
    starttime = Time.now
    while (instance.status != :Terminated) && (Time.now < starttime + 200)
      instance = read_instance
      sleep 10
    end
    assert_equal false, instance.shielded_instance_config.enable_secure_boot
    @client.update_shielded_instance_config(instance: @name, zone: @default_zone, project: @default_project,
                                            shielded_instance_config_resource: resource)
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

  def read_instance
    @client.get project: @default_project, zone: @default_zone, instance: @name
  end

  def insert_resource
    instance_resource = {
      name: @name,
      machine_type: @machine_type,
      network_interfaces: [{ access_configs: [{ name: "default" }] }],
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
    result = @client.insert project: @default_project, zone: @default_zone, instance_resource: instance_resource
    @instances.append @name
    return unless result.status != :DONE
    client_ops ||= ::Google::Cloud::Compute::V1::ZoneOperations::Rest::Client.new
    starttime = Time.now
    while (result.status != :DONE) && (Time.now < starttime + 60)
      result = client_ops.get operation: result.name, project: @default_project, zone: @default_zone
      sleep 3
    end
  end
end
