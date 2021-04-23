require "minitest/autorun"

require "google/cloud/compute/v1/addresses"
require "google/cloud/compute/v1/region_operations"

# Tests for GCE addresses
class AddressesSmokeTest < Minitest::Test
  def setup
    @default_region = "us-central1"
    @default_project = ENV["V1_TEST_PROJECT"]
    @client = ::Google::Cloud::Compute::V1::Addresses::Rest::Client.new
    @client_ops ||= ::Google::Cloud::Compute::V1::RegionOperations::Rest::Client.new
    @name = "rbgapic#{rand 10_000_000}"
    @addresses = []
    skip "PROJECT_ID must be set before running this test" if @default_project.nil?
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
    result = @client.list(project: @default_project, region: @default_region)["items"]
    names = result.map(&:name)
    assert_includes names, @name
  end

  def test_delete
    insert_address
    @addresses.delete @name
    op = @client.delete project: @default_project, region: @default_region, address: @name
    wait_for_regional_op op
  end

  def test_non_ascii
    address_resource = {
      name: @name,
      description: "тест"
    }
    op = @client.insert project: @default_project, region: @default_region, address_resource: address_resource
    @addresses.append @name
    wait_for_regional_op op
    address = @client.get project: @default_project, region: @default_region, address: @name
    assert_equal @name, address.name
    assert_equal "тест", address.description
  end

  private

  def insert_address
    address_resource = {
      name: @name
    }
    op = @client.insert project: @default_project, region: @default_region, address_resource: address_resource
    @addresses.append @name
    wait_for_regional_op op
  end

  def wait_for_regional_op operation
    starttime = Time.now
    while (operation.status != :DONE) && (Time.now < starttime + 60)
      @client_ops.get operation: operation.name, project: @default_project, region: @default_region
      sleep 3
    end
  end
end
