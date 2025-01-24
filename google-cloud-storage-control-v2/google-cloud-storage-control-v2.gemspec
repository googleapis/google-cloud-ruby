# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/storage/control/v2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-storage-control-v2"
  gem.version       = Google::Cloud::Storage::Control::V2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Cloud Storage API allows applications to read and write data through the abstractions of buckets and objects, which are similar to directories and files except that buckets cannot contain other buckets, and directory-level operations (like directory rename) are not supported. Buckets share a single global namespace, and each bucket belongs to a specific project that has an associated owner that pays for the data stored in the bucket. This API is accessed using standard gRPC requests. Note that google-cloud-storage-control-v2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-storage-control instead. See the readme for more details."
  gem.summary       = "The Storage Control API lets you perform metadata-specific, control plane, and long-running operations. The Storage Control API creates one space to perform metadata-specific, control plane, and long-running operations apart from the Storage API. Separating these operations from the Storage API improves API standardization and lets you run faster releases."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.25.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
