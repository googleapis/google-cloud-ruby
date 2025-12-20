# Core Concepts

This documentation covers essential patterns and usage for the Google Cloud Ruby Client Library, focusing on performance (gRPC), data handling (Protobuf, Update Masks), and flow control (Pagination, LROs, Streaming).

## 1. Pagination

Most list methods in the Google Cloud Ruby library return a `Gapic::PagedEnumerable`. This allows you to iterate over results without manually managing page tokens.

The easiest way to handle pagination is to simply `.each` over the response. The library automatically fetches new pages in the background as you iterate.

```ruby
require "google/cloud/secret_manager"

# Initialize the client
client = Google::Cloud::SecretManager.secret_manager_service

# Call the API using keyword arguments
# Returns a Gapic::PagedEnumerable
response = client.list_secrets parent: "projects/my-project"

# Automatically fetches subsequent pages of secrets
response.each do |secret|
  puts "Secret: #{secret.name}"
end
```

### Manual Pagination (Using Page Tokens)

If you need to control pagination manually (e.g., for a web API), you can access the `next_page_token` and the page object.

```ruby
# Call with page_size
response = client.list_secrets parent: "projects/my-project", page_size: 10

# Process current page items
response.response.secrets.each do |secret|
  # Process logic
end

# Check for next page
if response.next_page?
  next_token = response.next_page_token
  # Pass this token to the next call:
  # client.list_secrets(..., page_token: next_token)
end
```

## 2. Long Running Operations (LROs)

Some operations return a Long Running Operation (LRO). The Ruby library provides a wrapper (often `Gapic::Operation`) to manage these.

### Polling for Completion

The standard pattern is to call `wait_until_done!`.

```ruby
require "google/cloud/compute/v1"

# Your Google Cloud project ID
project = "your-project-id"
# The zone in which to create the instance
zone = "your-zone" # e.g., "us-central1-a"

instances_client = Google::Cloud::Compute::V1::Instances::Rest::Client.new

# Prepare the request arguments
instance_resource = {
  name: "new-instance",
  machine_type: "zones/us-central1-a/machineTypes/n1-standard-1",
  disks: [
    {
      auto_delete: true,
      boot: true,
      initialize_params: {
        source_image: "projects/debian-cloud/global/images/debian-11-bullseye-v20230306"
      }
    }
  ],
  network_interfaces: [
    {
      network: "global/networks/default",
      access_configs: [{ name: "External NAT", type: "ONE_TO_ONE_NAT" }]
    }
  ]
}

# Call the method
operation = instances_client.insert project: project, zone: zone, instance_resource: instance_resource

# Wait for the operation to complete
# This blocks the script, polling periodically
operation.wait_until_done!

if operation.error?
  puts "Error: #{operation.error.message}"
else
  # Get the result resource
  result = operation.response
  puts "Instance created: #{result.name}"
end
```

### Async / Non-Blocking Check

If you don't want to block the script, you can store the Operation Name.

```ruby
# 1. Start operation
operation = client.long_running_method(...)
op_name = operation.name

# ... later, or in a different worker process ...

# 2. Retrieve operation status
# Note: You usually use a specific Operations Client or the main client's operations helper
# For specific services, it might look like:
checked_op = client.get_operation name: op_name

if checked_op.done?
  # Handle success
end
```

## 3. Update Masks

When updating resources (PATCH requests), you use a `Google::Protobuf::FieldMask`. Ruby clients often provide helpers, or you can construct the mask explicitly.

### Constructing a FieldMask

```ruby
require "google/cloud/secret_manager"

client = Google::Cloud::SecretManager.secret_manager_service

# 1. Prepare the resource with NEW values
# In Ruby, we often use a Hash or the Protobuf object directly
secret = {
  name: "projects/my-project/secrets/my-secret",
  labels: { "env" => "production" } # We only want to update this field
}

# 2. Create the FieldMask
# 'paths' MUST match the protobuf field names (snake_case)
update_mask = { paths: ["labels"] }

# 3. Call the API
# Ruby arguments match the proto definition
client.update_secret secret: secret, update_mask: update_mask
```

