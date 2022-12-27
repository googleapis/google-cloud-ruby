require "google/cloud/pubsub"

pubsub = Google::Cloud::PubSub.new
topic = pubsub.topic "test"
data = "data" * 2000
res = topic.publish data

# with compression enabled
# Compressed[gzip] 8045 bytes vs. 96 bytes (98.81% savings)
# bundle exec ruby test.rb  0.97s user 0.44s system 52% cpu 2.690 total
# bundle exec ruby test.rb  0.98s user 0.44s system 57% cpu 2.471 total
# bundle exec ruby test.rb  0.98s user 0.44s system 58% cpu 2.441 total

# without compression
# bundle exec ruby test.rb  0.97s user 0.44s system 57% cpu 2.458 total
# bundle exec ruby test.rb  0.98s user 0.45s system 58% cpu 2.430 total
# bundle exec ruby test.rb  0.98s user 0.45s system 58% cpu 2.457 total
