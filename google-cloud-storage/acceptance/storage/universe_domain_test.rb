require "storage_helper"

location=File.read(File.realpath(File.join(ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-storage-location")))

puts "location: #{location}"