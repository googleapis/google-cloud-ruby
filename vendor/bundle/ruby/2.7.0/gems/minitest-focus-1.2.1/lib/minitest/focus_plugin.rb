# frozen_string_literal: true

module Minitest
  def self.plugin_focus_options(_opts, options)
    return unless Minitest::Test.respond_to? :filtered_names
    return if Minitest::Test.filtered_names.empty?

    index = ARGV.index { |arg| arg =~ /^-n/ || arg =~ /^--name/ }
    if index
      warn 'Ignoring -n / --name, using `focus` filters instead'
      ARGV.delete_at index
    end

    options[:filter] = "/^(#{Regexp.union(Minitest::Test.filtered_names).source})$/"
  end
end
