require 'test_helper'

describe Gcloud::Jsondoc, :generator do

  before do
    registry = YARD::Registry.load(["test/fixtures/**/*.rb"], true)
    generator = Gcloud::Jsondoc::Generator.new registry
    generator.build!
    @docs = generator.docs
    @types = generator.docs
  end

  it "must have all docs" do
    @docs.size.must_equal 5
  end

  it "must have all types" do
    @types.must_be_kind_of Array
    @types.size.must_equal 5
    @types[0].full_name.must_equal "mymodule"
    @types[0].name.must_equal "MyModule"
    @types[0].filepath.must_equal "mymodule.json"
  end
end
