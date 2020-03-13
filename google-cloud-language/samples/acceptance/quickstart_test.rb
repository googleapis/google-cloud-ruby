require_relative "helper"
require_relative "../quickstart.rb"

describe "Language Quickstart" do
  parallelize_me!

  it "detects the sentiment of \"Hello, world!\"" do
    assert_output(/Text: Hello, world!\nScore: \d\.\d+, \d\.\d+/) do
      quickstart
    end
  end
end
