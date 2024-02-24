# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/policy_simulator/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-policy_simulator"
  gem.version       = Google::Cloud::PolicySimulator::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Policy Simulator is a collection of endpoints for creating, running, and viewing a [Replay][google.cloud.policysimulator.v1.Replay]. A `Replay` is a type of simulation that lets you see how your members' access to resources might change if you changed your IAM policy. During a `Replay`, Policy Simulator re-evaluates, or replays, past access attempts under both the current policy and your proposed policy, and compares those results to determine how your members' access might change under the proposed policy."
  gem.summary       = "Policy Simulator is a collection of endpoints for creating, running, and viewing a [Replay][google.cloud.policysimulator.v1.Replay]. A `Replay` is a type of simulation that lets you see how your members' access to resources might change if you changed your IAM policy. During a `Replay`, Policy Simulator re-evaluates, or replays, past access attempts under both the current policy and your proposed policy, and compares those results to determine how your members' access might change under the proposed policy."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-policy_simulator-v1", ">= 0.3", "< 2.a"
end
