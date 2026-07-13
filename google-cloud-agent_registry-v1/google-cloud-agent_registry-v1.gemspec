# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/agent_registry/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-agent_registry-v1"
  gem.version       = Google::Cloud::AgentRegistry::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Agent Registry provides the core infrastructure for your environment, bringing together autonomous agents with the consistent data contexts and tools that MCP servers offer. By consolidating these services, Agent Registry resolves common challenges in complex AI deployments, such as fragmented tool access, isolated data, and redundant services. Note that google-cloud-agent_registry-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-agent_registry instead. See the readme for more details."
  gem.summary       = "Agent Registry is a centralized, unified catalog that lets you store, discover, and govern Model Context Protocol (MCP) servers, tools, and AI agents within Google Cloud."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "gapic-common", "~> 1.3"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", "~> 1.0"
end