## 4. Protobuf and gRPC

The Google Cloud Ruby library supports two transports: REST (HTTP/1.1) and gRPC.

* **Protobuf (Protocol Buffers):** The mechanism for serializing structured data. Ruby uses the `google-protobuf` gem.
* **gRPC:** The high-performance RPC framework. Ruby uses the `grpc` gem.

### Installation & Setup

Unlike PHP (which requires PECL), Ruby handles these extensions via Gems. If you are using `google-cloud-*` gems, these dependencies are usually installed automatically.

**Gemfile:**

```ruby
gem "google-cloud-pubsub"
# The following are usually pulled in automatically, but can be explicit:
# gem "grpc"
# gem "google-protobuf"
```

**Terminal:**

```
bundle install
```

### Usage in Client

The client library uses gRPC by default if the gem is available. You can force a specific transport using the `transport` keyword argument (usually handled at the GAPIC layer).

```ruby
require "google/cloud/pubsub"

# Force REST transport (if supported by the specific client)
# Note: Most modern Ruby clients default to gRPC automatically.
publisher = Google::Cloud::Pubsub::V1::Publisher::Client.new do |config|
  config.transport = :grpc # or :rest
end
```

## 5. gRPC Streaming

gRPC Streaming allows continuous data flow.

| Type | Description | Common Ruby Use Case |
| ----- | ----- | ----- |
| **Server-Side** | Client sends one request; Server streams messages. | Reading BigQuery rows, watching logs. |
| **Client-Side** | Client streams messages; Server waits for close. | Asynchronous speech recognition, bulk uploads. |
| **Bidirectional** | Both stream messages independently. | Real-time Speech-to-Text. |

### Server-Side Streaming Example

This behaves like a standard Ruby Enumerable.

```ruby
require "google/cloud/bigquery/storage/v1"

read_client = Google::Cloud::Bigquery::Storage::V1::BigQueryRead::Client.new

# Prepare request
read_stream_name = "projects/my-proj/locations/us/sessions/id/streams/id"

# read_rows returns an Enumerable
stream = read_client.read_rows read_stream: read_stream_name

# Iterate over the stream
stream.each do |response|
  # response is a ReadRowsResponse object
  row_data = response.avro_rows.serialized_binary_rows
  puts "Row size: #{row_data.bytesize} bytes"
end
```

### gRPC Bidirectional Streaming

**Crucial Difference:** unlike PHP's imperative `write()` / `read()` loop, Ruby utilizes **Enumerators**. You pass an *Input Enumerator* (containing your requests) to the method, and the method returns an *Output Enumerator* (containing the server responses).

#### Concept:

```ruby
# 1. Create an Enumerator that yields requests
input_stream = Enumerator.new do |yielder|
  yielder << request_object_1
  yielder << request_object_2
end

# 2. Pass the input stream to the client
responses = client.bidi_stream_method(input_stream)

# 3. Iterate over responses
responses.each do |response|
  puts response
end
```

#### Real World Example: Speech-to-Text

```ruby
require "google/cloud/speech/v2"

client = Google::Cloud::Speech::V2::Speech::Client.new

# Define the Input Stream (Requests)
# In a real app, this might pull from a queue or microphone buffer
request_stream = Enumerator.new do |yielder|

  # 1. First Yield: Configuration
  recognition_config = {
    explicit_decoding_config: {
      encoding: :LINEAR16,
      sample_rate_hertz: 16000,
      audio_channel_count: 1
    }
  }

  streaming_config = { config: recognition_config }

  yielder << { recognizer: "projects/.../recognizers/...", streaming_config: streaming_config }

  # 2. Subsequent Yields: Audio Data
  # Simulating reading chunks
  File.open("audio.raw", "rb") do |file|
    while chunk = file.read(4096)
      yielder << { audio: chunk }
    end
  end
end

# Call the API
# We pass the Enumerator into the method
responses = client.streaming_recognize request_stream

# Iterate over responses as they arrive
responses.each do |response|
  response.results.each do |result|
    puts "Transcript: #{result.alternatives[0].transcript}"
  end
end
```

