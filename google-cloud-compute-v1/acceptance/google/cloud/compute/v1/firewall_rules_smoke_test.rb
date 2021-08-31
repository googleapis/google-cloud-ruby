require "minitest/autorun"

require "google/cloud/compute/v1/firewall_policies"
require "google/cloud/compute/v1/global_organization_operations"
require "pp"

# Tests for GCE addresses
class FirewallPoliciesSmokeTest < Minitest::Test
    def setup
      @client = ::Google::Cloud::Compute::V1::FirewallPolicies::Rest::Client.new
      @client_ops ||= ::Google::Cloud::Compute::V1::GlobalOrganizationOperations::Rest::Client.new
      @name = "rbgapic#{rand 10_000_000}"
    end
  
    def test_integration
        fp_desc = {
            description: "#{@name}_desc",
            short_name: @name
        }

        parent = "folders/rbgapic_test_folder"

        op = @client.insert firewall_policy_resource: fp_desc

        pp op

        op_done = wait_until_done op

        pp op_done

        #fp = client.get 

    end

    def wait_until_done gapic_op, timeout: 3 * 60
        operation = gapic_op.operation
        request = { operation: operation.name, }
        deadline = Time.now + timeout
        # Wait until the operation is not RUNNING.
        # #wait is on a best-effort basis and does not guarantee to block until either
        # the operation is DONE or the deadline is reached.
        while operation.status == :RUNNING
          now = Time.now
          if now > deadline
            raise "operation timed out"
          end
          options = { timeout: deadline - now }
          operation = @client.wait request, options
        end
        operation
    end
end