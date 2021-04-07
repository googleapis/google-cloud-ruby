class MiniTest::Unit::TestCase # :nodoc:
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
    opts = MiniTest::Unit.runner.options
    meta = class << self; self; end

    opts[:names] ||= []

    meta.send :define_method, :method_added do |name|
      opts[:names] << name.to_s
      opts[:filter] = "/^(#{Regexp.union(opts[:names]).source})$/"

      meta.send :remove_method, :method_added
    end
  end
end
