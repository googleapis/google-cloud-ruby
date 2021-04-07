# -*- encoding: utf-8 -*-
# stub: minitest-rg 5.1.0.20140416094215 ruby lib

Gem::Specification.new do |s|
  s.name = "minitest-rg"
  s.version = "5.1.0.20140416094215"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Mike Moore"]
  s.date = "2014-04-16"
  s.description = "Adds color to your MiniTest output"
  s.email = ["mike@blowmage.com"]
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "Manifest.txt", "README.rdoc"]
  s.files = [".autotest", ".gemtest", "CHANGELOG.rdoc", "Gemfile", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "lib/minitest/rg.rb", "lib/minitest/rg_plugin.rb", "minitest-rg.gemspec", "test/test_minitest-rg.rb"]
  s.homepage = "http://blowmage.com/minitest-rg"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.rubygems_version = "2.2.2"
  s.summary = "RedGreen for MiniTest"
  s.test_files = ["test/test_minitest-rg.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<minitest>, ["~> 5.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.11"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.0"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.11"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.0"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.11"])
  end
end
