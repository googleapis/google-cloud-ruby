require "minitest/autorun"

require "google/cloud/compute/v1/images"
require "google/cloud/compute/v1/global_operations"

# Tests for GCE images
class ImagesSmokeTest < Minitest::Test
  def setup
    @default_project = ENV["COMPUTE_TEST_PROJECT"]
    skip "COMPUTE_TEST_PROJECT must be set before running this test" if @default_project.nil?
    @client = ::Google::Cloud::Compute::V1::Images::Rest::Client.new
    @client_ops = ::Google::Cloud::Compute::V1::GlobalOperations::Rest::Client.new
    @name = "rbgapic#{rand 10_000_000}"
    @images = []
  end

  def teardown
    @images.each do |image|
      @client.delete project: @default_project, image: image
    end
  end

  def test_create_fetch
    # we want to test a field of int64 type
    resource = {
      name: @name,
      license_codes: [5543610867827062957],
      source_image:
        'projects/debian-cloud/global/images/debian-10-buster-v20210721',
    }
    operation = @client.insert project: @default_project, image_resource: resource
    @client_ops.wait operation: operation.name, project: @default_project
    @images.append @name
    fetched = @client.get project: @default_project, image: @name
    assert_equal 5543610867827062957, fetched.license_codes[0]
  end

end