# Copyright 2017 Google LLC
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
    ##
    # @private Helps organize configuration options for Stackdriver
    # instrumentation libraries. It's initialized with a nested list of
    # predefined category keys, then only allows getting and setting these
    # predefined options.
    #
    # @example
    #   nested_categories = [:cat1, {cat2: [:cat3]}]
    #   config = Google::Cloud::Configuration.new nested_categories
    #
    #   config.opt1        #=> nil
    #   config.opt1 = true #=> true
    #   config.opt1        #=> true
    #
    #   config.cat1           #=> <Google::Cloud::Configuration>
    #   config.cat2.cat3   #=> <Google::Cloud::Configuration>
    #
    class Configuration
      ##
      # Constructs a new instance of Configuration object.
      #
      # @param [Symbol, Array<Symbol, Hash>, Hash<Symbol, (Array, Hash)>]
      #   categories A Symbol, or nested Array and Hash of sub configuration
      #   categories. A single symbol, or symbols in array, will be key(s) to
      #   next level of categories. Nested hash represent sub categories with
      #   further nested sub categories.
      #
      def initialize categories = {}
        @configs = {}

        add_options categories
      end

      ##
      # Add nested sub configuration categories to a Configuration object
      #
      # @param [Symbol, Array<Symbol, Hash>, Hash<Symbol, (Array, Hash)>]
      #   categories A Symbol, or nested Array and Hash of sub configuration
      #   categories. A single symbol, or symbols in array, will be key(s) to
      #   next level of categories. Nested hash represent sub categories with
      #   further nested sub categories.
      #
      # @example
      #   config = Google::Cloud::Configuration.new
      #   config.cat1 #=> nil
      #   config.add_options {cat1: [:cat2]}
      #   config.cat1 #=> <Google::Cloud::Configuration>
      #   config.cat1.cat2 #=> <Google::Cloud::Configuration>
      #
      def add_options categories
        categories = [categories].flatten(1)
        categories.each do |sub_key|
          case sub_key
          when Symbol
            self[sub_key] = self.class.new
          when Hash
            sub_key.each do |k, v|
              self[k] = self.class.new v
            end
          else
            raise ArgumentError \
              "Configuration option can only be Symbol or Hash"
          end
        end
      end

      ##
      # Assign an option with `key` to value, while forcing `key` to be a
      # Symbol.
      def []= key, value
        @configs[key.to_sym] = value
      end

      ##
      # Get the option with `key`, while forcing `key` to be a Symbol.
      def [] key
        @configs[key.to_sym]
      end

      ##
      # Delete the option with `key`, while forcing `key` to be a Symbol.
      def delete key
        @configs.delete key.to_sym
      end

      ##
      # Clears all options.
      def clear
        @configs.clear
      end

      ##
      # Check if the Configuration object has this option
      #
      # @param [Symbol] key The key to check for.
      #
      # @return [Boolean] True if the inquired key is a valid option for this
      #   Configuration object. False otherwise.
      #
      def option? key
        @configs.key? key.to_sym
      end

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

      def respond_to_missing? name, include_private
        return true if option? name.to_s.chomp("=")
        super
      end
    end

    # Shared Configuration object that all libraries will use.
    @config = Configuration.new

    ##
    # Configure the default parameter for Google::Cloud. The values defined on
    # this top level will be shared across all Stackdriver instrumentation
    # libraries (Debugger, ErrorReporting, Logging, and Trace). These other
    # libraries may also add sub configuration options under this.
    #
    # Possible configuration parameters:
    #   * project_id: The Google Cloud Project ID. Automatically discovered
    #                 when running from GCP environments.
    #   * credentials: The service account JSON file path. Automatically
    #                  discovered when running from GCP environments.
    #   * use_debugger: Explicitly enable or disable Stackdriver Debugger
    #                   instrumentation
    #   * use_error_reporting: Explicitly enable or disable Stackdriver Error
    #                          Reporting instrumentation
    #   * use_logging: Explicitly enable or disable Stackdriver Logging
    #                  instrumentation
    #   * use_trace: Explicitly enable or disable Stackdriver
    #
    # @return [Google::Cloud::Configuration] The configuration object
    #   for Google::Cloud libraries.
    #
    def self.configure
      yield @config if block_given?

      @config
    end
  end
end
