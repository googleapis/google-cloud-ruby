# Client Configuration

The Google Cloud Ruby Client Libraries allow you to configure client behavior via keyword arguments passed to the client constructor (or `configure` blocks).

## 1. Customizing the API Endpoint

You can modify the API endpoint to connect to a specific Google Cloud region or to a private endpoint.

### Connecting to a Regional Endpoint

```ruby
require "google/cloud/pubsub"

# Connect explicitly to the us-east1 region
pubsub = Google::Cloud::Pubsub.new(
  endpoint: "us-east1-pubsub.googleapis.com:443"
)
```

## 2. Authenticating

## See [Authentication](https://docs.cloud.google.com/ruby/docs/reference/help/authentication) for a comprehensive guide.

## 3. Logging

## See [Troubleshooting](https://docs.cloud.google.com/ruby/docs/reference/help/troubleshooting) for a comprehensive guide.

## 4. Configuring a Proxy

The configuration method depends on whether the client uses gRPC (most clients) or REST (e.g., Storage, BigQuery partial).

### Proxy with gRPC

The Ruby gRPC layer respects standard environment variables. You generally do not configure this in the Ruby code itself.

Set the following environment variables in your shell or Docker container:

```
export http_proxy="http://proxy.example.com:3128"
export https_proxy="http://proxy.example.com:3128"
```

**Handling Self-Signed Certificates (gRPC):** If your proxy uses a self-signed certificate, point gRPC to the CA bundle:

```
export GRPC_DEFAULT_SSL_ROOTS_FILE_PATH="/path/to/roots.pem"
```

### Proxy with REST (e.g., Google::Cloud::Storage)

The underlying HTTP libraries in Ruby (often `Faraday` or `httpclient`) also respect the standard `http_proxy` environment variables automatically.

However, if you must configure it in code (specifically for `Google::Cloud::Storage`), you can pass connection options:

```ruby
require "google/cloud/storage"

storage = Google::Cloud::Storage.new(
  connection_options: {
    proxy: "http://user:password@proxy.example.com"
  }
)
```

## 5. Configuring Retries and Timeouts

Ruby uses **Seconds** (Float/Integer) for time values, whereas PHP uses Milliseconds.

### Per-Call Configuration (Recommended)

You can override settings for specific calls using keyword arguments (`retry_policy` and `timeout`).

```ruby
require "google/cloud/secret_manager"

# Instantiate the client
# Note: secret_manager_service gives access to the V1 GAPIC client
client = Google::Cloud::SecretManager.secret_manager_service

# Prepare the request
parent = "projects/my-project"

# Advanced Retry Configuration
# Note: Time values are in SECONDS
retry_policy = {
  initial_delay: 0.5,    # Start with 0.5s wait
  max_delay: 5.0,        # Cap wait at 5s
  multiplier: 2.0,       # Double the wait each time
  retry_codes: [14]      # Retry on specific gRPC error codes (e.g., UNAVAILABLE)
}

# Make the call
request = { parent: parent }
options = Gapic::CallOptions.new(
  retry_policy: retry_policy,
  timeout: 15.0
)
client.list_secrets request, options
```

### Available `retry_policy` Keys

| Key | Type | Description |
| ----- | ----- | ----- |
| `initial_delay` | Float | Wait time before the first retry (in **seconds**). |
| `max_delay` | Float | The maximum wait time between any two retries (in **seconds**). |
| `multiplier` | Float | Multiplier applied to the delay after each failure. |
| `retry_codes` | Array | List of gRPC error codes (integers) that should trigger a retry. |

### Global Client Configuration

You can configure defaults globally when initializing the low-level GAPIC client, though per-call is preferred for specific logic.

```php
require "google/cloud/pubsub"

# Create a client with a custom timeout for all requests
pubsub = Google::Cloud::Pubsub.new(
  timeout: 10 # Default 10 seconds for all operations
)
```

## 6. Other Common Configuration Options

The following options can be passed to the constructor of generated clients (e.g., `Google::Cloud::Pubsub`, `Google::Cloud::Spanner`, `Google::Cloud::Storage`).

| Option Key | Type | Description |
| ----- | ----- | ----- |
| `credentials` | String / Hash | Path to the JSON keyfile or the JSON object itself. |
| `endpoint` | String | The address of the API remote host. Used for Regional Endpoints (e.g., `us-central1-pubsub.googleapis.com:443`). |
| `lib_name` / `lib_version` | String | Used to append identification to the `x-goog-api-client` header for tracing/debugging. |
| `timeout` | Numeric | The default timeout (in **seconds**) for requests. |
| `retries` | Integer | Number of retries for the underlying HTTP/gRPC connection (distinct from logic retries). |
| `project_id` | String | Explicitly sets the project ID, overriding environment variables. |
| `universe_domain` | String | Overrides the default service domain (defaults to `googleapis.com`) for Cloud Universe support. |
