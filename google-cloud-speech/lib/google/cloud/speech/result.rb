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


require "google/cloud/speech/v1beta1"

module Google
  module Cloud
    module Speech
      ##
      # # Result
      #
      class Result
        attr_reader :transcript, :confidence, :alternatives

        ##
        # @private Creates a new Results instance.
        def initialize transcript, confidence, alternatives = []
          @transcript  = transcript
          @confidence = confidence
          @alternatives = alternatives
        end

        ##
        # @private New Results from a SpeechRecognitionAlternative object.
        def self.from_grpc grpc
          head, *tail = *grpc.alternatives
          return nil if head.nil?
          alternatives = tail.map do |alt|
            new alt.transcript, alt.confidence
          end
          new head.transcript, head.confidence, alternatives
        end
      end
    end
  end
end
