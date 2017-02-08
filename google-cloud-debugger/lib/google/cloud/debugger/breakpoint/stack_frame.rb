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


require "google/cloud/debugger/breakpoint/source_location"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        class StackFrame
          attr_accessor :function

          attr_accessor :location

          attr_accessor :arguments

          attr_accessor :locals

          def initialize
            @function = nil
            @location = SourceLocation.new
            @arguments = nil
            @locals = []
          end

          def to_grpc
            Google::Apis::ClouddebuggerV2::StackFrame.new.tap do |sf|
              sf.function = @function
              sf.location = @location.to_grpc
              # sf.arguments = @arguments
              sf.locals = @locals.map { |var| var.to_grpc }
            end
          end

          def self.from_grpc grpc
            StackFrame.new.tap do |sf|
              sf.function = grpc.function
              sf.location = grpc.location
              arguments = grpc.arguments || []
              sf.arguments = arguments.map { |arg| Variable.from_grpc arg }
              locals = grpc.locals || []
              sf.locals = locals.map { |var| Variable.from_grpc var }
            end
          end
        end
      end
    end
  end
end
