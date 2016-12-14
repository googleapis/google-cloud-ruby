require 'test_helper'

describe Gcloud::Jsondoc, :module do

  before do
    registry = YARD::Registry.load(["test/error_fixtures/**/*.rb"], true)
    @generator = Gcloud::Jsondoc::Generator.new registry
  end

  it "raises RuntimeError if @return has no type" do

    assert_raises Gcloud::Jsondoc::YardSyntaxError do
      @generator.build!
    end
  end
end
