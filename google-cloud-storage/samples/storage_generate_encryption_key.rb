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

def generate_encryption_key
  # [START storage_generate_encryption_key]
  require "base64"
  require "openssl"

  encryption_key  = OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key
  encoded_enc_key = Base64.encode64 encryption_key

  puts "Sample encryption key: #{encoded_enc_key}"
  # [END storage_generate_encryption_key]
end

generate_encryption_key if $PROGRAM_NAME == __FILE__
