# frozen_string_literal: true

desc "Run YARD doctests for this gem"

include :exec, e: true

def run
  require "bundler"
  gem_dir = Dir.pwd
  unless File.file?(File.join(gem_dir, "Gemfile")) && File.file?(File.join(gem_dir, "support/doctest_helper.rb"))
    puts "No doctests configured for #{File.basename(gem_dir)}."
    exit 0
  end
  Bundler.with_unbundled_env do
    exec ["bundle", "exec", "yard", "--plugin", "doctest", "doctest"]
  end
end
