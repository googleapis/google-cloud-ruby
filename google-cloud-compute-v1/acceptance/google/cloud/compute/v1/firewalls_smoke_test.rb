require "minitest/autorun"

require "google/cloud/compute/v1/firewalls"
require "google/cloud/compute/v1/global_operations"

# Tests for GCE firewalls
class FirewallsSmokeTest < Minitest::Test
  def setup
    @default_project = ENV["COMPUTE_TEST_PROJECT"]
    skip "COMPUTE_TEST_PROJECT must be set before running this test" if @default_project.nil?
    @client = ::Google::Cloud::Compute::V1::Firewalls::Rest::Client.new
    @client_ops = ::Google::Cloud::Compute::V1::GlobalOperations::Rest::Client.new
    @name = "rbgapic#{rand 10_000_000}"
    @firewalls = []
  end

  def teardown
    @firewalls.each do |firewall|
      @client.delete project: @default_project, firewall: firewall
    end
  end

  def test_create_fetch
    # we want to test here a field like IPProtocol
    resource = {
      name: @name,
      source_ranges: ["0.0.0.0/0"],
      allowed: [
        {
          I_p_protocol: "tcp",
          ports: ["80"],
        },
      ],
    }
    operation = @client.insert project: @default_project, firewall_resource: resource
    @client_ops.wait operation: operation.operation.name, project: @default_project
    @firewalls.append @name
    fetched = @client.get project: @default_project, firewall: @name
    assert_equal "tcp", fetched.allowed[0].I_p_protocol
  end

end
