class TestController < ApplicationController
  def index
    render text: "google-cloud-ruby Rails 4 test app"
  end

  def test_error_reporting
    error_toke = params[:token]
    raise "Test error from Rails 4: #{error_toke}"
  end

  def test_logging
    log_token = params[:token]
    logger.info "Test info log entry from Rails 4: #{log_token}"
    logger.error "Test error log entry from Rails 4: #{log_token}"

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
end
