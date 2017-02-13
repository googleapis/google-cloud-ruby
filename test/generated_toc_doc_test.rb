require 'test_helper'

describe Gcloud::Jsondoc, :generated_toc_doc do
  let(:registry) { YARD::Registry.load(["test/fixtures/**/*.rb"], true) }
  let(:generate) do
    {
      documents: [
        {
          type: "toc",
          title: "Google::Datastore::V1::DataTypes",
          modules: [
            {
              title: "IncludedModule",
              include: ["includedmodule/"]
            },
            {
              title: "IncludedModule2",
              include: ["includedmodule2/"],
              exclude: ["includedmodule2/nested"]
            }
          ]
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

  it "must generate a TOC doc as directed in the generate option" do
    toc = docs.last
    toc.must_be_kind_of Gcloud::Jsondoc::GeneratedTocDoc
    toc.filepath.must_equal "google/datastore/v1/datatypes.json"
    toc_json = toc.jbuilder.attributes!
    toc_json["id"].must_equal "google/datastore/v1/datatypes"
    toc_json["name"].must_equal "DataTypes"
    toc_json["title"].must_equal ["Google","Datastore","V1","DataTypes"]
    toc_json["source"].must_equal ""
    toc_json["resources"].must_equal []
    toc_json["examples"].must_equal []
    toc_json["methods"].must_equal []
    expected_html = <<EOT
<h4>IncludedModule</h4>

<table class="table">
  <thead>
    <tr>
      <th>Class</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>

    <tr>
      <td><a data-custom-type=\"includedmodule/classa\">IncludedModule::ClassA</a></td>
      <td>When mode is +TRANSACTIONAL+, mutations affecting a single entity are
applied in order.</td>
    </tr>

    <tr>
      <td><a data-custom-type=\"includedmodule/any\">IncludedModule::Any</a></td>
      <td>+Any+ contains an arbitrary serialized protocol buffer message along with a
URL that describes the type of the serialized message.</td>
    </tr>

    <tr>
      <td><a data-custom-type=\"includedmodule/nested/classa\">IncludedModule::Nested::ClassA</a></td>
      <td>The response for Datastore::RunQuery.</td>
    </tr>

  </tbody>
</table>
<h4>IncludedModule2</h4>

<table class="table">
  <thead>
    <tr>
      <th>Class</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>

    <tr>
      <td><a data-custom-type=\"includedmodule2/classa\">IncludedModule2::ClassA</a></td>
      <td>When mode is +TRANSACTIONAL+, mutations affecting a single entity are
applied in order.</td>
    </tr>

    <tr>
      <td><a data-custom-type=\"includedmodule2/classb\">IncludedModule2::ClassB</a></td>
      <td>Entities not found as +ResultType.KEY_ONLY+ entities.</td>
    </tr>

  </tbody>
</table>

EOT
    toc_json["description"].must_equal expected_html
  end
end
