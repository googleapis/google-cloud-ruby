require "gapic/common/polling_harness"
require "gapic/common/retry_policy"


# Extends functionality of the Table class in order to use the Gapic::Common::PollingHarness for replication wait methods.
module Google
  module Cloud
    module Bigtable
      class Table

        # @private
        # Implements `wait_for_replication` via PollingHarness.
        def wait_for_replication_with_polling_harness timeout, check_interval
          raise InvalidArgumentError, "'check_interval' cannot be greater than timeout" if check_interval > timeout

          retry_policy = Gapic::Common::RetryPolicy.new initial_delay: check_interval, multiplier: 1, timeout: timeout
          polling_harness = Gapic::Common::PollingHarness.new retry_policy: retry_policy

          token = generate_consistency_token
          status = false
          polling_harness.wait do
            status = check_consistency token
            status ? status : nil
          end
          status
        end

        # @private
        def wait_for_replication_test use_polling_harness: false, timeout: 600, check_interval: 5
          if use_polling_harness
            wait_for_replication_with_polling_harness(timeout, check_interval)
          else
            wait_for_replication(timeout: timeout, check_interval: check_interval)
          end
        end
      end
    end
  end
end
