require "google/cloud/errors"
require "google/cloud/storage"
require "minitest/autorun"
require "securerandom"

def create_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    return storage_client.create_bucket bucket_name
  end
end

def delete_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    bucket = storage_client.bucket bucket_name
    return unless bucket

    bucket.files.each(&:delete)
    bucket.delete
  end
end

def create_file_and_upload bucket_name, file_name, text_content
  storage_client = Google::Cloud::Storage.new
  bucket         = storage_client.bucket bucket_name
  return unless bucket

  local_file = Tempfile.new "language-sample-test-file"
  File.write local_file.path, text_content

  bucket.create_file local_file.path, file_name
ensure
  local_file.close
  local_file.unlink
end

def retry_resource_exhaustion
  5.times do
    begin
      yield
      return
    rescue Google::Cloud::ResourceExhaustedError => e
      puts "\n#{e} Gonna try again"
      sleep rand(1..3)
    rescue StandardError => e
      puts "\n#{e}"
      return
    end
  end
  raise Google::Cloud::ResourceExhaustedError("Maybe take a break from creating and deleting buckets for a bit")
end
