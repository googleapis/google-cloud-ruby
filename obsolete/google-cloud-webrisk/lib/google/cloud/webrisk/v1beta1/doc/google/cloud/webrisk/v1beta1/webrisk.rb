# Copyright 2020 Google LLC
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


module Google
  module Cloud
    module Webrisk
      module V1beta1
        # Describes an API diff request.
        # @!attribute [rw] threat_type
        #   @return [Google::Cloud::Webrisk::V1beta1::ThreatType]
        #     The ThreatList to update.
        # @!attribute [rw] version_token
        #   @return [String]
        #     The current version token of the client for the requested list (the
        #     client version that was received from the last successful diff).
        # @!attribute [rw] constraints
        #   @return [Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest::Constraints]
        #     Required. The constraints associated with this request.
        class ComputeThreatListDiffRequest
          # The constraints for this diff.
          # @!attribute [rw] max_diff_entries
          #   @return [Integer]
          #     The maximum size in number of entries. The diff will not contain more
          #     entries than this value.  This should be a power of 2 between 2**10 and
          #     2**20.  If zero, no diff size limit is set.
          # @!attribute [rw] max_database_entries
          #   @return [Integer]
          #     Sets the maximum number of entries that the client is willing to have
          #     in the local database. This should be a power of 2 between 2**10 and
          #     2**20. If zero, no database size limit is set.
          # @!attribute [rw] supported_compressions
          #   @return [Array<Google::Cloud::Webrisk::V1beta1::CompressionType>]
          #     The compression types supported by the client.
          class Constraints; end
        end

        # @!attribute [rw] response_type
        #   @return [Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffResponse::ResponseType]
        #     The type of response. This may indicate that an action must be taken by the
        #     client when the response is received.
        # @!attribute [rw] additions
        #   @return [Google::Cloud::Webrisk::V1beta1::ThreatEntryAdditions]
        #     A set of entries to add to a local threat type's list.
        # @!attribute [rw] removals
        #   @return [Google::Cloud::Webrisk::V1beta1::ThreatEntryRemovals]
        #     A set of entries to remove from a local threat type's list.
        #     This field may be empty.
        # @!attribute [rw] new_version_token
        #   @return [String]
        #     The new opaque client version token.
        # @!attribute [rw] checksum
        #   @return [Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffResponse::Checksum]
        #     The expected SHA256 hash of the client state; that is, of the sorted list
        #     of all hashes present in the database after applying the provided diff.
        #     If the client state doesn't match the expected state, the client must
        #     disregard this diff and retry later.
        # @!attribute [rw] recommended_next_diff
        #   @return [Google::Protobuf::Timestamp]
        #     The soonest the client should wait before issuing any diff
        #     request. Querying sooner is unlikely to produce a meaningful diff.
        #     Waiting longer is acceptable considering the use case.
        #     If this field is not set clients may update as soon as they want.
        class ComputeThreatListDiffResponse
          # The expected state of a client's local database.
          # @!attribute [rw] sha256
          #   @return [String]
          #     The SHA256 hash of the client state; that is, of the sorted list of all
          #     hashes present in the database.
          class Checksum; end

          # The type of response sent to the client.
          module ResponseType
            # Unknown.
            RESPONSE_TYPE_UNSPECIFIED = 0

            # Partial updates are applied to the client's existing local database.
            DIFF = 1

            # Full updates resets the client's entire local database. This means
            # that either the client had no state, was seriously out-of-date,
            # or the client is believed to be corrupt.
            RESET = 2
          end
        end

        # Request to check URI entries against threatLists.
        # @!attribute [rw] uri
        #   @return [String]
        #     Required. The URI to be checked for matches.
        # @!attribute [rw] threat_types
        #   @return [Array<Google::Cloud::Webrisk::V1beta1::ThreatType>]
        #     Required. The ThreatLists to search in.
        class SearchUrisRequest; end

        # @!attribute [rw] threat
        #   @return [Google::Cloud::Webrisk::V1beta1::SearchUrisResponse::ThreatUri]
        #     The threat list matches. This may be empty if the URI is on no list.
        class SearchUrisResponse
          # Contains threat information on a matching uri.
          # @!attribute [rw] threat_types
          #   @return [Array<Google::Cloud::Webrisk::V1beta1::ThreatType>]
          #     The ThreatList this threat belongs to.
          # @!attribute [rw] expire_time
          #   @return [Google::Protobuf::Timestamp]
          #     The cache lifetime for the returned match. Clients must not cache this
          #     response past this timestamp to avoid false positives.
          class ThreatUri; end
        end

        # Request to return full hashes matched by the provided hash prefixes.
        # @!attribute [rw] hash_prefix
        #   @return [String]
        #     A hash prefix, consisting of the most significant 4-32 bytes of a SHA256
        #     hash. For JSON requests, this field is base64-encoded.
        # @!attribute [rw] threat_types
        #   @return [Array<Google::Cloud::Webrisk::V1beta1::ThreatType>]
        #     Required. The ThreatLists to search in.
        class SearchHashesRequest; end

        # @!attribute [rw] threats
        #   @return [Array<Google::Cloud::Webrisk::V1beta1::SearchHashesResponse::ThreatHash>]
        #     The full hashes that matched the requested prefixes.
        #     The hash will be populated in the key.
        # @!attribute [rw] negative_expire_time
        #   @return [Google::Protobuf::Timestamp]
        #     For requested entities that did not match the threat list, how long to
        #     cache the response until.
        class SearchHashesResponse
          # Contains threat information on a matching hash.
          # @!attribute [rw] threat_types
          #   @return [Array<Google::Cloud::Webrisk::V1beta1::ThreatType>]
          #     The ThreatList this threat belongs to.
          #     This must contain at least one entry.
          # @!attribute [rw] hash
          #   @return [String]
          #     A 32 byte SHA256 hash. This field is in binary format. For JSON
          #     requests, hashes are base64-encoded.
          # @!attribute [rw] expire_time
          #   @return [Google::Protobuf::Timestamp]
          #     The cache lifetime for the returned match. Clients must not cache this
          #     response past this timestamp to avoid false positives.
          class ThreatHash; end
        end

        # Contains the set of entries to add to a local database.
        # May contain a combination of compressed and raw data in a single response.
        # @!attribute [rw] raw_hashes
        #   @return [Array<Google::Cloud::Webrisk::V1beta1::RawHashes>]
        #     The raw SHA256-formatted entries.
        #     Repeated to allow returning sets of hashes with different prefix sizes.
        # @!attribute [rw] rice_hashes
        #   @return [Google::Cloud::Webrisk::V1beta1::RiceDeltaEncoding]
        #     The encoded 4-byte prefixes of SHA256-formatted entries, using a
        #     Golomb-Rice encoding. The hashes are converted to uint32, sorted in
        #     ascending order, then delta encoded and stored as encoded_data.
        class ThreatEntryAdditions; end

        # Contains the set of entries to remove from a local database.
        # @!attribute [rw] raw_indices
        #   @return [Google::Cloud::Webrisk::V1beta1::RawIndices]
        #     The raw removal indices for a local list.
        # @!attribute [rw] rice_indices
        #   @return [Google::Cloud::Webrisk::V1beta1::RiceDeltaEncoding]
        #     The encoded local, lexicographically-sorted list indices, using a
        #     Golomb-Rice encoding. Used for sending compressed removal indices. The
        #     removal indices (uint32) are sorted in ascending order, then delta encoded
        #     and stored as encoded_data.
        class ThreatEntryRemovals; end

        # A set of raw indices to remove from a local list.
        # @!attribute [rw] indices
        #   @return [Array<Integer>]
        #     The indices to remove from a lexicographically-sorted local list.
        class RawIndices; end

        # The uncompressed threat entries in hash format.
        # Hashes can be anywhere from 4 to 32 bytes in size. A large majority are 4
        # bytes, but some hashes are lengthened if they collide with the hash of a
        # popular URI.
        #
        # Used for sending ThreatEntryAdditons to clients that do not support
        # compression, or when sending non-4-byte hashes to clients that do support
        # compression.
        # @!attribute [rw] prefix_size
        #   @return [Integer]
        #     The number of bytes for each prefix encoded below.  This field can be
        #     anywhere from 4 (shortest prefix) to 32 (full SHA256 hash).
        # @!attribute [rw] raw_hashes
        #   @return [String]
        #     The hashes, in binary format, concatenated into one long string. Hashes are
        #     sorted in lexicographic order. For JSON API users, hashes are
        #     base64-encoded.
        class RawHashes; end

        # The Rice-Golomb encoded data. Used for sending compressed 4-byte hashes or
        # compressed removal indices.
        # @!attribute [rw] first_value
        #   @return [Integer]
        #     The offset of the first entry in the encoded data, or, if only a single
        #     integer was encoded, that single integer's value. If the field is empty or
        #     missing, assume zero.
        # @!attribute [rw] rice_parameter
        #   @return [Integer]
        #     The Golomb-Rice parameter, which is a number between 2 and 28. This field
        #     is missing (that is, zero) if `num_entries` is zero.
        # @!attribute [rw] entry_count
        #   @return [Integer]
        #     The number of entries that are delta encoded in the encoded data. If only a
        #     single integer was encoded, this will be zero and the single value will be
        #     stored in `first_value`.
        # @!attribute [rw] encoded_data
        #   @return [String]
        #     The encoded deltas that are encoded using the Golomb-Rice coder.
        class RiceDeltaEncoding; end

        # The ways in which threat entry sets can be compressed.
        module CompressionType
          # Unknown.
          COMPRESSION_TYPE_UNSPECIFIED = 0

          # Raw, uncompressed data.
          RAW = 1

          # Rice-Golomb encoded data.
          RICE = 2
        end

        # The type of threat. This maps dirrectly to the threat list a threat may
        # belong to.
        module ThreatType
          # Unknown.
          THREAT_TYPE_UNSPECIFIED = 0

          # Malware targeting any platform.
          MALWARE = 1

          # Social engineering targeting any platform.
          SOCIAL_ENGINEERING = 2

          # Unwanted software targeting any platform.
          UNWANTED_SOFTWARE = 3
        end
      end
    end
  end
end