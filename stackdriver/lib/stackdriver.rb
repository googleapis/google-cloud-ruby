# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


gem "google-cloud-debugger"
gem "google-cloud-error_reporting"
gem "google-cloud-logging"
gem "google-cloud-trace"

require "google/cloud/debugger"
require "google/cloud/error_reporting"
require "google/cloud/logging"
require "google/cloud/trace"

if defined? ::Rails::Railtie
  require "google/cloud/debugger/rails"
  require "google/cloud/error_reporting/rails"
  require "google/cloud/logging/rails"
  require "google/cloud/trace/rails"
end

##
# # Stackdriver
#
# The stackdriver gem instruments a Ruby web application for Stackdriver
# diagnostics. When loaded, it integrates with Rails, Sinatra, or other
# Rack-based web frameworks to collect application diagnostic and monitoring
# information for your application.
#
# Specifically, this gem is a convenience package that loads the following gems:
#
# - [google-cloud-debugger](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-debugger)
# - [google-cloud-error_reporting](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-error_reporting)
# - [google-cloud-logging](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-logging)
# - [google-cloud-trace](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-trace)
#
# On top of that, stackdriver gem automatically activates the following
# instrumentation features:
#
# - [google-cloud-debugger instrumentation](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-debugger/latest/file.INSTRUMENTATION)
# - [google-cloud-error_reporting instrumentation](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-error_reporting/latest/file.INSTRUMENTATION)
# - [google-cloud-logging instrumentation](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-logging/latest/file.INSTRUMENTATION)
# - [google-cloud-trace instrumentation](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-trace/latest/file.INSTRUMENTATION)
#
# ## Usage
#
# Instead of requiring multiple Stackdriver client library gems and explicitly
# load each built-in Railtie classes, now users can achieve all these through
# requiring this single **stackdriver** umbrella gem.
# @example
#   require "stackdriver"
module Stackdriver
end
