require 'test_helper'

describe Gcloud::Jsondoc, :generator do

  before do
    registry = YARD::Registry.load(["test/fixtures/**/*.rb"], true)
    generator = Gcloud::Jsondoc::Generator.new registry
    @docs = generator.docs
  end

  it "must have 3 docs" do
    @docs.size.must_equal 5
  end
end
