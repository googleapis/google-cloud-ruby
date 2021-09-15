require "minitest/autorun"

require "google/cloud/compute/v1/addresses"
require "google/cloud/compute/v1/region_operations"

# Tests for GCE addresses
class AddressesSmokeTest < Minitest::Test
  def setup
    @default_region = "us-central1"
    @default_project = ENV["COMPUTE_TEST_PROJECT"]
    @client = ::Google::Cloud::Compute::V1::Addresses::Rest::Client.new
    @client_ops ||= ::Google::Cloud::Compute::V1::RegionOperations::Rest::Client.new
    @name = "rbgapic#{rand 10_000_000}"
    @addresses = []
    skip "COMPUTE_TEST_PROJECT must be set before running this test" if @default_project.nil?
  end

  def teardown
    @addresses.each do |address|
      @client.delete project: @default_project, region: @default_region, address: address
    end
  end

  def test_create
    insert_address
    address = @client.get project: @default_project, region: @default_region, address: @name
    assert_equal @name, address.name
  end

  def test_list
    insert_address
    names = @client.list(project: @default_project, region: @default_region).map(&:name)
    assert_includes names, @name
  end

  def test_delete
    insert_address
    @addresses.delete @name
    operation = @client.delete project: @default_project, region: @default_region, address: @name
    wait_for_regional_op operation, "delete"
  end

  def test_non_ascii
    address_resource = {
      name: @name,
      description: "тест"
    }
    operation = @client.insert project: @default_project, region: @default_region, address_resource: address_resource
    @addresses.append @name
    wait_for_regional_op operation, "insert"
    address = @client.get project: @default_project, region: @default_region, address: @name
    assert_equal @name, address.name
    assert_equal "тест", address.description
  end

  private

  def insert_address
    address_resource = {
      name: @name
    }
    $stdout.puts "Inserting address #{@name}."
    operation = @client.insert project: @default_project, region: @default_region, address_resource: address_resource
    @addresses.append @name
    wait_for_regional_op operation, "insert"
    $stdout.puts "Operation to insert address #{@name} completed."
  end

  def wait_for_regional_op operation, op_type
    operation = operation.operation
    $stdout.puts "Waiting for regional #{op_type} operation #{operation.name}."
    starttime = Time.now
    while (operation.status != :DONE) && (Time.now < starttime + 60)
      operation = @client_ops.get operation: operation.name, project: @default_project, region: @default_region
      sleep 3
    end
  end
end
