require "storage_helper"

puts "KOKORO_GFILE_DIR: #{ENV['KOKORO_GFILE_DIR']}"
# ENV["TEST_UNIVERSE_DOMAIN_CREDENTIAL"]=File.read(File.realpath(${KOKORO_GFILE_DIR}/secret_manager/client-library-test-universe-storage-location))