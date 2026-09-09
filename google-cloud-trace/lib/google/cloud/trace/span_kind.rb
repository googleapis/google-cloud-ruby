# Copyright 2014 Google LLC
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
    module Trace
      ##
      # SpanKind represents values for the "kind" field of span.
      #
      class SpanKind
        @@mapping = {}

        ##
        # Create a new SpanKind.
        #
        # @private
        #
        def initialize name
          @name = name
          @@mapping[name] = self
        end

        ##
        # The `:SPAN_KIND_UNSPECIFIED` value
        #
        UNSPECIFIED = new :SPAN_KIND_UNSPECIFIED

        ##
        # The `:RPC_SERVER` value
        #
        RPC_SERVER = new :RPC_SERVER

        ##
        # The `:RPC_CLIENT` value
        #
        RPC_CLIENT = new :RPC_CLIENT

        ##
        # Returns the symbolic representation of this SpanKind
        #
        # @return [Symbol] Symbol representation.
        #
        def to_sym
          @name
        end

        ##
        # Returns the string representation of this SpanKind
        #
        # @return [String] String representation.
        #
        def to_s
          to_sym.to_s
        end

        ##
        # Returns the SpanKind given a symbol or string representation.
        #
        # @param [String, Symbol] name The name of the SpanKind.
        # @return [SpanKind] The SpanKind, or `nil` if not known.
        #
        def self.get name
          @@mapping[name.to_sym]
        end
      end
    end
  end
end
