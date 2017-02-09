require 'test_helper'

describe Gcloud::Jsondoc, :generated_toc_doc do
  let(:registry) { YARD::Registry.load(["test/fixtures/**/*.rb"], true) }
  let(:generate) do
    { types: [{title: "Google::Datastore::V1::DataTypes", toc: {package: "Google::Datastore::V1", include: "includedmodule/"}}] }
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
<p>The <code>Google::Datastore::V1</code> module provides the following types:</p>

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
      <td><p>When mode is +TRANSACTIONAL+, mutations affecting a single entity are
applied in order.</td>
    </tr>

    <tr>
      <td><a data-custom-type=\"includedmodule/classb\">IncludedModule::ClassB</a></td>
      <td><p>Entities not found as +ResultType.KEY_ONLY+ entities.</td>
    </tr>

    <tr>
      <td><a data-custom-type=\"includedmodule/nested/classa\">IncludedModule::Nested::ClassA</a></td>
      <td><p>The response for Datastore::RunQuery.</p>.</td>
    </tr>

  </tbody>
</table>
EOT
    toc_json["description"].must_equal expected_html
  end
end
