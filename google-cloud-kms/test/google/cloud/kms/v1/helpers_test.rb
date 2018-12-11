# Copyright 2018 Google LLC
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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/kms"
require "google/cloud/kms/v1/helpers"

require "google/cloud/kms/v1/key_management_service_client"

class HelperMockKmsCredentials_v1 < Google::Cloud::Kms::V1::Credentials
  def initialize
  end

  def updater_proc
    proc do
      raise "The client was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Kms::V1::KeyManagementServiceClient do
  let(:mock_credentials) { HelperMockKmsCredentials_v1.new }

  describe "the crypto_key_version_path instance method" do
    it "correctly calls Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path" do
      Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Kms::V1::KeyManagementServiceClient.method("crypto_key_version_path").arity
        client = Google::Cloud::Kms.new version: :v1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.crypto_key_version_path(*args),
          Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path(*args)
        )
      end
    end
  end

  describe "the key_ring_path instance method" do
    it "correctly calls Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path" do
      Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Kms::V1::KeyManagementServiceClient.method("key_ring_path").arity
        client = Google::Cloud::Kms.new version: :v1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.key_ring_path(*args),
          Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path(*args)
        )
      end
    end
  end

  describe "the crypto_key_path_path instance method" do
    it "correctly calls Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path_path" do
      Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Kms::V1::KeyManagementServiceClient.method("crypto_key_path_path").arity
        client = Google::Cloud::Kms.new version: :v1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.crypto_key_path_path(*args),
          Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path_path(*args)
        )
      end
    end
  end

  describe "the crypto_key_path instance method" do
    it "correctly calls Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path" do
      Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Kms::V1::KeyManagementServiceClient.method("crypto_key_path").arity
        client = Google::Cloud::Kms.new version: :v1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.crypto_key_path(*args),
          Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path(*args)
        )
      end
    end
  end

  describe "the location_path instance method" do
    it "correctly calls Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path" do
      Google::Cloud::Kms::V1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Kms::V1::KeyManagementServiceClient.method("location_path").arity
        client = Google::Cloud::Kms.new version: :v1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.location_path(*args),
          Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path(*args)
        )
      end
    end
  end
end