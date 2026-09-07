# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_multi_cloud/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_multi_cloud"
  gem.version       = Google::Cloud::GkeMultiCloud::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "GKE Multi-Cloud provides a way to manage Kubernetes clusters that run on AWS and Azure infrastructure using the GKE Multi-Cloud API. Combined with Connect, you can manage Kubernetes clusters on Google Cloud, AWS, and Azure from the Google Cloud Console. When you create a cluster with GKE Multi-Cloud, Google creates the resources needed and brings up a cluster on your behalf. You can deploy workloads with the GKE Multi-Cloud API or the gcloud and kubectl command-line tools."
  gem.summary       = "GKE Multi-Cloud provides a way to manage Kubernetes clusters that run on AWS and Azure infrastructure using the GKE Multi-Cloud API. Combined with Connect, you can manage Kubernetes clusters on Google Cloud, AWS, and Azure from the Google Cloud Console. When you create a cluster with GKE Multi-Cloud, Google creates the resources needed and brings up a cluster on your behalf. You can deploy workloads with the GKE Multi-Cloud API or the gcloud and kubectl command-line tools."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gke_multi_cloud-v1", ">= 0.8", "< 2.a"
end
