gem "minitest"
require 'minitest/autorun'
require 'minitest/rg'

describe 'minitest-rg' do
  # generate passing
  it "passes" do
    assert_equal 1, 1, "Pass should be GREEN"
  end

  # generate failing
  it "fails" do
    assert_equal 1, 2, "Failure should be RED"
  end

  # generate error
  it "error" do
    raise "Error should be YELLOW"
  end

  # generate skip
  it "skips" do
    skip "Skip should be CYAN"
  end
end
