# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0oud
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Stackdriver
  module Core
    ##
    # @private Helps organize configuration options for Stackdriver
    # instrumentation libraries. It's initialized with a nested list of
    # predefined option keys, then only allows getting and setting these
    # predefined options.
    #
    # @example
    #   nested_categories = [:nested1, {nested2: [:nested3]}]
    #   config = Stackdriver::Core::Configuration.new nested: nested_categories
    #
    #   config.opt1        #=> nil
    #   config.opt1 = true #=> true
    #   config.opt1        #=> true
    #
    #   config.nested1           #=> <Stackdriver::Core::Configuration>
    #   config.nested2.nested3   #=> <Stackdriver::Core::Configuration>
    #
    class Configuration < Hash
      ##
      # Constructs a new instance of Configuration object.
      #
      # @param [Symbol, Array<Symbol, Hash>, Hash<Symbol, (Array, Hash)>] nested
      #   A Symbol, or nested Array and Hash of sub configuration categories.
      #   A single Symbol and Symbols in array will be keys to next level of
      #   categories. Nested hash represent sub categories with further nested
      #   sub categories.
      #
      def initialize nested = {}
        super()

        add_nested nested
      end

      ##
      # Add nested sub configurations to a Configuration object
      #
      # @param [Symbol, Array<Symbol, Hash>, Hash<Symbol, ( Array, Hash)>] nested
      #   A Symbol, or nested Array and Hash of sub configuration categories.
      #   A single Symbol and Symbols in array will be keys to next level of
      #   categories. Nested hash represent sub categories with further nested
      #   sub categories.
      #
      # @example
      #   config = Stackdriver::Core::Configuration.new
      #   config.nest1 #=> nil
      #   config.add_nested {nest1: [nest2]}
      #   config.nest1 #=> <Stackdriver::Core::Configuration>
      #   config.nest1.nest2 #=> <Stackdriver::Core::Configuration>
      #
      def add_nested nested
        nested = [nested].flatten(1)
        nested.each do |sub_key|
          case sub_key
            when Symbol
              self[sub_key] = self.class.new
            when Hash
              sub_key.each do |k, v|
                self[k] = self.class.new v
              end
            else
              fail ArgumentError \
              "Configuration option can only be Symbol or Hash"
          end
        end
      end

      ##
      # @private Wrap inherited #[] method. Force key to be a Symbol.
      def []= key, value
        super key.to_sym, value
      end

      ##
      # @private Wrap inherited #[]= method. Force key to be a Symbol.
      def [] key
        super key.to_sym
      end

      ##
      # Check if the Configuration object has this option
      #
      # @param [Symbol] key The key to check for.
      #
      # @return [Boolean] True if the inquired key is a valid option for this
      #   Configuration object. False otherwise.
      #
      alias_method :option?, :key?

      ##
      # @private Dynamic getters and setters
      def method_missing mid, *args
        method_string = mid.to_s
        if method_string.chomp!("=")
          self[method_string] = args.first
        else
          self[mid]
        end
      end
    end
  end
end
