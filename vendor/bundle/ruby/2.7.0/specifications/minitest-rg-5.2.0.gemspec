# -*- encoding: utf-8 -*-
# stub: minitest-rg 5.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "minitest-rg".freeze
  s.version = "5.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Moore".freeze]
  s.date = "2015-08-14"
  s.description = "Colored red/green output for Minitest".freeze
  s.email = ["mike@blowmage.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["CHANGELOG.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.homepage = "http://blowmage.com/minitest-rg".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Red/Green for MiniTest".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_development_dependency(%q<hoe>.freeze, ["~> 3.13"])
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.13"])
  end
end
