# Copyright 2014 Google LLC
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

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "retriable"
require "google/cloud/storage"
require "google/cloud/pubsub"

# Generate JUnit format test reports
if ENV["GCLOUD_TEST_GENERATE_XML_REPORT"]
  require "minitest/reporters"
  Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Reporters::JUnitReporter.new]
end

# Create shared storage object so we don't create new for each test
scopes = ["https://www.googleapis.com/auth/devstorage.full_control", "https://www.googleapis.com/auth/iam"]
$storage = Google::Cloud.new.storage retries: 10, scope: scopes

# Create second storage object for tests requiring one, such as requester pays and user project.
if (proj = ENV["GCLOUD_TEST_STORAGE_REQUESTER_PAYS_PROJECT"]) &&
  (keyfile = ENV["GCLOUD_TEST_STORAGE_REQUESTER_PAYS_KEYFILE"] ||
    (ENV["GCLOUD_TEST_STORAGE_REQUESTER_PAYS_KEYFILE_JSON"] &&
      JSON.parse(ENV["GCLOUD_TEST_STORAGE_REQUESTER_PAYS_KEYFILE_JSON"])))
  $storage_2 = Google::Cloud.storage proj, keyfile, retries: 10
end

module Acceptance
  ##
  # Test class for running against a Storage instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :storage to describe:
  #
  #   describe "My Storage Test", :storage do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class StorageTest < Minitest::Test
    attr_accessor :storage
    attr_accessor :storage_2
    attr_accessor :prefix

    ##
    # Setup project based on available ENV variables
    def setup
      @storage = $storage
      @prefix = $prefix
      @storage_2 = $storage_2

      refute_nil @storage, "You do not have an active storage to run the tests."
      refute_nil @prefix, "You do not have a prefix to name the pubsub topics with."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :storage is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :storage
    end

    def try_with_backoff msg = nil, limit: 10
      count = 0
      loop do
        begin
          return yield
        rescue => e
          raise e if count >= limit
          count += 1
          puts "Retry (#{count}): #{msg}"
          sleep count
        end
      end
    end

    def self.run_one_method klass, method_name, reporter
      result = nil
      reporter.prerecord klass, method_name
      (1..3).each do |try|
        result = Minitest.run_one_method(klass, method_name)
        break if (result.passed? || result.skipped?)
        puts "Retrying #{klass}##{method_name} (#{try})"
      end
      reporter.record result
    end
  end
end

def safe_gcs_execute retries: 5
  max_retries = 10
  Retriable.retriable(
    on: Google::Cloud::ResourceExhaustedError,
    base_interval: 1,
    multiplier: 2,
    tries: [retries, max_retries].min
  ) do
    return yield
  end
  raise
end

# Create buckets to be shared with all the tests
require "time"
require "securerandom"
t = Time.now.utc.iso8601.gsub ":", "-"
$bucket_names = 3.times.map { "gcloud-ruby-acceptance-#{t}-#{SecureRandom.hex(4)}".downcase }
$prefix = "gcloud_ruby_acceptance_#{t}_#{SecureRandom.hex(4)}".downcase.gsub "-", "_"
# bucket names for second project
$bucket_names_2 = 3.times.map { "gcloud-ruby-acceptance-2-#{t}-#{SecureRandom.hex(4)}".downcase }
$bucket_name_public = "gcloud-ruby-acceptance-public-read".freeze

def bucket_public
  begin
    b = storage.bucket $bucket_name_public
    return b if b
    create_bucket_public $bucket_name_public
  rescue Google::Cloud::PermissionDeniedError
    create_bucket_public $bucket_name_public
  end
end

def create_bucket_public name
  b = storage.create_bucket name
  b.acl.public!
  b.default_acl.public!
  b.create_file StringIO.new("hello world"), bucket_public_file_text
  b.create_file gzipped_string_io, bucket_public_file_gzip, content_type: "text/plain", content_encoding: "gzip"
  b.create_file StringIO.new("Normalization Form C"), bucket_public_file_normalization_form_c
  b.create_file StringIO.new("Normalization Form D"), bucket_public_file_normalization_form_d
  b
end

# The content of the file is plaintext "hello world"
def bucket_public_file_text
  "hello-world.txt"
end

# The content of the file is gzipped "hello world"
def bucket_public_file_gzip
  "hello-world-gzip.txt"
end

# The content of the file is gzipped "Normalization Form C"
def bucket_public_file_normalization_form_c
  "Caf\u00e9"
end

# The content of the file is gzipped "Normalization Form D"
def bucket_public_file_normalization_form_d
  "Cafe\u0301"
end

def gzipped_string_io data = "hello world"
  gz = StringIO.new ""
  z = Zlib::GzipWriter.new gz
  z.write data
  z.close # write the gzip footer
  StringIO.new gz.string
end

def clean_up_storage_buckets proj = $storage, names = $bucket_names, user_project: nil
  puts "Cleaning up storage buckets after tests for #{proj.project}."
  names.each do |bucket_name|
    bucket = proj.bucket bucket_name, user_project: user_project
    clean_up_storage_bucket bucket if bucket
  end
rescue => e
  puts "Error while cleaning up storage buckets after tests.\n\n#{e}"
  raise e
end

def clean_up_storage_bucket bucket
  bucket.files(versions: true).all do |file|
    file.delete generation: true
  end
  # Add one second delay between bucket deletes to avoid rate limiting errors
  sleep 1
  safe_gcs_execute { bucket.delete }
rescue => e
  puts "Error while cleaning up bucket #{bucket.name}\n\n#{e}"
end

Minitest.after_run do
  clean_up_storage_buckets
  if $storage_2
    clean_up_storage_buckets $storage_2, $bucket_names_2, user_project: true
  else
    puts "The requester pays tests were not run. These tests require a second " \
         "project which is not configured. To enable, ensure that the following " \
         "are present in the environment: \n" \
         "GCLOUD_TEST_STORAGE_REQUESTER_PAYS_PROJECT and \n" \
         "GCLOUD_TEST_STORAGE_REQUESTER_PAYS_KEYFILE or GCLOUD_TEST_STORAGE_REQUESTER_PAYS_KEYFILE_JSON"
  end

  # Delete things that are more than a day old
  time_threshold = Time.now.to_i - 86400

  $storage.buckets(prefix: "object-lock-bucket-", max: 200).each do |bucket|
    if bucket.name =~ /object-lock-bucket-(\d+)/
      if Regexp.last_match[1].to_i < time_threshold
        puts "Cleaning up old test bucket: #{bucket.name} ..."
        clean_up_storage_bucket bucket
      end
    end
  end

  [
    "gcloud-ruby-acceptance-",
    "single_use_gcloud-ruby-acceptance-",
    "ruby-storage-samples-test-",
    "ruby-transcoder-samples-test-"
  ].each do |prefix|
    $storage.buckets(prefix: prefix, max: 100).each do |bucket|
      if bucket.name =~ /#{prefix}(\d+-\d+-\d+)t(\d+)-(\d+)-(\d+)z/
        m = Regexp.last_match
        bucket_time = DateTime.parse("#{m[1]}t#{m[2]}:#{m[3]}:#{m[4]}z").to_time.to_i
        if bucket_time < time_threshold
          puts "Cleaning up old test bucket: #{bucket.name} ..."
          clean_up_storage_bucket bucket
        end
      end
    end
  end
end
