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


require "base64"
require "cgi"
require "openssl"
require "google/cloud/storage/errors"

module Google
  module Cloud
    module Storage
      class File
        ##
        # @private Create a signed_url for a file.
        class V4Signer
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

          ##
          # The external path to the file.
          def ext_path
            escaped_path = String(@file_name).split("/").map do |node|
              CGI.escape node
            end.join("/")
            "/#{CGI.escape @bucket_name}/#{escaped_path}"
          end

          ##
          # The external url to the file.
          def ext_url
            "#{GOOGLEAPIS_URL}#{ext_path}"
          end

          def signature_str options
            [options[:method], options[:content_md5],
             options[:content_type], options[:expires],
             format_extension_headers(options[:headers]) + ext_path].join "\n"
          end

          def signed_url method: "GET", expires: nil, headers: nil,
                         issuer: nil, client_email: nil,
                         access_token: nil, project_id: nil, signing_key: nil,
                         private_key: nil, query: nil

            headers = Hash[headers.map{ |k,v| [k.downcase, v.strip.gsub(/\s+/, " ")] } ] if headers

            # Select appropriate signer
            signer = nil
            if !access_token.nil? && !client_email.nil? && !project_id.nil?
              # Use access token
              signer = iam_signer project_id, CGI.escape(client_email), access_token
            else
              # Use service account
              # Parse the Service Account and get client id and private key



              issuer = issuer || client_email || @service.credentials.issuer
              raise SignedUrlUnavailable, "issuer (client_email) not found "unless issuer
              signing_key = signing_key ||
                private_key || @service.credentials.signing_key
              raise SignedUrlUnavailable, "signing_key (private_key) not found "unless signing_key
              signer = service_account_signer signing_key
            end
            expires ||= 604800 # Default is 7 days.
            if expires > 604800
              fail "Expiration time can't be longer than a week"
            end

            datetime_now = Time.now.utc
            goog_date = datetime_now.strftime("%Y%m%dT%H%M%SZ")
            datestamp = datetime_now.strftime("%Y%m%d")
            algorithm = "GOOG4-RSA-SHA256"
            # goog4_request is not checked.
            region_name = "auto"
            credential_scope = "#{datestamp}/#{region_name}/storage/goog4_request"
            # Headers needs to be in alpha order.
            canonical_headers = headers || {}
            canonical_headers["host"] = "storage.googleapis.com"

            canonical_headers = canonical_headers.sort_by { |k, v| k.downcase }.to_h
            canonical_headers_str = ""
            canonical_headers.each { |k, v| canonical_headers_str += "#{k}:#{v}\n" }
            signed_headers_str = ""
            canonical_headers.each { |k, v| signed_headers_str += "#{k};" }
            signed_headers_str = signed_headers_str.chomp(';') # remove trailing ';'

            # Begin constructing string_to_sign
            # Needs to be in alpha order
            credential = CGI.escape(issuer + "/" + credential_scope)
            query ||={}
            query["X-Goog-Algorithm"] = algorithm
            query["X-Goog-Credential"] = credential
            query["X-Goog-Date"] = goog_date
            query["X-Goog-Expires"] = expires
            query["X-Goog-SignedHeaders"] = CGI.escape(signed_headers_str)
            query = query.sort_by { |k, v| k.to_s.downcase }.to_h
            canonical_querystring = ""
            query.each { |k, v| canonical_querystring += "#{k}=#{v}&" }
            canonical_querystring = canonical_querystring.chomp("&") # remove trailing '&'

            # From AWS: You don't include a payload hash in the Canonical Request,
            # because when you create a presigned URL, you don't know the payload
            # content because the URL is used to upload an arbitrary payload. Instead,
            # you use a constant string UNSIGNED-PAYLOAD.
            canonical_request = [method,
                                 ext_path,
                                 canonical_querystring,
                                 canonical_headers_str,
                                 signed_headers_str,
                                 "UNSIGNED-PAYLOAD"].join("\n")

            # Construct string to sign
            string_to_sign = [algorithm,
                              goog_date,
                              credential_scope,
                              Digest::SHA256.hexdigest(canonical_request)].join("\n")


            # puts "\n\ncanonical_request\n\n#{canonical_request}\n\nstring_to_sign\n\n#{string_to_sign}\n\n"
            # Sign string
            signature = signer.call(string_to_sign)

            # Construct signed URL
            "#{ext_url}?#{canonical_querystring}&X-Goog-Signature=#{signature}"
          end

          protected

          ##
          # The external path to the file.
          def ext_path
            escaped_path = String(@file_name).split("/").map do |node|
              CGI.escape node
            end.join("/")
            "/#{CGI.escape @bucket_name}/#{escaped_path}"
          end

          ##
          # The external url to the file.
          def ext_url
            "#{GOOGLEAPIS_URL}#{ext_path}"
          end

          def service_account_signer signer
            unless signer.respond_to? :sign
              signer = OpenSSL::PKey::RSA.new signer
            end
            # Sign string to sign
            lambda do |string_to_sign|
              signature = signer.sign(OpenSSL::Digest::SHA256.new, string_to_sign).unpack('H*').first
            end
          end

          def iam_signer project_id, client_email, access_token
            lambda do |string_to_sign|
              begin
                uri = URI("https://iam.googleapis.com/v1/projects/-/serviceAccounts/#{client_email}:signBlob")
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                #http.set_debug_output($stdout)
                header = {}
                header["Authorization"] = "Bearer #{access_token}"
                header["Content-type"] = "application/json"
                req = Net::HTTP::Post.new(uri, header)
                req.body = {"bytesToSign" => Base64.strict_encode64(string_to_sign)}.to_json
                res = http.request req
                unless res.kind_of? Net::HTTPSuccess
                  fail "Unable to sign string #{res.body}"
                end
                puts res.body
                Base64.strict_decode64(JSON.parse(res.body)["signature"]).unpack('H*').first
              rescue => err
                fail "Error occurred: #{err}"
              end
            end
          end
        end
      end
    end
  end
end
