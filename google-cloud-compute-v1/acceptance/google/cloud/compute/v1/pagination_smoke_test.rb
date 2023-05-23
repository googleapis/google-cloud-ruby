require "minitest/autorun"

require "google/cloud/errors"
require "google/cloud/compute/v1/accelerator_types"

# Tests for pagination in GCE
class PaginationSmokeTest < Minitest::Test
  def setup
    @default_zone = "us-central1-a"
    @default_project = ENV["COMPUTE_TEST_PROJECT"]
    @client = Google::Cloud::Compute::V1::AcceleratorTypes::Rest::Client.new
    skip "COMPUTE_TEST_PROJECT must be set before running this test" if @default_project.nil?
  end

  def test_basic_list
    names = @client.list(project: @default_project, zone:@default_zone).map(&:name)
    assert_includes names, "nvidia-tesla-a100"
  end

  def test_list_each
    ats = []
    @client.list(zone: @default_zone, project: @default_project, max_results:2).each do |accelerator_type|
      ats << accelerator_type.name
    end
    assert_includes ats, "nvidia-tesla-t4"
  end

  def test_list_each_page
    ats = []
    @client.list(zone: @default_zone, project: @default_project, max_results:2).each_page do |page|
      page.each do |accelerator_type|
        ats << accelerator_type.name
      end
    end
    assert_includes ats, "nvidia-tesla-t4"
  end

  def test_max_results
    ats = @client.list project: @default_project, zone:@default_zone, max_results:2
    assert_equal 2, ats.page.resources.length
  end

  def test_next_page_token
    ats = @client.list project: @default_project, zone:@default_zone, max_results:1
    at_names = ats.page.resources.map(&:name)
    ats.next_page!
    at_next_names = ats.page.resources.map(&:name)

    assert_equal false, at_names.eql?(at_next_names)
  end

  def test_filter
    ats = @client.list project: @default_project, zone:@default_zone, max_results:1, filter: "name = nvidia-tesla-a100"
    assert_equal "nvidia-tesla-a100", ats.first.name
  end

  def test_aggregated_list_each
    zone_at_pairs = []
    @client.aggregated_list(project: @default_project, max_results:10).each do |zone, at_grouped_list|
      at_grouped_list.accelerator_types.each { |at|  zone_at_pairs << [zone, at.name] }
    end

    assert_includes zone_at_pairs, %w[zones/us-central1-a nvidia-tesla-a100]
  end

  def test_aggregated_list_each_page
    zone_at_pairs = []
    @client.aggregated_list(project: @default_project, max_results:10).each_page do |page|
      page.each do |zone_grouped_list|
        zone = zone_grouped_list[0]
        at_grouped_list = zone_grouped_list[1]
        at_grouped_list.accelerator_types.each { |at|  zone_at_pairs << [zone, at.name] }
      end
    end

    assert_includes zone_at_pairs, %w[zones/us-central1-a nvidia-tesla-a100]
  end
end
