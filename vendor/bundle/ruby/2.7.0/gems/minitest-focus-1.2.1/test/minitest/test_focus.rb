require "minitest/autorun"
require "minitest/focus"

test_cls = defined?(Minitest::Test) ? Minitest::Test : MiniTest::Unit::TestCase

class MyTest1 < test_cls
         def test_fail;            flunk; end
  focus; def test_method;          pass;  end
         def test_method_edgecase; flunk; end
end

describe "MyTest2" do
         it "is ignored"            do flunk end
  focus; it "does something"        do pass  end
         it "bombs"                 do flunk end
  focus; it "has non-word ['chars'" do pass  end # Will raise invalid RegExp unless correctly escaped
end
