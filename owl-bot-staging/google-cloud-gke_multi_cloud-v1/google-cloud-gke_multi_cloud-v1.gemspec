# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_multi_cloud/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_multi_cloud-v1"
  gem.version       = Google::Cloud::GkeMultiCloud::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Anthos Multi-Cloud provides a way to manage Kubernetes clusters that run on AWS and Azure infrastructure using the Anthos Multi-Cloud API. Combined with Connect, you can manage Kubernetes clusters on Google Cloud, AWS, and Azure from the Google Cloud Console. Note that google-cloud-gke_multi_cloud-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-gke_multi_cloud instead. See the readme for more details."
  gem.summary       = "Anthos Multi-Cloud provides a way to manage Kubernetes clusters that run on AWS and Azure infrastructure using the Anthos Multi-Cloud API. Combined with Connect, you can manage Kubernetes clusters on Google Cloud, AWS, and Azure from the Google Cloud Console. When you create a cluster with Anthos Multi-Cloud, Google creates the resources needed and brings up a cluster on your behalf. You can deploy workloads with the Anthos Multi-Cloud API or the gcloud and kubectl command-line tools."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
