require 'test_helper'

describe Gcloud::Jsondoc, :generator do
  let(:registry) { YARD::Registry.load(["test/fixtures/**/*.rb"], true) }
  let(:source_path) { "my-module-subdir" }
  let(:generator) do
    generator = Gcloud::Jsondoc::Generator.new registry
    generator.build!
    generator.set_types
    generator
  end
  let(:docs) { generator.docs }
  let(:types) { generator.types }
  let(:generator_source_path) do
    generator = Gcloud::Jsondoc::Generator.new registry, source_path
    generator.build!
    generator
  end
  let(:docs_source_path) { generator_source_path.docs }

  it "must have all docs" do
    docs.must_be_kind_of Array
    docs.size.must_equal 5
    docs[0].full_name.must_equal "mymodule"
    docs[0].name.must_equal "MyModule"
    docs[0].filepath.must_equal "mymodule.json"
  end

  it "must have all types" do
    types.must_be_kind_of Array
    types.size.must_equal 19
    types[0].full_name.must_equal "mymodule"
    types[0].name.must_equal "MyModule"
    types[0].filepath.must_equal "mymodule.json"
  end

  describe "when given a source path" do
    it "must produce module doc with source path prepended to source" do
      doc_json = docs_source_path.first.jbuilder.attributes!
      doc_json["id"].must_equal "mymodule"
      doc_json["source"].must_equal "my-module-subdir/test/fixtures/my_module.rb#L15"
    end
  end
end
