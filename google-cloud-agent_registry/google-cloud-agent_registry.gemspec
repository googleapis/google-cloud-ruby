# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/agent_registry/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-agent_registry"
  gem.version       = Google::Cloud::AgentRegistry::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Agent Registry provides the core infrastructure for your environment, bringing together autonomous agents with the consistent data contexts and tools that MCP servers offer. By consolidating these services, Agent Registry resolves common challenges in complex AI deployments, such as fragmented tool access, isolated data, and redundant services."
  gem.summary       = "Agent Registry is a centralized, unified catalog that lets you store, discover, and govern Model Context Protocol (MCP) servers, tools, and AI agents within Google Cloud."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-agent_registry-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
