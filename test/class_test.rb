require 'test_helper'

describe Gcloud::Jsondoc, :jsondoc_spec, :class do

  before do
    registry = YARD::Registry.load(["test/fixtures/**/*.rb"], true)
    generator = Gcloud::Jsondoc::Generator.new registry
    generator.build!
    @doc = generator.docs[2].jbuilder.attributes! # docs[0] in module_test.rb
  end

  it "must have attributes at root" do
    @doc.keys.size.must_equal 8
    @doc.keys[0].must_equal "id"
  end

  describe "when given a class" do

    it "must have metadata" do
      @doc["name"].must_equal "MyClass"
      @doc["description"].must_equal "<p>You can use MyClass for almost anything.</p>"
      @doc["source"].must_equal "test/fixtures/my_module/my_class.rb#L4"
    end

    it "should exclude exclude @private and protected methods" do
      methods = @doc["methods"]
      methods.size.must_equal 2
    end

    describe "when a class has methods" do
      it "must have metadata" do
        method = @doc["methods"][0]
        method["name"].must_equal "example_instance_method"
        method["description"].must_equal "<p>Accepts many arguments for testing this library. Has no relation to\n<a data-custom-type=\"mymodule/myclass#other_instance_method\">#other_instance_method</a>. Also accepts a block if a block is given.</p>\n\n<p>Do not call this method until you have read all of its documentation.</p>"
        method["source"].must_equal "test/fixtures/my_module/my_class.rb#L50"
      end

      it "must have method examples" do
        method = @doc["methods"][0]
        method["examples"].size.must_equal 2
        method["examples"][0]["caption"].must_equal "<p>You can pass a block.</p>"
        method["examples"][0]["code"].must_equal "my_class = MyClass.new\nmy_class.example_instance_method times: 5 do |my_config|\n  my_config.limit = 5\n  true\nend"
      end

      it "must have method resources" do
        method = @doc["methods"][0]
        method["resources"].size.must_equal 1
        method["resources"][0]["link"].must_equal "http://ruby-doc.org/core-2.2.0/Proc.html"
        method["resources"][0]["title"].must_equal "Proc objects are blocks of\ncode that have been bound to a set of local variables."
      end

      it "can have params with options hash and keyword args" do
        params = @doc["methods"][0]["params"]
        params.size.must_equal 8

        params[0]["name"].must_equal "policy"
        params[0]["types"].must_equal ["String"]
        params[0]["description"].must_equal "A <em>policy</em> is a deliberate system of principles to\nguide decisions and achieve rational outcomes.  As defined in\n<a href=\"https://en.wikipedia.org/wiki/Policy\">policy</a>."
        params[0]["optional"].must_equal true
        params[0]["default"].must_equal "\"ALWAYS\""
        params[0]["nullable"].must_equal false

        params[1]["name"].must_equal "opts"
        params[1]["types"].must_equal ["Hash"]
        params[1]["description"].must_equal "Optional parameters hash, not to be confused with\nkeyword arguments."
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
        params[7]["description"].must_equal "A new instance of MyConfig. See\n<a href=\"https://en.wikipedia.org/wiki/Configuration_management\">configuration</a>\nfor more info."
        params[7]["optional"].must_equal false
        params[7]["default"].must_be :nil?
        params[7]["nullable"].must_equal false

        # TODO: support @yieldreturn as an additional parameter?
      end


      it "can have returns array" do
        returns = @doc["methods"][0]["returns"]
        returns[0]["description"].must_equal "An array containing the return\nvalue from the block and the block MyConfig argument, or nil if no\nblock was given."
        returns[0]["types"].size.must_equal 2
        returns[0]["types"][0].must_equal "Array&lt;(Boolean, <a data-custom-type=\"mymodule/myconfig\">MyConfig</a>)&gt;"
        returns[0]["types"][1].must_equal "nil"
      end

      it "can have params with variable length argument lists" do
        params = @doc["methods"][1]["params"]
        params.size.must_equal 1

        params[0]["name"].must_equal "items"
        params[0]["types"].must_equal ["Object"]
        params[0]["description"].must_equal "a variable-length argument list"
        params[0]["optional"].must_equal false
        params[0]["default"].must_be :nil?
        params[0]["nullable"].must_equal false
      end
    end
  end
end
