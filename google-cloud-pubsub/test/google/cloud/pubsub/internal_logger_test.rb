require "helper"
require "google/cloud/pubsub/internal_logger"

describe Google::Cloud::PubSub::InternalLogger do
  let(:output) { StringIO.new }
  let(:logger) { Logger.new output }

  it "logs when a logger with pubsub progname is passed" do
    logger.progname = "pubsub"
    logging = Google::Cloud::PubSub::InternalLogger.new logger
    
    logging.log :info, "test-tag" do
      "test message"
    end

    _(output.string).must_include "pubsub:test-tag"
    _(output.string).must_include "test message"
  end

  it "does not log when a logger without pubsub progname is passed" do
    logger.progname = "other"
    logging = Google::Cloud::PubSub::InternalLogger.new logger
    
    logging.log :info, "test-tag" do
      "test message"
    end

    _(output.string).must_be_empty
  end

  it "does not log when no logger is passed" do
    logging = Google::Cloud::PubSub::InternalLogger.new nil
    
    logging.log :info, "test-tag" do
      "test message"
    end

    # Verifies it doesn't raise an error since no capture is possible (no logger).
  end
  
  it "does not log when default logger (nil progname) is passed" do
    # logger.progname is nil by default
    logging = Google::Cloud::PubSub::InternalLogger.new logger
    
    logging.log :info, "test-tag" do
      "test message"
    end

    _(output.string).must_be_empty
  end
end
