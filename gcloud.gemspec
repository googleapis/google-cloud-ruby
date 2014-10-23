# -*- encoding: utf-8 -*-
# stub: gcloud 0.0.1.20141103160019 ruby lib

Gem::Specification.new do |s|
  s.name = "gcloud"
  s.version = "0.0.1.20141103160019"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Silvano Luciani", "Mike Moore"]
  s.date = "2014-11-03"
  s.description = "Gcloud is the official library for interacting with Google Cloud."
  s.email = ["silvano@google.com", "mike@blowmage.com"]
  s.extra_rdoc_files = ["CHANGELOG.md", "CONTRIBUTING.md", "Manifest.txt", "README.md"]
  s.files = [".gemtest", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE", "Manifest.txt", "README.md", "Rakefile", "gcloud.gemspec", "lib/gcloud.rb", "lib/gcloud/version.rb", "test/gcloud/test_version.rb"]
  s.homepage = "http://googlecloudplatform.github.io/gcloud-ruby/"
  s.licenses = ["Apache-2.0"]
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.2.2"
  s.summary = "API Client library for Google Cloud"
  s.test_files = ["test/gcloud/test_version.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.4"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.4"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
