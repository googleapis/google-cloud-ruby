class Minitest::Test    # :nodoc:
  class Focus           # :nodoc:
    VERSION = "1.2.1"   # :nodoc:
  end

  @@filtered_names = [] # :nodoc:

  def self.add_to_filter name
    @@filtered_names << "#{self}##{name}"
  end

  def self.filtered_names
    @@filtered_names
  end

  ##
  # Focus on the next test defined. Cumulative. Equivalent to
  # running with command line arg: -n /test_name|.../
  #
  #   class MyTest < MiniTest::Unit::TestCase
  #     ...
  #     focus
  #     def test_pass; ... end # this one will run
  #     ...
  #   end

  def self.focus
    meta = class << self; self; end

    meta.send :define_method, :method_added do |name|
      add_to_filter name

      meta.send :remove_method, :method_added
    end
  end
end
