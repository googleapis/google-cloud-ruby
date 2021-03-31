require 'securerandom'
require "minitest/autorun"

require "google/cloud/compute/v1/zones"
require "google/cloud/compute/v1/regions"

$default_zone = 'us-central1-a'
$default_project = ENV['PROJECT_ID']

class TestUseComputePagination < Minitest::Test

  def setup
    @client = Google::Cloud::Compute::V1::Zones::Rest::Client.new
    if $default_project.eql? NIL
      skip("PROJECT_ID must be set before running this test")
    end
  end

  def test_basic_list
    result = @client.list(project: $default_project)['items']
    s = result.map{|x| x['name']}
    assert s.include? $default_zone
  end

  def test_max_results
    zones = @client.list project: $default_project, max_results: 3
    assert_equal 3, zones.items.length
  end

  def test_next_page_token
    zones = @client.list project: $default_project, max_results: 1
    zones_token = @client.list project: $default_project, page_token: zones.next_page_token, max_results: 1
    assert_equal(false, zones.items.eql?(zones_token.items))
  end

  def test_filter
    zones = @client.list project: $default_project, max_results: 1, filter: "name = us-central1-a"
    assert_equal(zones.items[0].name, 'us-central1-a')
  end

end
