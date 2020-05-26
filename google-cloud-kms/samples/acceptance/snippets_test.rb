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

require "securerandom"
require "uri"

require "google/cloud/kms"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require_relative "../snippets"

describe "Cloud KMS samples" do
  let(:rotation_period_seconds) { 60 * 60 * 24 * 30 }
  before :all do
    @client      = Google::Cloud::Kms.new
    @project_id  = ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT")
    @location_id = "us-east1"

    @key_ring_id = SecureRandom.uuid
    location_name = @client.location_path @project_id, @location_id
    @client.create_key_ring location_name, @key_ring_id, {}
    @key_ring_name = @client.key_ring_path @project_id, @location_id, @key_ring_id


    @asymmetric_sign_ec_key_id = SecureRandom.uuid
    @client.create_crypto_key(@key_ring_name, @asymmetric_sign_ec_key_id,
                              purpose:          :ASYMMETRIC_SIGN,
                              version_template: {
                                algorithm: :EC_SIGN_P256_SHA256
                              },
                              labels:           { "foo" => "bar", "zip" => "zap" })

    @asymmetric_sign_rsa_key_id = SecureRandom.uuid
    @client.create_crypto_key(@key_ring_name, @asymmetric_sign_rsa_key_id,
                              purpose:          :ASYMMETRIC_SIGN,
                              version_template: {
                                algorithm: :RSA_SIGN_PSS_2048_SHA256
                              },
                              labels:           { "foo" => "bar", "zip" => "zap" })


    @symmetric_key_id = SecureRandom.uuid
    @client.create_crypto_key(@key_ring_name, @symmetric_key_id,
                              purpose:          :ENCRYPT_DECRYPT,
                              version_template: {
                                algorithm: :GOOGLE_SYMMETRIC_ENCRYPTION
                              },
                              labels:           { "foo" => "bar", "zip" => "zap" })

    @hsm_key_id = SecureRandom.uuid
    @client.create_crypto_key(@key_ring_name, @hsm_key_id,
                              purpose:          :ENCRYPT_DECRYPT,
                              version_template: {
                                algorithm:        :GOOGLE_SYMMETRIC_ENCRYPTION,
                                protection_level: "HSM"
                              },
                              labels:           { "foo" => "bar", "zip" => "zap" })

    @asymmetric_decrypt_key_id = SecureRandom.uuid
    @client.create_crypto_key(@key_ring_name, @asymmetric_decrypt_key_id,
                              purpose:          :ASYMMETRIC_DECRYPT,
                              version_template: {
                                algorithm: :RSA_DECRYPT_OAEP_2048_SHA256
                              },
                              labels:           { "foo" => "bar", "zip" => "zap" })
  end

  after :all do
    @client.list_crypto_keys(@key_ring_name).each do |key|
      if key.rotation_period || key.next_rotation_time
        updated_key = {
          name:               key.name,
          rotation_period:    nil,
          next_rotation_time: nil
        }
        update_mask = { paths: ["rotation_period", "next_rotation_time"] }
        @client.update_crypto_key updated_key, update_mask
      end

      filter = "state != DESTROYED AND state != DESTROY_SCHEDULED"
      @client.list_crypto_key_versions(key.name, filter: filter).each do |version|
        @client.destroy_crypto_key_version version.name
      end
    end
  end

  it "create_key_asymmetric_decrypt" do
    out = capture_io do
      key = create_key_asymmetric_decrypt(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        id:          SecureRandom.uuid
      )

      assert key
      assert key.version_template
      assert_equal :ASYMMETRIC_DECRYPT, key.purpose
      assert_equal :RSA_DECRYPT_OAEP_2048_SHA256, key.version_template.algorithm
    end
    assert_match(/Created asymmetric decryption key/, out.first)
  end

  it "create_key_asymmetric_sign" do
    out = capture_io do
      key = create_key_asymmetric_sign(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        id:          SecureRandom.uuid
      )

      assert key
      assert key.version_template
      assert_equal :ASYMMETRIC_SIGN, key.purpose
      assert_equal :RSA_SIGN_PKCS1_2048_SHA256, key.version_template.algorithm
    end
    assert_match(/Created asymmetric signing key/, out.first)
  end

  it "create_key_hsm" do
    out = capture_io do
      key = create_key_hsm(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        id:          SecureRandom.uuid
      )

      assert key
      assert key.version_template
      assert_equal :ENCRYPT_DECRYPT, key.purpose
      assert_equal :GOOGLE_SYMMETRIC_ENCRYPTION, key.version_template.algorithm
      assert_equal :HSM, key.version_template.protection_level
    end
    assert_match(/Created hsm key/, out.first)
  end

  it "create_key_labels" do
    out = capture_io do
      key = create_key_labels(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        id:          SecureRandom.uuid
      )

      assert key
      assert key.labels
      assert_equal "alpha", key.labels["team"]
      assert_equal "cc1234", key.labels["cost_center"]
    end
    assert_match(/Created labeled key/, out.first)
  end

  it "create_key_ring" do
    out = capture_io do
      key_ring = create_key_ring(
        project_id:  @project_id,
        location_id: @location_id,
        id:          SecureRandom.uuid
      )

      assert key_ring
      assert_includes key_ring.name, @location_id
    end
    assert_match(/Created key ring/, out.first)
  end

  it "create_key_rotation_schedule" do
    out = capture_io do
      key = create_key_rotation_schedule(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        id:          SecureRandom.uuid
      )

      assert key
      assert key.rotation_period
      assert key.next_rotation_time
      assert_equal rotation_period_seconds, key.rotation_period.seconds
    end
    assert_match(/Created rotating key/, out.first)
  end

  it "create_key_symmetric_encrypt_decrypt" do
    out = capture_io do
      key = create_key_symmetric_encrypt_decrypt(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        id:          SecureRandom.uuid
      )

      assert key
      assert key.version_template
      assert_equal :ENCRYPT_DECRYPT, key.purpose
      assert_equal :GOOGLE_SYMMETRIC_ENCRYPTION, key.version_template.algorithm
    end
    assert_match(/Created symmetric key/, out.first)
  end

  it "create_key_version" do
    out = capture_io do
      version = create_key_version(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id
      )

      assert version
      assert_includes version.name, @key_ring_id
    end
    assert_match(/Created key version/, out.first)
  end

  it "decrypt_asymmetric" do
    skip "Ruby does not support customizing MGF or hash"
  end

  it "decrypt_symmetric" do
    plaintext = "my message"

    key_name = @client.crypto_key_path @project_id, @location_id, @key_ring_id, @symmetric_key_id
    encrypt_response = @client.encrypt key_name, plaintext
    ciphertext = encrypt_response.ciphertext

    out = capture_io do
      decrypt_response = decrypt_symmetric(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        ciphertext:  ciphertext
      )

      assert decrypt_response
      assert_equal plaintext, decrypt_response.plaintext
    end
    assert_match(/Plaintext/, out.first)
  end

  it " destroy|restore)_key_version" do
    key_name = @client.crypto_key_path @project_id, @location_id, @key_ring_id, @symmetric_key_id
    version = @client.create_crypto_key_version key_name, {}
    version_id = version.name.split("/").last

    out = capture_io do
      version = destroy_key_version(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        version_id:  version_id
      )

      assert version
      assert_includes [:DESTROYED, :DESTROY_SCHEDULED], version.state
    end
    assert_match(/Destroyed key version/, out.first)

    out = capture_io do
      version = restore_key_version(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        version_id:  version_id
      )

      assert version
      assert_equal :DISABLED, version.state
    end
    assert_match(/Restored key version/, out.first)
  end

  it "(disable|enable)_key_version" do
    key_name = @client.crypto_key_path @project_id, @location_id, @key_ring_id, @symmetric_key_id
    version = @client.create_crypto_key_version key_name, {}
    version_id = version.name.split("/").last

    out = capture_io do
      version = disable_key_version(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        version_id:  version_id
      )

      assert version
      assert_equal :DISABLED, version.state
    end
    assert_match(/Disabled key version/, out.first)

    out = capture_io do
      version = enable_key_version(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        version_id:  version_id
      )

      assert version
      assert_equal :ENABLED, version.state
    end
    assert_match(/Enabled key version/, out.first)
  end

  it "encrypt_asymmetric" do
    skip "Ruby does not support customizing MGF or hash"
  end

  it "encrypt_symmetric" do
    plaintext = "my message"
    ciphertext = nil

    out = capture_io do
      encrypt_response = encrypt_symmetric(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        plaintext:   plaintext
      )

      assert encrypt_response
      assert encrypt_response.ciphertext
      ciphertext = encrypt_response.ciphertext
    end
    assert_match(/Ciphertext/, out.first)

    key_name = @client.crypto_key_path @project_id, @location_id, @key_ring_id, @symmetric_key_id
    decrypt_response = @client.decrypt key_name, ciphertext
    assert_equal plaintext, decrypt_response.plaintext
  end

  it "get_key_labels" do
    out = capture_io do
      key = get_key_labels(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id
      )

      assert key
      assert key.labels
      assert_equal "bar", key.labels["foo"]
    end
    assert_match(/foo = bar/, out.first)
  end

  it "get_key_version_attestation" do
    out = capture_io do
      attestation = get_key_version_attestation(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @hsm_key_id,
        version_id:  "1"
      )

      assert attestation
      assert attestation.content
    end
    assert_match(/Attestation/, out.first)
  end

  it "get_key_version_attestation" do
    out = capture_io do
      public_key = get_public_key(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @asymmetric_decrypt_key_id,
        version_id:  "1"
      )

      assert public_key
      assert public_key.pem
    end
    assert_match(/Public key/, out.first)
  end

  it "iam_add_member" do
    out = capture_io do
      policy = iam_add_member(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        member:      "group:test@google.com"
      )

      assert policy
      bind = policy.bindings.find do |b|
        b.role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
      end

      assert bind
      assert_includes bind.members, "group:test@google.com"
    end
    assert_match(/Added/, out.first)
  end

  it "iam_get_policy" do
    out = capture_io do
      policy = iam_get_policy(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id
      )

      assert policy
    end
    assert_match(/Policy for/, out.first)
  end

  it "iam_remove_member" do
    out = capture_io do
      policy = iam_remove_member(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        member:      "group:test@google.com"
      )

      assert policy
      bind = policy.bindings.find do |b|
        b.role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
      end

      assert_nil bind
    end
    assert_match(/Removed/, out.first)
  end

  it "quickstart" do
    out = capture_io do
      key_rings = quickstart(
        project_id:  @project_id,
        location_id: @location_id
      )

      assert key_rings
    end
    assert_match(/Key rings/, out.first)
  end

  it "sign_asymmetric" do
    message = "my message"

    out = capture_io do
      signature = sign_asymmetric(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @asymmetric_sign_ec_key_id,
        version_id:  "1",
        message:     message
      )

      assert signature
      # Note: we can't verify the signature because we can't customize the
      # padding.
    end
    assert_match(/Signature/, out.first)
  end

  it "update_key_add_rotation" do
    out = capture_io do
      key = update_key_add_rotation(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id
      )

      assert key
      assert key.rotation_period
      assert key.next_rotation_time
      assert_equal rotation_period_seconds, key.rotation_period.seconds
    end
    assert_match(/Updated/, out.first)
  end

  it "update_key_remove_labels" do
    out = capture_io do
      key = update_key_remove_labels(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @asymmetric_decrypt_key_id
      )

      assert key
      assert_empty key.labels.to_h
    end
    assert_match(/Updated/, out.first)
  end

  it "update_key_remove_rotation" do
    out = capture_io do
      key = update_key_remove_rotation(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id
      )

      assert key
      assert_nil key.rotation_period
      assert_nil key.next_rotation_time
    end
    assert_match(/Updated/, out.first)
  end

  it "update_key_set_primary" do
    out = capture_io do
      key = update_key_set_primary(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @symmetric_key_id,
        version_id:  "1"
      )

      assert key
      assert key.primary
      assert_match(/cryptoKeyVersions\/1/, key.primary.name)
    end
    assert_match(/Updated/, out.first)
  end

  it "update_key_update_labels" do
    out = capture_io do
      key = update_key_update_labels(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @asymmetric_sign_ec_key_id
      )

      assert key
      assert_equal({ "new_label" => "new_value" }, key.labels.to_h)
    end
    assert_match(/Updated/, out.first)
  end

  it "verify_asymmetric_signature_ec" do
    message = "my message"
    key_version_name = @client.crypto_key_version_path @project_id,
                                                       @location_id,
                                                       @key_ring_id,
                                                       @asymmetric_sign_ec_key_id,
                                                       "1"
    sign_response = @client.asymmetric_sign(key_version_name,
                                            sha256: Digest::SHA256.digest(message))

    out = capture_io do
      verified = verify_asymmetric_signature_ec(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        key_id:      @asymmetric_sign_ec_key_id,
        version_id:  "1",
        message:     message,
        signature:   sign_response.signature
      )

      assert verified
    end
    assert_match(/Verified/, out.first)
  end

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5.0")
    it "verify_asymmetric_signature_rsa" do
      message = "my message"
      key_version_name = @client.crypto_key_version_path @project_id,
                                                         @location_id,
                                                         @key_ring_id,
                                                         @asymmetric_sign_rsa_key_id,
                                                         "1"
      sign_response = @client.asymmetric_sign(key_version_name,
                                              sha256: Digest::SHA256.digest(message))

      out = capture_io do
        verified = verify_asymmetric_signature_rsa(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @asymmetric_sign_rsa_key_id,
          version_id:  "1",
          message:     message,
          signature:   sign_response.signature
        )

        assert verified
      end
      assert_match(/Verified/, out.first)
    end
  end
end
