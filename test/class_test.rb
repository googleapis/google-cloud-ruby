require 'test_helper'

describe Gcloud::Jsondoc, :jsondoc_spec, :class do

  before do
    registry = YARD::Registry.load(["test/fixtures/**/*.rb"], true)
    generator = Gcloud::Jsondoc::Generator.new registry
    @docs = generator.docs[2].jbuilder.attributes! # docs[0] in module_test.rb
  end

  it "must have attributes at root" do
    @docs.size.must_equal 3
    @docs.keys[0].must_equal "id"
    @docs.keys[1].must_equal "metadata"
    @docs.keys[2].must_equal "methods"
  end

  describe "when given a class" do

    it "must have metadata" do
      metadata = @docs["metadata"]
      metadata["name"].must_equal "MyClass"
      metadata["description"].must_equal "<p>You can use MyClass for almost anything.</p>"
      metadata["source"].must_equal "test/fixtures/my_module/my_class.rb#L4"
    end

    it "can have methods" do
      methods = @docs["methods"]
      methods.size.must_equal 2
    end

    describe "when a class has a method" do
      it "must have metadata" do
        metadata = @docs["methods"][0]["metadata"]
        metadata["name"].must_equal "example_instance_method"
        metadata["description"].must_equal "<p>Accepts many arguments for testing this library. Has no relation to <a data-custom-type=\"mymodule/myclass#other_instance_method\">#other_instance_method</a>. Also accepts a block if a block is given.</p>  <p>Do not call this method until you have read all of its documentation.</p>"
        metadata["source"].must_equal "test/fixtures/my_module/my_class.rb#L50"
      end

      it "must have metadata examples" do
        metadata = @docs["methods"][0]["metadata"]
        metadata["examples"].size.must_equal 2
        metadata["examples"][0]["caption"].must_equal "<p>You can pass a block.</p>"
        metadata["examples"][0]["code"].must_equal "my_class = MyClass.new\nmy_class.example_instance_method times: 5 do |my_config|\n  my_config.limit = 5\n  true\nend"
      end

      it "must have metadata resources" do
        metadata = @docs["methods"][0]["metadata"]
        metadata["resources"].size.must_equal 1
        metadata["resources"][0]["link"].must_equal "http://ruby-doc.org/core-2.2.0/Proc.html"
        metadata["resources"][0]["title"].must_equal "Proc objects are blocks of code that have been bound to a set of local variables."
      end

      it "can have params with options hash and keyword args" do
        params = @docs["methods"][0]["params"]
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
