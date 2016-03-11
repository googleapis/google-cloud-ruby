require 'test_helper'

describe Gcloud::Jsondoc, :module do

  before do
    registry = YARD::Registry.load(["test/fixtures/**/*.rb"], true)
    generator = Gcloud::Jsondoc::Generator.new registry
    generator.build!
    @doc = generator.docs[0].jbuilder.attributes! # docs[2] in class_test.rb
  end

  it "must have attributes at root" do
    @doc.keys.size.must_equal 8
    @doc.keys[0].must_equal "id"
  end

  describe "when given a module" do
    it "must have an id" do
      @doc["id"].must_equal "mymodule"
    end

    it "must have service metadata" do
      @doc["name"].must_equal "MyModule"
      expected = "<p>The outermost module in the test fixtures.</p>\n\n<p>This is a Ruby <a href=\"http://docs.ruby-lang.org/en/2.2.0/Module.html\">module</a>.</p>\n\n<div class=\"highlighter-rouge\"><pre class=\"ruby\"><code><span class=\"nb\">require</span> <span class=\"s2\">\"gcloud\"</span>\n\n<span class=\"n\">gcloud</span> <span class=\"o\">=</span> <span class=\"no\">Gcloud</span><span class=\"p\">.</span><span class=\"nf\">new</span> <span class=\"s2\">\"publicdata\"</span>\n<span class=\"n\">bigquery</span> <span class=\"o\">=</span> <span class=\"n\">gcloud</span><span class=\"p\">.</span><span class=\"nf\">bigquery</span>\n</code></pre>\n</div>\n\n<p>It lists all datasets in the project.</p>"
      @doc["description"].must_equal expected
      @doc["source"].must_equal "test/fixtures/my_module.rb#L15"
    end

    it "can have methods" do
      methods = @doc["methods"]
      methods.size.must_equal 1
    end
  end

  describe "when a module has a method" do

    it "must have metadata" do
      method = @doc["methods"][0]
      method["name"].must_equal "example_method"
      method["description"].must_equal "<p>Creates a new object for testing this library, as explained in <a href=\"https://en.wikipedia.org/wiki/Software_testing\">this\narticle on testing</a>.</p>\n\n<p>Each call creates a new instance.</p>"
      method["source"].must_equal "test/fixtures/my_module.rb#L45"
    end

    it "must have method examples" do
      method = @doc["methods"][0]
      method["examples"].size.must_equal 1
      method["examples"][0]["caption"].must_equal "<p>You can pass options.</p>"
      method["examples"][0]["code"].must_equal "return_object = Mymodule.storage \"my name\", opt_in: true do |config|\n  config.more = \"more\"\nend"
    end

    it "must have method resources" do
      method = @doc["methods"][0]
      method["resources"].size.must_equal 1
      method["resources"][0]["link"].must_equal "http://ntp.org/documentation.html"
      method["resources"][0]["title"].must_equal "NTP Documentation"
    end

    it "must have params" do
      params = @doc["methods"][0]["params"]
      params.size.must_equal 3
      params[0]["name"].must_equal "personal_name"
      params[0]["types"].must_equal ["String"]
      params[0]["description"].must_equal "The name, which can be any name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this\narticle on names</a>"
      params[0]["optional"].must_equal false
      params[0]["default"].must_be :nil?
      params[0]["nullable"].must_equal false

      params[1]["name"].must_equal "email"
      params[1]["types"].must_equal ["String", "Array<String>", "nil"]
      params[1]["description"].must_equal "The person’s email or emails."
      params[1]["optional"].must_equal true
      params[1]["default"].must_equal "nil"
      params[1]["nullable"].must_equal true

      params[2]["name"].must_equal "opt_in"
      params[2]["types"].must_equal ["Boolean", "nil"]
      params[2]["description"].must_equal "Whether to subscribe to <em>all</em> mailing lists."
      params[2]["optional"].must_equal true
      params[2]["default"].must_equal "false"
      params[2]["nullable"].must_equal true
    end

    it "must have exceptions" do
      exceptions = @doc["methods"][0]["exceptions"]
      exceptions.size.must_equal 1
      exceptions[0]["type"].must_equal "ArgumentError"
      exceptions[0]["description"].must_equal "if the name is not a name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this\narticle</a>"
    end

    it "must have returns" do
      returns = @doc["methods"][0]["returns"]
      returns.size.must_equal 1
      returns[0]["types"].must_equal ["<a data-custom-type=\"mymodule/returnclass\">MyModule::ReturnClass</a>"]
      returns[0]["description"].must_equal "an empty object instance"
    end
  end
end
