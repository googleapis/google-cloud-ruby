# Optimistic Concurrency Control (OCC) Loop for IAM

## Introduction to OCC

Optimistic Concurrency Control (OCC) is a strategy used to manage shared resources and prevent "lost updates" or race conditions when multiple users or processes attempt to modify the same resource simultaneously.

In the context of Google Cloud IAM, the resource is the IAM Policy applied to a resource (like a Project, Bucket, or Service). An IAM Policy object contains a version number and an **etag** (entity tag) field.

OCC introduces a unique fingerprint (etag) which changes every time an entity is modified. The IAM service checks this tag on every write:

1. When you **read** the policy, the server returns an etag.
2. When you **write** the modified policy, you must include that original etag.
3. If the server finds the etag provided does not match the current stored etag, the write fails with an `ABORTED` or `FAILED_PRECONDITION` error.

This failure forces the client to retry the entire process—re-read, re-apply changes, and re-write.

## Implementing the OCC Loop

The core of the implementation is a loop that handles the retry logic. We use Ruby's `begin ... rescue` block to catch specific concurrency errors.

### Steps of the Loop

| Step | Action | Ruby Implementation |
| ----- | ----- | ----- |
| **1\. Read** | Fetch the current IAM Policy. | `policy = client.get_iam_policy resource: name` |
| **2\. Modify** | Apply changes to the local policy object. | `policy.bindings << new_binding` |
| **3\. Write** | Attempt to set the modified policy. | `client.set_iam_policy resource: name, policy: policy` |
| **4\. Retry** | Catch errors and loop. | `rescue Google::Cloud::AbortedError` |

## Example

The following example demonstrates how to implement the OCC loop using the `google-cloud-resource_manager-v3` gem.

```ruby
require "google/cloud/resource_manager/v3"

# Executes an Optimistic Concurrency Control (OCC) loop to safely update an IAM policy.
#
# @param project_id [String] The Google Cloud Project ID (e.g., 'my-project-123').
# @param role [String] The IAM role to grant (e.g., 'roles/storage.objectAdmin').
# @param member [String] The member to add (e.g., 'user:user@example.com').
# @param max_retries [Integer] Maximum number of retries.
def update_iam_policy_with_occ(project_id, role, member, max_retries = 5)
  # 1. Setup Client
  client = Google::Cloud::ResourceManager::V3::Projects::Client.new
  project_name = "projects/#{project_id}"

  retries = 0

  # --- START OCC LOOP ---
  begin
    # READ: Get current policy (includes etag)
    puts "Attempt #{retries + 1}: Reading policy for #{project_name}..."
    policy = client.get_iam_policy resource: project_name

    # MODIFY: Apply changes locally
    # Find existing binding for the role, or create a new one
    binding = policy.bindings.find { |b| b.role == role }

    if binding
      # If the member isn't already there, add them
      unless binding.members.include?(member)
        binding.members << member
      end
    else
      # Create new binding
      new_binding = Google::Iam::V1::Binding.new(
        role: role,
        members: [member]
      )
      policy.bindings << new_binding
    end

    # WRITE: Attempt to update
    # The policy object contains the 'etag' from the READ step.
    puts "Attempt #{retries + 1}: Writing modified policy..."
    client.set_iam_policy resource: project_name, policy: policy

    puts "Successfully updated IAM policy."
    return policy

  rescue Google::Cloud::AbortedError, Google::Cloud::FailedPreconditionError => e
    # RETRY LOGIC
    retries += 1
    if retries < max_retries
      puts "Concurrency conflict (etag mismatch). Retrying... (#{retries}/#{max_retries})"
      sleep(0.1 * retries) # Exponential backoff
      retry # Restarts the `begin` block
    else
      puts "Failed to update policy after #{max_retries} attempts."
      raise e
    end
  end
  # --- END OCC LOOP ---
end

# Usage Example:
# update_iam_policy_with_occ("my-project-id", "roles/viewer", "user:test@example.com")
```

