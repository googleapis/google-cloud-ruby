# -*- encoding: utf-8 -*-
# stub: gcloud 0.0.1.20141216152904 ruby lib

Gem::Specification.new do |s|
  s.name = "gcloud"
  s.version = "0.0.1.20141216152904"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Silvano Luciani", "Mike Moore"]
  s.date = "2014-12-16"
  s.description = "Gcloud is the official library for interacting with Google Cloud."
  s.email = ["silvano@google.com", "mike@blowmage.com"]
  s.extra_rdoc_files = ["CHANGELOG.md", "CONTRIBUTING.md", "Manifest.txt", "README.md"]
  s.files = [".gemtest", ".rubocop.yml", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE", "Manifest.txt", "README.md", "Rakefile", "gcloud.gemspec", "lib/gcloud.rb", "lib/gcloud/datastore.rb", "lib/gcloud/datastore/connection.rb", "lib/gcloud/datastore/credentials.rb", "lib/gcloud/datastore/dataset.rb", "lib/gcloud/datastore/entity.rb", "lib/gcloud/datastore/errors.rb", "lib/gcloud/datastore/key.rb", "lib/gcloud/datastore/list.rb", "lib/gcloud/datastore/proto.rb", "lib/gcloud/datastore/query.rb", "lib/gcloud/datastore/transaction.rb", "lib/gcloud/proto/datastore_v1.pb.rb", "lib/gcloud/storage.rb", "lib/gcloud/storage/bucket.rb", "lib/gcloud/storage/connection.rb", "lib/gcloud/storage/credentials.rb", "lib/gcloud/storage/errors.rb", "lib/gcloud/storage/file.rb", "lib/gcloud/storage/project.rb", "lib/gcloud/version.rb", "rakelib/console.rake", "rakelib/manifest.rake", "rakelib/proto.rake", "rakelib/rubocop.rake", "rakelib/test.rake", "test/gcloud/datastore/proto/test_cursor.rb", "test/gcloud/datastore/proto/test_direction.rb", "test/gcloud/datastore/proto/test_operator.rb", "test/gcloud/datastore/proto/test_value.rb", "test/gcloud/datastore/test_connection.rb", "test/gcloud/datastore/test_credentials.rb", "test/gcloud/datastore/test_dataset.rb", "test/gcloud/datastore/test_entity.rb", "test/gcloud/datastore/test_key.rb", "test/gcloud/datastore/test_query.rb", "test/gcloud/datastore/test_transaction.rb", "test/gcloud/storage/test_bucket.rb", "test/gcloud/storage/test_file.rb", "test/gcloud/storage/test_project.rb", "test/gcloud/storage/test_storage.rb", "test/gcloud/test_version.rb", "test/helper.rb"]
  s.homepage = "http://googlecloudplatform.github.io/gcloud-ruby/"
  s.licenses = ["Apache-2.0"]
  s.rdoc_options = ["--main", "README.md", "--exclude", "lib/gcloud/proto/", "--exclude", "Manifest.txt"]
  s.rubygems_version = "2.2.2"
  s.summary = "API Client library for Google Cloud"
  s.test_files = ["test/gcloud/datastore/proto/test_cursor.rb", "test/gcloud/datastore/proto/test_direction.rb", "test/gcloud/datastore/proto/test_operator.rb", "test/gcloud/datastore/proto/test_value.rb", "test/gcloud/datastore/test_connection.rb", "test/gcloud/datastore/test_credentials.rb", "test/gcloud/datastore/test_dataset.rb", "test/gcloud/datastore/test_entity.rb", "test/gcloud/datastore/test_key.rb", "test/gcloud/datastore/test_query.rb", "test/gcloud/datastore/test_transaction.rb", "test/gcloud/storage/test_bucket.rb", "test/gcloud/storage/test_file.rb", "test/gcloud/storage/test_project.rb", "test/gcloud/storage/test_storage.rb", "test/gcloud/test_version.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<beefcake>, ["~> 1.0"])
      s.add_runtime_dependency(%q<google-api-client>, ["~> 0.7"])
      s.add_runtime_dependency(%q<retriable>, ["~> 1.4"])
      s.add_runtime_dependency(%q<mime-types>, ["~> 2.4"])
      s.add_development_dependency(%q<minitest>, ["~> 5.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.27"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<beefcake>, ["~> 1.0"])
      s.add_dependency(%q<google-api-client>, ["~> 0.7"])
      s.add_dependency(%q<retriable>, ["~> 1.4"])
      s.add_dependency(%q<mime-types>, ["~> 2.4"])
      s.add_dependency(%q<minitest>, ["~> 5.4"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<rubocop>, ["~> 0.27"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<beefcake>, ["~> 1.0"])
    s.add_dependency(%q<google-api-client>, ["~> 0.7"])
    s.add_dependency(%q<retriable>, ["~> 1.4"])
    s.add_dependency(%q<mime-types>, ["~> 2.4"])
    s.add_dependency(%q<minitest>, ["~> 5.4"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<rubocop>, ["~> 0.27"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
