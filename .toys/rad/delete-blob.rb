desc "Delete cloud-rad blobs"

include :exec, e: true
include :terminal

required_arg :prefix
flag :yes

def run
  blobs = filter_blobs list_blobs
  puts "Found #{blobs.size} blobs to delete..."
  blobs.each { |blob| delete_blob blob if confirm_blob blob }
end

def list_blobs
  capture(["gsutil", "ls", "gs://docs-staging-v2"]).split("\n")
end

def filter_blobs blobs
  blobs.find_all do |url|
    url.start_with?("gs://docs-staging-v2/ruby-#{prefix}") ||
      url.start_with?("gs://docs-staging-v2/docfx-ruby-#{prefix}")
  end
end

def confirm_blob blob
  return true if yes
  puts "Delete #{blob}?", :bold
  result = ask("[Y]es / [N]o / [A]ll / [Q]uit ").downcase
  case result
  when "q"
    puts "aborted", :bold, :red
    exit 1
  when "a"
    set :yes, true
    true
  when "y"
    true
  when "n"
    false
  else
    puts "Bad response: #{result}"
    confirm_blob blob
  end
end

def delete_blob blob
  payload = <<~PAYLOAD
    full_job_name: "cloud-devrel/client-libraries/doc-pipeline/delete-blob"
    wait_until_started: false
    env_vars {
      key: "BLOB_TO_DELETE"
      value: "#{blob}"
    }
  PAYLOAD
  exec(["stubby", "call", "blade:kokoro-api", "KokoroApi.Build"], in: [:string, payload])
end
