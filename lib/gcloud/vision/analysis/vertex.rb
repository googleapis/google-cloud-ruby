# Copyright 2016 Google Inc. All rights reserved.
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


module Gcloud
  module Vision
    class Analysis
      ##
      # # Vertex
      class Vertex
        attr_accessor :x, :y

        def initialize x, y
          @x = x
          @y = y
        end

        def to_a
          to_ary
        end

        def to_ary
          [x, y]
        end

        def to_h
          to_hash
        end

        def to_hash
          { x: x, y: y }
        end

        def to_s
          "(x: #{x.inspect}, y: #{y.inspect})"
        end

        def inspect
          "#<#{self.class.class_name} #{self}>"
        end

        ##
        # @private New Analysis::Entity::Bounds::Vertex from a Google API
        # Client object.
        def self.from_gapi gapi
          new gapi["x"], gapi["y"]
        end
      end
    end
  end
end
