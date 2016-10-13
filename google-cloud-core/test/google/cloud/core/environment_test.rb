require "helper"
require "google/cloud/core/environment"

describe Google::Cloud::Core::Environment do
  describe ".gce?" do
    it "returns false if .gke? is true" do
      ENV.stub :[], nil do
        Google::Cloud::Core::Environment.stub :gke?, true do
          Google::Cloud::Core::Environment.stub :gce_vm?, true do
            Google::Cloud::Core::Environment.gce?.must_equal false
          end
        end
      end
    end

    it "returns false if .gae? is true" do
      ENV.stub :[], nil do
        Google::Cloud::Core::Environment.stub :gae?, true do
          Google::Cloud::Core::Environment.stub :gce_vm?, true do
            Google::Cloud::Core::Environment.gce?.must_equal false
          end
        end
      end
    end
  end

  describe ".get_metadata_attribute" do
    let(:succ_response) { OpenStruct.new status: 200, body: "Success!" }
    let(:fail_response) { OpenStruct.new status: 500, body: "Failed!" }

    after do
      Google::Cloud::Core::Environment.instance_variable_set "@metadata", {}
    end

    it "returns attr if request made successfully" do
      request_mock = Minitest::Mock.new
      request_mock.expect :options, OpenStruct.new

      Faraday.default_connection.stub :get, succ_response, request_mock do
        attr = Google::Cloud::Core::Environment.get_metadata_attribute "uri", :attr
        attr.must_equal succ_response.body
      end
    end

    it "returns nil if request failed" do
      request_mock = Minitest::Mock.new
      request_mock.expect :options, OpenStruct.new

      Faraday.default_connection.stub :get, fail_response, request_mock do
        attr = Google::Cloud::Core::Environment.get_metadata_attribute "uri", :attr
        attr.must_be :nil?
      end
    end
  end
end
