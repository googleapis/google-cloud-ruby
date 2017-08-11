class TestController < ApplicationController
  def index
    render text: "google-cloud-ruby Rails 5 test app"
  end

  def trigger_breakpoint
    local_var = 6 * 7
    local_var
  end

  def test_debugger_info
    debuggee_id = $debugger.agent.debuggee.id
    agent_version = $debugger.agent.debuggee.send :agent_version
    file_path = "app/controllers/test_controller.rb"
    line = method(:trigger_breakpoint).source_location.last + 2

    render json: {
      debuggee_id: debuggee_id,
      agent_version: agent_version,
      breakpoint_file_path: file_path,
      breakpoint_line: line,
      logger_monitored_resource_type: Rails.logger.resource.type
    }
  end

  def test_debugger
    trigger_breakpoint

    render text: "breakpoint triggered"
  end

  def test_error_reporting
    error_toke = params[:token]
    raise "Test error from Rails 5: #{error_toke}"
  end

  def test_logging
    log_token = params[:token]
    logger.info "Test info log entry from Rails 5: #{log_token}"
    logger.error "Test error log entry from Rails 5: #{log_token}"

    render text: log_token.to_s
  end

  def test_logger
    render json: {
      logger_class: Rails.logger.class.to_s,
      writer_class: Rails.logger.writer.class.to_s,
      monitored_resource: {
        type: Rails.logger.resource.type,
        labels: Rails.logger.resource.labels
      }
    }
  end

  def test_trace
    trace_token = params[:token]
    if trace_token
      span_labels = {"token" => trace_token}
      Google::Cloud::Trace.in_span "integration_test_span", labels: span_labels do
        sleep 0.5
      end
    end

    render text: trace_token.to_s
  end
end
