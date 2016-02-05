require 'test_helper'

describe Gcloud::Jsondoc, :docs do


  before do
    registry = YARD::Registry.load(["test/fixtures/**/*.rb"], true)
    @builder = Gcloud::Jsondoc.new registry
    @docs = @builder.docs[0].jbuilder.attributes!
  end

  it "must have attributes at root" do
    @docs.size.must_equal 4
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
      metadata["resources"][0]["href"].must_equal "http://ntp.org/documentation.html"
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
      params[1]["description"].must_equal "The person&#39;s email or emails."
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

  describe "when given a module class" do
    it "must have a pages entry" do
      pages = @docs["pages"]
      pages.size.must_equal 3
      pages[0]["id"].must_equal "returnclass"
      pages[1]["id"].must_equal "myclass"
      pages[2]["id"].must_equal "myconfig" # TODO: don't include in pages
    end

    it "must have metadata" do
      metadata = @docs["pages"][1]["metadata"]
      metadata["name"].must_equal "MyClass"
      metadata["description"].must_equal "<p>You can use MyClass for almost anything.</p>"
      metadata["source"].must_equal "test/fixtures/my_module/my_class.rb#L4"
    end

    it "can have methods" do
      methods = @docs["pages"][1]["methods"]
      methods.size.must_equal 1
    end

    describe "when a class has a method" do
      it "must have metadata" do
        metadata = @docs["pages"][1]["methods"][0]["metadata"]
        metadata["name"].must_equal "example_instance_method"
        metadata["description"].must_equal "<p>Accepts many arguments for testing this library. Also accepts a block if a block is given.</p>  <p>Do not call this method until you have read all of its documentation.</p>"
        metadata["source"].must_equal "test/fixtures/my_module/my_class.rb#L50"
      end

      it "must have metadata examples" do
        metadata = @docs["pages"][1]["methods"][0]["metadata"]
        metadata["examples"].size.must_equal 2
        metadata["examples"][0]["caption"].must_equal "You can pass a block."
        metadata["examples"][0]["code"].must_equal "my_class = MyClass.new\nmy_class.example_instance_method times: 5 do |my_config|\n  my_config.limit = 5\n  true\nend"
      end

      it "must have metadata resources" do
        metadata = @docs["pages"][1]["methods"][0]["metadata"]
        metadata["resources"].size.must_equal 1
        metadata["resources"][0]["href"].must_equal "http://ruby-doc.org/core-2.2.0/Proc.html"
        metadata["resources"][0]["title"].must_equal "Proc objects are blocks of code that have been bound to a set of local variables."
      end

      it "can have params with options hash and keyword args" do
        params = @docs["pages"][1]["methods"][0]["params"]
        params.size.must_equal 8

        params[0]["name"].must_equal "policy"
        params[0]["types"].must_equal ["String"]
        params[0]["description"].must_equal "A <em>policy</em> is a deliberate system of principles to guide decisions and achieve rational outcomes.  As defined in <a href=\"https://en.wikipedia.org/wiki/Policy\">policy</a>."
        params[0]["optional"].must_equal true
        params[0]["default"].must_equal "\"ALWAYS\""
        params[0]["nullable"].must_equal false

        params[1]["name"].must_equal "opts"
        params[1]["types"].must_equal ["Hash"]
        params[1]["description"].must_equal "Optional parameters hash, not to be confused with keyword arguments."
        params[1]["optional"].must_equal true
        params[1]["default"].must_equal "{}"
        params[1]["nullable"].must_equal false

        params[2]["name"].must_equal "opts.subject"
        params[2]["types"].must_equal ["String"]
        params[2]["description"].must_equal "The subject"
        params[2]["optional"].must_equal true
        params[2]["default"].must_be :nil?
        params[2]["nullable"].must_equal false

        params[3]["name"].must_equal "opts.body"
        params[3]["types"].must_equal ["String"]
        params[3]["description"].must_equal "The body"
        params[3]["optional"].must_equal true
        params[3]["default"].must_be :nil?
        params[3]["nullable"].must_equal false

        params[4]["name"].must_equal "times"
        params[4]["types"].must_equal ["Integer"]
        params[4]["description"].must_equal "a keyword argument for how many times"
        params[4]["optional"].must_equal true
        params[4]["default"].must_equal "10"
        params[4]["nullable"].must_equal false

        params[5]["name"].must_equal "prefix"
        params[5]["types"].must_equal ["String"]
        params[5]["description"].must_equal "a keyword argument for the prefix"
        params[5]["optional"].must_equal true
        params[5]["default"].must_equal "nil"
        params[5]["nullable"].must_equal true

        params[6]["name"].must_equal "yield"
        params[6]["types"].must_equal ["block"]
        params[6]["description"].must_equal "An optional block for setting configuration."
        params[6]["optional"].must_equal true
        params[6]["default"].must_be :nil?
        params[6]["nullable"].must_equal false

        params[7]["name"].must_equal "yield.c"
        params[7]["types"].must_equal ["MyConfig"]
        params[7]["description"].must_equal "A new instance of MyConfig. See <a href=\"https://en.wikipedia.org/wiki/Configuration_management\">configuration</a> for more info."
        params[7]["optional"].must_equal false
        params[7]["default"].must_be :nil?
        params[7]["nullable"].must_equal false

        # TODO: support @yieldreturn as an additional parameter?
      end

    end
  end
end
