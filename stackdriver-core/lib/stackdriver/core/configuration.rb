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
    #   options = [opt1, {category1: [opt2]}, {category2: [opt3]}]
    #   config = Stackdriver::Core::Configuration.new options: options
    #
    #   config.opt1 = true
    #   config.category1.opt2 = false
    #
    #   config.opt1           #=> true
    #   config.category1.opt2 #=> false
    #   config.category2.opt3 #=> nil
    #   config.opt4           #=> RuntimeError: Unrecognized option: opt4
    #
    class Configuration
      ##
      # @private Constructs a new instance of Configuration object.
      #
      # @param [Array<Symbol, Hash<Symbol, Array>>] options A nested list of
      #   predefined option keys. Symbols in array will be option keys for this
      #   level. Nested hash translates to nested Configuration objects with
      #   nested options.
      #
      def initialize options: []
        @configs = {}

        init_options @configs, options
      end

      ##
      # @private Dynamic getters and setters
      def method_missing mid, *args
        match = mid.match(/(\w+)(=?)$/)
        fail NoMethodError, mid unless match

        config_key = match[1].to_sym
        assignment = !match[2].empty?

        if @configs.key? config_key
          if @configs[config_key].is_a? Configuration
            if assignment
              fail "#{config_key} is not a configuration option"
            else
              return @configs[config_key]
            end
          else
            if assignment
              @configs[config_key] = args.first
            else
              return @configs[config_key]
            end
          end
        else
          fail "Unrecognized Option: #{mid}"
        end
      end

      private

      def init_options configs, options
        options.each do |option|
          case option
            when Symbol
              configs[option] = nil
            when Hash
              option.each do |k, v|
                configs[k] = self.class.new options: v
              end
            else
              fail ArgumentError \
                "Configuration option can only be symbol or hash"
          end
        end
      end
    end
  end
end
