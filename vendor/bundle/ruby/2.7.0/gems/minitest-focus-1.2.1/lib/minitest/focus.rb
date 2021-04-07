begin
  require "minitest/test"
  require "minitest/focus5.rb"
rescue LoadError
  require "minitest/unit"
  require "minitest/focus4.rb"
end
