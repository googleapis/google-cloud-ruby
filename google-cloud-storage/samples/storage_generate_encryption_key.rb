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

# [START storage_generate_encryption_key]
def generate_encryption_key
  # Generates a 256 bit (32 byte) AES encryption key and prints the base64 representation.
  #
  # This is included for demonstration purposes. You should generate your own key.
  # Please remember that encryption keys should be handled with a comprehensive security policy.
  require "base64"
  require "openssl"

  encryption_key  = OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key
  encoded_enc_key = Base64.encode64 encryption_key

  puts "Sample encryption key: #{encoded_enc_key}"
end
# [END storage_generate_encryption_key]

generate_encryption_key if $PROGRAM_NAME == __FILE__
