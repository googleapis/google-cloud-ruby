# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require 'sinatra'
require 'stackdriver'
require 'grpc'

Google::Cloud.configure do |config|
  config.logging.log_name = "google-cloud-ruby_integration_test"
end

$debugger = Google::Cloud::Debugger.new

#######################################
# Setup Middlewares
use Google::Cloud::Debugger::Middleware, debugger: $debugger
use Google::Cloud::ErrorReporting::Middleware
use Google::Cloud::Logging::Middleware
use Google::Cloud::Trace::Middleware


# Set :raise_errors to expose error message in production environment
set :raise_errors, true
set :bind, "0.0.0.0"
set :port, 8080

get '/' do
  "google-cloud-ruby classic sinatra app up and running"
end

get '/_ah/health' do
  "Success"
end

def trigger_breakpoint
  local_var = 6 * 7
  local_var
end

get '/test_debugger_info' do
  debuggee_id = $debugger.agent.debuggee.id
  agent_version = $debugger.agent.debuggee.send :agent_version
  file_path = __FILE__
  line = method(:trigger_breakpoint).source_location.last + 2

  {
    debuggee_id: debuggee_id,
    agent_version: agent_version,
    breakpoint_file_path: file_path,
    breakpoint_line: line,
    logger_monitored_resource_type: logger.resource.type
  }.to_json
end

get '/test_debugger' do
  trigger_breakpoint

  "breakpoint triggered"
end

get '/test_error_reporting' do
  error_toke = params[:token]
  raise StandardError, "Test error from sinatra classic: #{error_toke}"
end

get '/test_logging' do
  log_token = params[:token]
  logger.info "Test log entry from classic sinatra #{log_token}"
  log_token.to_s
end

get '/test_logger' do
  {
    logger_class: logger.class.to_s,
    writer_class: logger.writer.class.to_s,
    monitored_resource: {
      type: logger.resource.type,
      labels: logger.resource.labels
    }
  }.to_json
end

get '/test_trace' do
  trace_token = params[:token]
  if trace_token
    span_labels = {"token" => trace_token}
    Google::Cloud::Trace.in_span "integration_test_span", labels: span_labels do
      sleep 0.5
    end
  end
  trace_token.to_s
end
