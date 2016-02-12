require 'test_helper'

describe Gcloud::Jsondoc, :module do


  before do
    registry = YARD::Registry.load(["test/fixtures/**/*.rb"], true)
    @builder = Gcloud::Jsondoc.new registry
    @docs = @builder.docs[0].jbuilder.attributes! # docs[2] in class_test.rb
  end

  it "must have attributes at root" do
    @docs.size.must_equal 3
    @docs.keys[0].must_equal "id"
    @docs.keys[1].must_equal "metadata"
    @docs.keys[2].must_equal "methods"
  end

  describe "when given a module" do
    it "must have an id" do
      @docs["id"].must_equal "mymodule"
    end

    it "must have service metadata" do
      metadata = @docs["metadata"]
      metadata["name"].must_equal "MyModule"
      metadata["description"].must_equal "<p>The outermost module in the test fixtures.</p>  <p>This is a Ruby <a href=\"http://docs.ruby-lang.org/en/2.2.0/Module.html\">module</a>.</p>"
      metadata["source"].must_equal "test/fixtures/my_module.rb#L8"
    end

    it "can have methods" do
      methods = @docs["methods"]
      methods.size.must_equal 1
    end
  end

  describe "when a module has a method" do

    it "must have metadata" do
      metadata = @docs["methods"][0]["metadata"]
      metadata["name"].must_equal "example_method"
      metadata["description"].must_equal "<p>Creates a new object for testing this library, as explained in <a href=\"https://en.wikipedia.org/wiki/Software_testing\">this article on testing</a>.</p>  <p>Each call creates a new instance.</p>"
      metadata["source"].must_equal "test/fixtures/my_module.rb#L38"
    end

    it "must have metadata examples" do
      metadata = @docs["methods"][0]["metadata"]
      metadata["examples"].size.must_equal 1
      metadata["examples"][0]["caption"].must_equal "You can pass options."
      metadata["examples"][0]["code"].must_equal "return_object = Mymodule.storage \"my name\", opt_in: true do |config|\n  config.more = \"more\"\nend"
    end

    it "must have metadata resources" do
      metadata = @docs["methods"][0]["metadata"]
      metadata["resources"].size.must_equal 1
      metadata["resources"][0]["link"].must_equal "http://ntp.org/documentation.html"
      metadata["resources"][0]["title"].must_equal "NTP Documentation"
    end

    it "must have params" do
      params = @docs["methods"][0]["params"]
      params.size.must_equal 3
      params[0]["name"].must_equal "personal_name"
      params[0]["types"].must_equal ["String"]
      params[0]["description"].must_equal "The name, which can be any name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this article on names</a>"
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
      exceptions = @docs["methods"][0]["exceptions"]
      exceptions.size.must_equal 1
      exceptions[0]["type"].must_equal "ArgumentError"
      exceptions[0]["description"].must_equal "if the name is not a name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this article</a>"
    end

    it "must have returns" do
      returns = @docs["methods"][0]["returns"]
      returns.size.must_equal 1
      returns[0]["types"].must_equal ["MyModule::ReturnClass"]
      returns[0]["description"].must_equal "an empty object instance"
    end
  end
end
