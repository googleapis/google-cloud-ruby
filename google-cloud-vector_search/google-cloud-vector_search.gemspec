# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/vector_search/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-vector_search"
  gem.version       = Google::Cloud::VectorSearch::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Vector Search API provides a fully-managed, highly performant, and scalable vector database designed to power next-generation search, recommendation, and generative AI applications. It allows you to store, index, and query your data and its corresponding vector embeddings through a simple, intuitive interface. With Vector Search, you can define custom schemas for your data, insert objects with associated metadata, automatically generate embeddings from your data, and perform fast approximate nearest neighbor (ANN) searches to find semantically similar items at scale."
  gem.summary       = "The Vector Search API provides a fully-managed, highly performant, and scalable vector database designed to power next-generation search, recommendation, and generative AI applications. It allows you to store, index, and query your data and its corresponding vector embeddings through a simple, intuitive interface. With Vector Search, you can define custom schemas for your data, insert objects with associated metadata, automatically generate embeddings from your data, and perform fast approximate nearest neighbor (ANN) searches to find semantically similar items at scale."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-vector_search-v1", ">= 0.0", "< 2.a"
end
