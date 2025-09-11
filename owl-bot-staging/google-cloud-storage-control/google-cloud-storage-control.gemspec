# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/storage/control/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-storage-control"
  gem.version       = Google::Cloud::Storage::Control::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Cloud Storage API allows applications to read and write data through the abstractions of buckets and objects, which are similar to directories and files except that buckets cannot contain other buckets, and directory-level operations (like directory rename) are not supported. Buckets share a single global namespace, and each bucket belongs to a specific project that has an associated owner that pays for the data stored in the bucket. This API is accessed using standard gRPC requests."
  gem.summary       = "The Storage Control API lets you perform metadata-specific, control plane, and long-running operations. The Storage Control API creates one space to perform metadata-specific, control plane, and long-running operations apart from the Storage API. Separating these operations from the Storage API improves API standardization and lets you run faster releases."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-storage-control-v2", ">= 0.0", "< 2.a"
end
