class TestController < ApplicationController
  def index
    @outputs = ["google-cloud-ruby Rails 5 test app"]
    render "test/test"
  end

  def test_error_reporting
    error_toke = params[:token]
    raise "Test error from Rails 5: #{error_toke}"
  end

  def test_logging
    log_token = params[:token]
    logger.info "Test info log entry from Rails 5: #{log_token}"
    logger.error "Test error log entry from Rails 5: #{log_token}"

    @outputs = [log_token.to_s]
    render "test/test"
  end
end
