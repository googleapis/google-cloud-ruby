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


require "google/cloud/storage/policy/binding"

module Google
  module Cloud
    module Storage
      class Policy
        class Bindings
          include Enumerable

          def initialize
            @bindings = []
          end

          def insert *bindings
            bindings = coerce_bindings(*bindings)
            @bindings += bindings
          end

          def remove *bindings
            bindings = coerce_bindings(*bindings)
            @bindings -= bindings
          end

          def each
            return enum_for :each unless block_given?

            @bindings.each { |binding| yield binding }
          end

          def to_gapi
            @bindings.map(&:to_gapi)
          end

          protected

          def coerce_bindings *bindings
            bindings.map do |binding|
              binding = Binding.new(**binding) if binding.is_a? Hash
              raise ArgumentError, "expected Binding, not #{binding.inspect}" unless binding.is_a? Binding
              binding
            end
          end
        end
      end
    end
  end
end
