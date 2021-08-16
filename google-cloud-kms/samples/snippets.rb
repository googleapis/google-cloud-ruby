# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Snippets contains all the code samples for Cloud KMS.
# rubocop:disable Metrics/ClassLength
class Snippets
  def create_key_asymmetric_decrypt project_id:, location_id:, key_ring_id:, id:
    # [START kms_create_key_asymmetric_decrypt]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # id          = "my-asymmetric-decrypt-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key ring name.
    key_ring_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Build the key.
    key = {
      purpose:          :ASYMMETRIC_DECRYPT,
      version_template: {
        algorithm: :RSA_DECRYPT_OAEP_2048_SHA256
      },

      # Optional: customize how long key versions should be kept before destroying.
      destroy_scheduled_duration: {
        seconds: 24 * 60 * 60
      }
    }

    # Call the API.
    created_key = client.create_crypto_key parent: key_ring_name, crypto_key_id: id, crypto_key: key
    puts "Created asymmetric decryption key: #{created_key.name}"
    # [END kms_create_key_asymmetric_decrypt]

    created_key
  end

  def create_key_asymmetric_sign project_id:, location_id:, key_ring_id:, id:
    # [START kms_create_key_asymmetric_sign]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # id          = "my-asymmetric-signing-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key ring name.
    key_ring_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Build the key.
    key = {
      purpose:          :ASYMMETRIC_SIGN,
      version_template: {
        algorithm: :RSA_SIGN_PKCS1_2048_SHA256
      },

      # Optional: customize how long key versions should be kept before destroying.
      destroy_scheduled_duration: {
        seconds: 24 * 60 * 60
      }
    }

    # Call the API.
    created_key = client.create_crypto_key parent: key_ring_name, crypto_key_id: id, crypto_key: key
    puts "Created asymmetric signing key: #{created_key.name}"
    # [END kms_create_key_asymmetric_sign]

    created_key
  end

  def create_key_hsm project_id:, location_id:, key_ring_id:, id:
    # [START kms_create_key_hsm]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # id          = "my-hsm-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key ring name.
    key_ring_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Build the key.
    key = {
      purpose:          :ENCRYPT_DECRYPT,
      version_template: {
        algorithm:        :GOOGLE_SYMMETRIC_ENCRYPTION,
        protection_level: :HSM
      },

      # Optional: customize how long key versions should be kept before destroying.
      destroy_scheduled_duration: {
        seconds: 24 * 60 * 60
      }
    }

    # Call the API.
    created_key = client.create_crypto_key parent: key_ring_name, crypto_key_id: id, crypto_key: key
    puts "Created hsm key: #{created_key.name}"
    # [END kms_create_key_hsm]

    created_key
  end

  def create_key_labels project_id:, location_id:, key_ring_id:, id:
    # [START kms_create_key_labels]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # id          = "my-key-with-labels"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key ring name.
    key_ring_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Build the key.
    key = {
      purpose:          :ENCRYPT_DECRYPT,
      version_template: {
        algorithm: :GOOGLE_SYMMETRIC_ENCRYPTION
      },
      labels:           {
        "team"        => "alpha",
        "cost_center" => "cc1234"
      }
    }

    # Call the API.
    created_key = client.create_crypto_key parent: key_ring_name, crypto_key_id: id, crypto_key: key
    puts "Created labeled key: #{created_key.name}"
    # [END kms_create_key_labels]

    created_key
  end

  def create_key_mac project_id:, location_id:, key_ring_id:, id:
    # [START kms_create_key_mac]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # id          = "my-mac-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key ring name.
    key_ring_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Build the key.
    key = {
      purpose:          :MAC,
      version_template: {
        algorithm: :HMAC_SHA256
      }
    }

    # Call the API.
    created_key = client.create_crypto_key parent: key_ring_name, crypto_key_id: id, crypto_key: key
    puts "Created mac key: #{created_key.name}"
    # [END kms_create_key_mac]

    created_key
  end

  def create_key_ring project_id:, location_id:, id:
    # [START kms_create_key_ring]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # id = "my-key-ring"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent location name.
    location_name = client.location_path project: project_id, location: location_id

    # Build the key ring.
    key_ring = {}

    # Call the API.
    created_key_ring = client.create_key_ring parent: location_name, key_ring_id: id, key_ring: key_ring
    puts "Created key ring: #{created_key_ring.name}"
    # [END kms_create_key_ring]

    created_key_ring
  end

  def create_key_rotation_schedule project_id:, location_id:, key_ring_id:, id:
    # [START kms_create_key_rotation_schedule]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # id          = "my-key-with-rotation"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key ring name.
    key_ring_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Build the key.
    key = {
      purpose:            :ENCRYPT_DECRYPT,
      version_template:   {
        algorithm: :GOOGLE_SYMMETRIC_ENCRYPTION
      },

      # Rotate the key every 30 days.
      rotation_period:    {
        seconds: 60 * 60 * 24 * 30
      },

      # Start the first rotation in 24 hours.
      next_rotation_time: {
        seconds: (Time.now + 60 * 60 * 24).to_i
      }
    }

    # Call the API.
    created_key = client.create_crypto_key parent: key_ring_name, crypto_key_id: id, crypto_key: key
    puts "Created rotating key: #{created_key.name}"
    # [END kms_create_key_rotation_schedule]

    created_key
  end

  def create_key_symmetric_encrypt_decrypt project_id:, location_id:, key_ring_id:, id:
    # [START kms_create_key_symmetric_encrypt_decrypt]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # id          = "my-symmetric-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key ring name.
    key_ring_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Build the key.
    key = {
      purpose:          :ENCRYPT_DECRYPT,
      version_template: {
        algorithm: :GOOGLE_SYMMETRIC_ENCRYPTION
      }
    }

    # Call the API.
    created_key = client.create_crypto_key parent: key_ring_name, crypto_key_id: id, crypto_key: key
    puts "Created symmetric key: #{created_key.name}"
    # [END kms_create_key_symmetric_encrypt_decrypt]

    created_key
  end

  def create_key_version project_id:, location_id:, key_ring_id:, key_id:
    # [START kms_create_key_version]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Build the version.
    version = {}

    # Call the API.
    created_version = client.create_crypto_key_version parent: key_name, crypto_key_version: version
    puts "Created key version: #{created_version.name}"
    # [END kms_create_key_version]

    created_version
  end

  def decrypt_asymmetric project_id:, location_id:, key_ring_id:, key_id:, version_id:, ciphertext:
    # [START kms_decrypt_asymmetric]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"
    # ciphertext  = "..."

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Call the API.
    response = client.asymmetric_decrypt key_version_name, ciphertext
    puts "Plaintext: #{response.plaintext}"
    # [END kms_decrypt_asymmetric]

    response
  end

  def decrypt_symmetric project_id:, location_id:, key_ring_id:, key_id:, ciphertext:
    # [START kms_decrypt_symmetric]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # ciphertext  = "..."

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Call the API.
    response = client.decrypt name: key_name, ciphertext: ciphertext
    puts "Plaintext: #{response.plaintext}"
    # [END kms_decrypt_symmetric]

    response
  end

  def destroy_key_version project_id:, location_id:, key_ring_id:, key_id:, version_id:
    # [START kms_destroy_key_version]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Call the API.
    destroyed_version = client.destroy_crypto_key_version name: key_version_name
    puts "Destroyed key version: #{destroyed_version.name}"
    # [END kms_destroy_key_version]

    destroyed_version
  end

  def disable_key_version project_id:, location_id:, key_ring_id:, key_id:, version_id:
    # [START kms_disable_key_version]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Create the updated version.
    version = {
      name:  key_version_name,
      state: :DISABLED
    }

    # Create the field mask.
    update_mask = { paths: ["state"] }

    # Call the API.
    disabled_version = client.update_crypto_key_version crypto_key_version: version, update_mask: update_mask
    puts "Disabled key version: #{disabled_version.name}"
    # [END kms_disable_key_version]

    disabled_version
  end

  def enable_key_version project_id:, location_id:, key_ring_id:, key_id:, version_id:
    # [START kms_enable_key_version]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Create the updated version.
    version = {
      name:  key_version_name,
      state: :ENABLED
    }

    # Create the field mask.
    update_mask = { paths: ["state"] }

    # Call the API.
    enabled_version = client.update_crypto_key_version crypto_key_version: version, update_mask: update_mask
    puts "Enabled key version: #{enabled_version.name}"
    # [END kms_enable_key_version]

    enabled_version
  end

  def encrypt_asymmetric project_id:, location_id:, key_ring_id:, key_id:, version_id:, plaintext:
    # [START kms_encrypt_asymmetric]
    # Ruby has limited support for asymmetric encryption operations. Specifically,
    # public_encrypt() does not allow customizing the MGF hash algorithm. Thus, it
    # is not currently possible to use Ruby core for asymmetric encryption
    # operations on RSA keys from Cloud KMS.
    #
    # Third party libraries may provide the required functionality. Google does
    # not endorse these external libraries.
    # [END kms_encrypt_asymmetric]

    _ = project_id, location_id, key_ring_id, key_id, version_id, plaintext
  end

  def encrypt_symmetric project_id:, location_id:, key_ring_id:, key_id:, plaintext:
    # [START kms_encrypt_symmetric]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # plaintext  = "..."

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Call the API.
    response = client.encrypt name: key_name, plaintext: plaintext
    puts "Ciphertext: #{Base64.strict_encode64 response.ciphertext}"
    # [END kms_encrypt_symmetric]

    response
  end

  def generate_random_bytes project_id:, location_id:, num_bytes:
    # [START kms_generate_random_bytes]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # num_bytes = 256

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent location name.
    location_name = client.location_path project:    project_id,
                                         location:   location_id

    # Call the API.
    response = client.generate_random_bytes location: location_name, length_bytes: num_bytes, protection_level: :HSM

    # The data comes back as raw bytes, which may include non-printable
    # characters. This base64-encodes the result so it can be printed below.
    encoded_data = Base64.strict_encode64 response.data

    puts "Random bytes: #{encoded_data}"
    # [END kms_generate_random_bytes]

    response
  end

  def get_key_labels project_id:, location_id:, key_ring_id:, key_id:
    # [START kms_get_key_labels]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Call the API.
    key = client.get_crypto_key name: key_name

    # Example of iterating over labels.
    key.labels.each do |k, v|
      puts "#{k} = #{v}"
    end
    # [END kms_get_key_labels]

    key
  end

  def get_key_version_attestation project_id:, location_id:, key_ring_id:, key_id:, version_id:
    # [START kms_get_key_version_attestation]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Call the API.
    version = client.get_crypto_key_version name: key_version_name

    # Only HSM keys have an attestation. For other key types, the attestion will
    # be nil.
    attestation = version.attestation
    unless attestation
      raise "no attestation"
    end

    puts "Attestation: #{Base64.strict_encode64 attestation.content}"
    # [END kms_get_key_version_attestation]

    attestation
  end

  def get_public_key project_id:, location_id:, key_ring_id:, key_id:, version_id:
    # [START kms_get_public_key]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Call the API.
    public_key = client.get_public_key name: key_version_name
    puts "Public key: #{public_key.pem}"
    # [END kms_get_public_key]

    public_key
  end

  def iam_add_member project_id:, location_id:, key_ring_id:, key_id:, member:
    # [START kms_iam_add_member]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # member      = "user:foo@example.com"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the resource name.
    resource_name = client.crypto_key_path project:    project_id,
                                           location:   location_id,
                                           key_ring:   key_ring_id,
                                           crypto_key: key_id

    # The resource name could also be a key ring.
    # resource_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Create the IAM client.
    iam_client = Google::Cloud::Kms::V1::IAMPolicy::Client.new

    # Get the current IAM policy.
    policy = iam_client.get_iam_policy resource: resource_name

    # Add the member to the policy.
    policy.bindings << Google::Iam::V1::Binding.new(
      members: [member],
      role:    "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    )

    # Save the updated policy.
    updated_policy = iam_client.set_iam_policy resource: resource_name, policy: policy
    puts "Added #{member}"
    # [END kms_iam_add_member]

    updated_policy
  end

  def iam_get_policy project_id:, location_id:, key_ring_id:, key_id:
    # [START kms_iam_get_policy]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the resource name.
    resource_name = client.crypto_key_path project:    project_id,
                                           location:   location_id,
                                           key_ring:   key_ring_id,
                                           crypto_key: key_id

    # The resource name could also be a key ring.
    # resource_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Create the IAM client.
    iam_client = Google::Cloud::Kms::V1::IAMPolicy::Client.new

    # Get the current IAM policy.
    policy = iam_client.get_iam_policy resource: resource_name

    # Print the policy.
    puts "Policy for #{resource_name}"
    policy.bindings.each do |bind|
      puts bind.role.to_s
      bind.members.each do |member|
        puts "- #{member}"
      end
    end
    # [END kms_iam_get_policy]

    policy
  end

  def iam_remove_member project_id:, location_id:, key_ring_id:, key_id:, member:
    # [START kms_iam_remove_member]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # member      = "user:foo@example.com"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the resource name.
    resource_name = client.crypto_key_path project:    project_id,
                                           location:   location_id,
                                           key_ring:   key_ring_id,
                                           crypto_key: key_id

    # The resource name could also be a key ring.
    # resource_name = client.key_ring_path project: project_id, location: location_id, key_ring: key_ring_id

    # Create the IAM client.
    iam_client = Google::Cloud::Kms::V1::IAMPolicy::Client.new

    # Get the current IAM policy.
    policy = iam_client.get_iam_policy resource: resource_name

    # Remove the member from the current bindings
    policy.bindings.each do |bind|
      if bind.role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        bind.members.delete member
      end
    end

    # Save the updated policy.
    updated_policy = iam_client.set_iam_policy resource: resource_name, policy: policy
    puts "Removed #{member}"
    # [END kms_iam_remove_member]

    updated_policy
  end

  def quickstart project_id:, location_id:
    # [START kms_quickstart]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent location name.
    location_name = client.location_path project: project_id, location: location_id

    # Call the API.
    key_rings = client.list_key_rings parent: location_name

    # Example of iterating over key rings.
    puts "Key rings in #{location_name}"
    key_rings.each do |key_ring|
      puts key_ring.name.to_s
    end
    # [END kms_quickstart]

    key_rings
  end

  def restore_key_version project_id:, location_id:, key_ring_id:, key_id:, version_id:
    # [START kms_restore_key_version]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Call the API.
    restored_version = client.restore_crypto_key_version name: key_version_name
    puts "Restored key version: #{restored_version.name}"
    # [END kms_restore_key_version]

    restored_version
  end

  def sign_asymmetric project_id:, location_id:, key_ring_id:, key_id:, version_id:, message:
    # [START kms_sign_asymmetric]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"
    # message     = "my message"

    # Require the library.
    require "google/cloud/kms"

    # Require digest.
    require "digest"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Calculate the hash.
    #
    # Note: Key algorithms will require a varying hash function. For
    # example, EC_SIGN_P384_SHA384 requires SHA-384.
    digest = { sha256: Digest::SHA256.digest(message) }

    # Call the API.
    sign_response = client.asymmetric_sign name: key_version_name, digest: digest
    puts "Signature: #{Base64.strict_encode64 sign_response.signature}"
    # [END kms_sign_asymmetric]

    sign_response
  end

  def sign_mac project_id:, location_id:, key_ring_id:, key_id:, version_id:, data:
    # [START kms_sign_mac]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"
    # data        = "my data"

    # Require the library.
    require "google/cloud/kms"

    # Require digest.
    require "digest"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Call the API.
    sign_response = client.mac_sign name: key_version_name, data: data

    # The data comes back as raw bytes, which may include non-printable
    # characters. This base64-encodes the result so it can be printed below.
    encoded_signature = Base64.strict_encode64 sign_response.mac

    puts "Signature: #{encoded_signature}"
    # [END kms_sign_mac]

    sign_response
  end

  def update_key_add_rotation project_id:, location_id:, key_ring_id:, key_id:
    # [START kms_update_key_add_rotation_schedule]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Build the key.
    key = {
      name:               key_name,

      # Rotate the key every 30 days.
      rotation_period:    {
        seconds: 60 * 60 * 24 * 30
      },

      # Start the first rotation in 24 hours.
      next_rotation_time: {
        seconds: (Time.now + 60 * 60 * 24).to_i
      }
    }

    # Build the field mask.
    update_mask = { paths: ["rotation_period", "next_rotation_time"] }

    # Call the API.
    updated_key = client.update_crypto_key crypto_key: key, update_mask: update_mask
    puts "Updated key: #{updated_key.name}"
    # [END kms_update_key_add_rotation_schedule]

    updated_key
  end

  def update_key_remove_labels project_id:, location_id:, key_ring_id:, key_id:
    # [START kms_update_key_remove_labels]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Build the key.
    key = {
      name:   key_name,
      labels: {}
    }

    # Build the field mask.
    update_mask = { paths: ["labels"] }

    # Call the API.
    updated_key = client.update_crypto_key crypto_key: key, update_mask: update_mask
    puts "Updated key: #{updated_key.name}"
    # [END kms_update_key_remove_labels]

    updated_key
  end

  def update_key_remove_rotation project_id:, location_id:, key_ring_id:, key_id:
    # [START kms_update_key_remove_rotation_schedule]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Build the key.
    key = {
      name:               key_name,
      rotation_period:    nil,
      next_rotation_time: nil
    }

    # Build the field mask.
    update_mask = { paths: ["rotation_period", "next_rotation_time"] }

    # Call the API.
    updated_key = client.update_crypto_key crypto_key: key, update_mask: update_mask
    puts "Updated key: #{updated_key.name}"
    # [END kms_update_key_remove_rotation_schedule]

    updated_key
  end

  def update_key_set_primary project_id:, location_id:, key_ring_id:, key_id:, version_id:
    # [START kms_update_key_set_primary]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Call the API.
    updated_key = client.update_crypto_key_primary_version name: key_name, crypto_key_version_id: version_id
    puts "Updated primary #{updated_key.name} to #{version_id}"
    # [END kms_update_key_set_primary]

    updated_key
  end

  def update_key_update_labels project_id:, location_id:, key_ring_id:, key_id:
    # [START kms_update_key_update_labels]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"

    # Require the library.
    require "google/cloud/kms"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the parent key name.
    key_name = client.crypto_key_path project:    project_id,
                                      location:   location_id,
                                      key_ring:   key_ring_id,
                                      crypto_key: key_id

    # Build the key.
    key = {
      name:   key_name,
      labels: {
        "new_label" => "new_value"
      }
    }

    # Build the field mask.
    update_mask = { paths: ["labels"] }

    # Call the API.
    updated_key = client.update_crypto_key crypto_key: key, update_mask: update_mask
    puts "Updated key: #{updated_key.name}"
    # [END kms_update_key_update_labels]

    updated_key
  end

  def verify_asymmetric_signature_ec project_id:, location_id:, key_ring_id:, key_id:, version_id:, message:, signature:
    # [START kms_verify_asymmetric_signature_ec]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"
    # message     = "my message"
    # signature   = "..."

    # Require the library.
    require "google/cloud/kms"
    require "openssl"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Get the public key.
    public_key = client.get_public_key name: key_version_name

    # Parse the public key.
    ec_key = OpenSSL::PKey::EC.new public_key.pem

    # Verify the signature.
    verified = ec_key.verify "sha256", signature, message
    puts "Verified: #{verified}"
    # [END kms_verify_asymmetric_signature_ec]

    verified
  end

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5.0")
    def verify_asymmetric_signature_rsa project_id:, location_id:, key_ring_id:, key_id:, version_id:, message:,
                                        signature:
      # [START kms_verify_asymmetric_signature_rsa]
      # TODO(developer): uncomment these values before running the sample.
      # project_id  = "my-project"
      # location_id = "us-east1"
      # key_ring_id = "my-key-ring"
      # key_id      = "my-key"
      # version_id  = "123"
      # message     = "my message"
      # signature   = "..."

      # Require the library.
      require "google/cloud/kms"
      require "openssl"

      # Create the client.
      client = Google::Cloud::Kms.key_management_service

      # Build the key version name.
      key_version_name = client.crypto_key_version_path project:            project_id,
                                                        location:           location_id,
                                                        key_ring:           key_ring_id,
                                                        crypto_key:         key_id,
                                                        crypto_key_version: version_id

      # Get the public key.
      public_key = client.get_public_key name: key_version_name

      # Parse the public key.
      rsa_key = OpenSSL::PKey::RSA.new public_key.pem

      # Verify the signature.
      #
      # Note: The verify_pss() method only exists in Ruby 2.5+.
      verified = rsa_key.verify_pss "sha256", signature, message, salt_length: :digest, mgf1_hash: "sha256"
      puts "Verified: #{verified}"
      # [END kms_verify_asymmetric_signature_rsa]

      verified
    end
  end

  def verify_mac project_id:, location_id:, key_ring_id:, key_id:, version_id:, data:, signature:
    # [START kms_verify_mac]
    # TODO(developer): uncomment these values before running the sample.
    # project_id  = "my-project"
    # location_id = "us-east1"
    # key_ring_id = "my-key-ring"
    # key_id      = "my-key"
    # version_id  = "123"
    # data        = "my data"
    # signature   = "..."

    # Require the library.
    require "google/cloud/kms"

    # Require digest.
    require "digest"

    # Create the client.
    client = Google::Cloud::Kms.key_management_service

    # Build the key version name.
    key_version_name = client.crypto_key_version_path project:            project_id,
                                                      location:           location_id,
                                                      key_ring:           key_ring_id,
                                                      crypto_key:         key_id,
                                                      crypto_key_version: version_id

    # Call the API.
    verify_response = client.mac_verify name: key_version_name, data: data, mac: signature
    puts "Verified: #{verify_response.success}"
    # [END kms_verify_mac]

    verify_response
  end
end
# rubocop:enable Metrics/ClassLength

if $PROGRAM_NAME == __FILE__
  instance = Snippets.new
  methods = instance.public_methods(false).sort
  args = ARGV.dup
  help = ARGV.any? { |a| ["help", "--help", "-h"].include? a }

  command = args.shift
  project = ENV["GOOGLE_CLOUD_PROJECT"]

  if help || command.nil? || command.empty?
    out = "Usage: bundle exec ruby #{__FILE__} [command] [arguments]\n"
    out << "\n"

    out << "Commands:\n"
    methods.each do |method_name|
      out << "  " << method_name.to_s
      instance.public_method(method_name).parameters.each do |_, param|
        next if param == :project_id
        out << " " << param.to_s.upcase
      end
      out << "\n"
    end

    out << "\n"
    out << "Environment variables:\n"
    out << "  GOOGLE_CLOUD_PROJECT"

    puts out
  elsif !methods.include?(command.to_sym)
    puts <<~MSG.strip
      Invalid command `#{command}`.
      Run with --help for help and usage instructions.
    MSG
    exit 1
  else
    kwargs = {}

    instance.public_method(command.to_sym).parameters.each do |_, param|
      if param == :project_id
        kwargs[:project_id] = project
      else
        val = args.shift
        if val.nil? || val.empty? # rubocop:disable Metrics/BlockNesting
          puts "Missing required parameter '#{param}' for command '#{command}'."
          exit 1
        end
        kwargs[param] = val
      end
    end

    instance.public_send(command.to_sym, **kwargs)
  end
end
