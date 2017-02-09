require 'test_helper'

describe Gcloud::Jsondoc, :generator do
  let(:registry) { YARD::Registry.load(["test/fixtures/**/*.rb"], true) }
  let(:source_path) { "my-module-subdir" }
  let(:generate) do
    {
      types: [
        {
          title: "Google::Datastore::V1::DataTypes",
          toc: { package: "Google::Datastore::V1", include: "includedmodule/" }
        }
      ]
    }
  end
  let(:generator) do
    generator = Gcloud::Jsondoc::Generator.new registry, nil, generate: generate
    generator.build!
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
    docs.size.must_equal 11
    docs[0].full_name.must_equal "mymodule"
    docs[0].name.must_equal "MyModule"
    docs[0].filepath.must_equal "mymodule.json"
  end

  it "must have all types" do
    types.must_be_kind_of Array
    types.size.must_equal 28
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

  it "must generate a TOC doc as directed in the generate option" do
    toc = docs.last
    toc.filepath.must_equal "google/datastore/v1/datatypes.json"
    toc_json = toc.jbuilder.attributes!
    toc_json["id"].must_equal "google/datastore/v1/datatypes"
    toc_json["name"].must_equal "DataTypes"
    toc_json["title"].must_equal ["Google","Datastore","V1","DataTypes"]
  end

  it "must generate a TOC type as directed in the generate option" do
    toc = types.last
    toc.filepath.must_equal "google/datastore/v1/datatypes.json"
  end
end
