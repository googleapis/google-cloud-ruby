require "rubygems"
require "hoe"

Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :minitest

Hoe.spec "gcloud" do
  developer "Silvano Luciani", "silvano@google.com"
  developer "Mike Moore",      "mike@blowmage.com"

  self.summary     = "API Client library for Google Cloud"
  self.description = "Gcloud is the official library for interacting with Google Cloud."
  self.urls        = ["http://googlecloudplatform.github.io/gcloud-ruby/"]

  self.history_file = "CHANGELOG.md"
  self.readme_file  = "README.md"
  self.testlib      = :minitest

  self.spec_extras[:rdoc_options] = ["--main", "README.md", "--exclude", "lib/gcloud/proto/"]

  license "Apache-2.0"

  dependency "beefcake", "~> 1.0"
  dependency "google-api-client", "~> 0.7"
  dependency "rubocop", "~> 0.27", :dev
end
