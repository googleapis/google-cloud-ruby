# Copyright 2019 Google LLC
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


require "addressable/uri"
require "cgi"
require "openssl"
require "google/cloud/storage/errors"

module Google
  module Cloud
    module Storage
      class File
        ##
        # @private Create a signed_url for a file.
        class SignerV4
          def initialize bucket_name, file_name, service
            @bucket_name = bucket_name
            @file_name = file_name
            @service = service
          end

          def self.from_file file
            new file.bucket, file.name, file.service
          end

          def self.from_bucket bucket, file_name
            new bucket.name, file_name, bucket.service
          end

          def signed_url method: "GET", expires: nil, headers: nil,
                         issuer: nil, client_email: nil, signing_key: nil,
                         private_key: nil, query: nil
            issuer, signer = issuer_and_signer issuer, client_email,
                                               signing_key, private_key
            datetime_now = Time.now.utc
            goog_date = datetime_now.strftime "%Y%m%dT%H%M%SZ"
            datestamp = datetime_now.strftime "%Y%m%d"
            # goog4_request is not checked.
            scope = "#{datestamp}/auto/storage/goog4_request"

            canonical_headers_str, signed_headers_str = \
              canonical_and_signed_headers headers

            algorithm = "GOOG4-RSA-SHA256"
            expires = determine_expires expires
            credential = CGI.escape issuer + "/" + scope
            canonical_query_str = canonical_query query, algorithm,
                                                  credential, goog_date,
                                                  expires, signed_headers_str

            # From AWS: You don't include a payload hash in the Canonical
            # Request, because when you create a presigned URL, you don't know
            # the payload content because the URL is used to upload an arbitrary
            # payload. Instead, you use a constant string UNSIGNED-PAYLOAD.
            canonical_request = [method,
                                 ext_path,
                                 canonical_query_str,
                                 canonical_headers_str,
                                 signed_headers_str,
                                 "UNSIGNED-PAYLOAD"].join("\n")
            # Construct string to sign
            req_sha = Digest::SHA256.hexdigest canonical_request
            string_to_sign = [algorithm, goog_date, scope, req_sha].join "\n"

            # Sign string
            signature = signer.call string_to_sign

            # Construct signed URL
            "#{ext_url}?#{canonical_query_str}&X-Goog-Signature=#{signature}"
          end

          protected

          def determine_issuer issuer, client_email
            # Parse the Service Account and get client id and private key
            issuer = issuer || client_email || @service.credentials.issuer
            unless issuer
              raise SignedUrlUnavailable, "issuer (client_email) missing"
            end
            issuer
          end

          def determine_signing_key signing_key, private_key
            signing_key = signing_key || private_key ||
                          @service.credentials.signing_key
            unless signing_key
              raise SignedUrlUnavailable, "signing_key (private_key) missing"
            end
            signing_key
          end

          def service_account_signer signer
            unless signer.respond_to? :sign
              signer = OpenSSL::PKey::RSA.new signer
            end
            # Sign string to sign
            lambda do |string_to_sign|
              sig = signer.sign OpenSSL::Digest::SHA256.new, string_to_sign
              sig.unpack("H*").first
            end
          end

          def issuer_and_signer issuer, client_email, signing_key, private_key
            issuer = determine_issuer issuer, client_email
            signing_key = determine_signing_key signing_key, private_key
            signer = service_account_signer signing_key
            [issuer, signer]
          end

          def canonical_and_signed_headers headers
            # Headers needs to be in alpha order.
            canonical_headers = headers || {}
            headers_arr = canonical_headers.map do |k, v|
              [k.downcase, v.strip.gsub(/[^\S\t]+/, " ").gsub(/\t+/, "\t")]
            end
            canonical_headers = Hash[headers_arr]
            canonical_headers["host"] = "storage.googleapis.com"

            canonical_headers = canonical_headers.sort_by do |k, _|
              k.downcase
            end.to_h
            canonical_headers_str = ""
            canonical_headers.each do |k, v|
              canonical_headers_str += "#{k}:#{v}\n"
            end
            signed_headers_str = ""
            canonical_headers.each_key { |k| signed_headers_str += "#{k};" }
            signed_headers_str = signed_headers_str.chomp ";"
            [canonical_headers_str, signed_headers_str]
          end

          def determine_expires expires
            expires ||= 604_800 # Default is 7 days.
            if expires > 604_800
              raise ArgumentError, "Expiration time can't be longer than a week"
            end
            expires
          end

          def canonical_query query, algorithm, credential, goog_date, expires,
                              signed_headers_str
            query ||= {}
            query["X-Goog-Algorithm"] = algorithm
            query["X-Goog-Credential"] = credential
            query["X-Goog-Date"] = goog_date
            query["X-Goog-Expires"] = expires
            query["X-Goog-SignedHeaders"] = CGI.escape signed_headers_str
            query = query.sort_by { |k, _| k.to_s.downcase }.to_h
            canonical_query_str = ""
            query.each { |k, v| canonical_query_str += "#{k}=#{v}&" }
            canonical_query_str.chomp "&"
          end

          ##
          # The URI-encoded (percent encoded) external path to the file.
          def ext_path
            path = "/#{@bucket_name}"
            path += "/#{String(@file_name)}" if @file_name && !@file_name.empty?
            Addressable::URI.escape path
          end

          ##
          # The external url to the file.
          def ext_url
            "#{GOOGLEAPIS_URL}#{ext_path}"
          end
        end
      end
    end
  end
end
