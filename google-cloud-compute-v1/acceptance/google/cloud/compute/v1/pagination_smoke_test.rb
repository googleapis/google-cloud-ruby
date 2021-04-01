require "minitest/autorun"

require "google/cloud/compute/v1/zones"
require "google/cloud/compute/v1/regions"


# Tests for pagination in GCE
class PaginationSmokeTest < Minitest::Test
  def setup
    @default_zone = "us-central1-a"
    @default_project = ENV["V1_TEST_PROJECT"]
    @client = Google::Cloud::Compute::V1::Zones::Rest::Client.new
    skip "V1_TEST_PROJECT must be set before running this test" if @default_project.nil?
  end

  def test_basic_list
    result = @client.list(project: @default_project)["items"]
    s = result.map(&:name)
    assert_includes s, @default_zone
  end

  def test_max_results
    zones = @client.list project: @default_project, max_results: 3
    assert_equal 3, zones.items.length
  end

  def test_next_page_token
    zones = @client.list project: @default_project, max_results: 1
    zones_token = @client.list project: @default_project, page_token: zones.next_page_token, max_results: 1
    assert_equal false, zones.items.eql?(zones_token.items)
  end

  def test_filter
    zones = @client.list project: @default_project, max_results: 1, filter: "name = us-central1-a"
    assert_equal "us-central1-a", zones.items[0].name
  end
end
