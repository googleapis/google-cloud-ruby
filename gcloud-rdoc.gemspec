# -*- encoding: utf-8 -*-
# stub: gcloud-rdoc 1.0.0.20150604065341 ruby lib

Gem::Specification.new do |s|
  s.name = "gcloud-rdoc"
  s.version = "1.0.0.20150604065341"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Silvano Luciani", "Mike Moore"]
  s.date = "2015-06-04"
  s.description = "Gcloud is the official library for interacting with Google Cloud."
  s.email = ["silvano@google.com", "mike@blowmage.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = [".gemtest", ".rubocop.yml", ".travis.yml", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "gcloud-rdoc.gemspec", "lib/gcloud-rdoc.rb", "lib/gcloud/rdoc.rb", "lib/rdoc/discover.rb", "lib/rdoc/generator/gcloud.rb", "lib/rdoc/generator/gcloud/_attributes.html.erb", "lib/rdoc/generator/gcloud/_buttons.html.erb", "lib/rdoc/generator/gcloud/_constants.html.erb", "lib/rdoc/generator/gcloud/_footer.html.erb", "lib/rdoc/generator/gcloud/_header.html.erb", "lib/rdoc/generator/gcloud/_includes.html.erb", "lib/rdoc/generator/gcloud/_meta.html.erb", "lib/rdoc/generator/gcloud/_method.html.erb", "lib/rdoc/generator/gcloud/_methods.html.erb", "lib/rdoc/generator/gcloud/_parent.html.erb", "lib/rdoc/generator/gcloud/_section.html.erb", "lib/rdoc/generator/gcloud/_side.html.erb", "lib/rdoc/generator/gcloud/class.html.erb", "lib/rdoc/generator/gcloud/config/side.yml", "lib/rdoc/generator/gcloud/index.html.erb", "lib/rdoc/generator/gcloud/page.html.erb", "lib/rdoc/generator/gcloud/reference.html.erb", "lib/rdoc/generator/gcloud/stylesheets/gcloud.css", "test/gcloud/test_rdoc.rb"]
  s.homepage = "http://googlecloudplatform.github.io/gcloud-ruby/"
  s.licenses = ["Apache-2.0"]
  s.rdoc_options = ["--main", "README.txt"]
  s.rubygems_version = "2.4.6"
  s.summary = "RDoc template for Google Cloud"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.7"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.7"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
