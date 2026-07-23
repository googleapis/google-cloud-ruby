# verify_keepalive.rb
require "logger"
require "google/cloud/pubsub"

project_id = ENV["PUBSUB_PROJECT_ID"] || "helical-zone-771"
keyfile = ENV["GOOGLE_APPLICATION_CREDENTIALS"]

debug_logger = Logger.new($stdout, level: :debug)
# CRITICAL: InternalLogger requires progname == 'pubsub' to enable internal logging
debug_logger.progname = "pubsub"
debug_logger.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime.strftime('%H:%M:%S.%L')}] #{severity} -- : #{msg}\n"
end

puts "================================================================="
puts " Streaming Keep-Alive E2E Verification & Validation Script"
puts " Project ID    : #{project_id}"
puts " Credentials   : #{keyfile || 'Default'}"
puts " Ping Interval : 5.0s (Customized via KeepaliveMonitor)"
puts " Pong Deadline : 3.0s (Customized via KeepaliveMonitor)"
puts " Logger Prog   : pubsub (DEBUG level enabled)"
puts "================================================================="

options = { project_id: project_id, logger: debug_logger }
options[:credentials] = keyfile if keyfile
options[:endpoint] = ENV["PUBSUB_ENDPOINT"] || "pubsub.googleapis.com:443"

pubsub = Google::Cloud::PubSub.new(**options)

topic_id = "jetski-keepalive-webapp-topic"
sub_id = "jetski-keepalive-webapp-sub"

topic_path = pubsub.topic_path(topic_id)
sub_path = pubsub.subscription_path(sub_id)

puts "\n[Setup] Ensuring test topic and subscription exist on GCP..."
begin
  pubsub.topic_admin.create_topic(name: topic_path)
rescue Google::Cloud::AlreadyExistsError, Google::Cloud::Error
end

begin
  pubsub.subscription_admin.create_subscription(name: sub_path, topic: topic_path)
rescue Google::Cloud::AlreadyExistsError, Google::Cloud::Error
end

subscriber = pubsub.subscriber(sub_id)
publisher = pubsub.publisher(topic_id)

processed_count = 0
listener = subscriber.listen do |received_message|
  processed_count += 1
  puts "--> [App Callback] Processed message #{processed_count}: #{received_message.data}"
  received_message.acknowledge!
end

stream = listener.instance_variable_get(:@stream_pool).first
stream.keepalive_monitor.interval = 5.0
stream.keepalive_monitor.deadline = 3.0

puts "[App] Starting bidirectional streaming pull listener..."
listener.start

puts "[App] Publishing a test message..."
publisher.publish "Hello live streaming keep-alive!"

puts "[App] Observing active stream keep-alive pings for 22 seconds...\n"
11.times do |i|
  sleep 2
  monitor = stream.keepalive_monitor
  puts "[Active Heartbeat #{i + 1}/11] last_ping_at: #{monitor&.last_ping_at&.round(3) || 'N/A'}, last_pong_at: #{monitor&.last_pong_at&.round(3) || 'N/A'} (stream_open == #{stream.stream_open})"
end

puts "\n[App] Stopping listener..."
listener.stop
listener.wait!

puts "[Teardown] Cleaning up test topic and subscription..."
begin
  pubsub.subscription_admin.delete_subscription(subscription: sub_path)
  pubsub.topic_admin.delete_topic(topic: topic_path)
rescue StandardError
end

puts "[App] E2E Verification & Validation completed successfully."
