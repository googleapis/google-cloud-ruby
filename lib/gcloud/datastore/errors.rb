# Copyright 2014 Google Inc. All rights reserved.
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


require "gcloud/errors"

module Gcloud
  module Datastore
    ##
    # # KeyError
    #
    # Raised when a key is not correct.
    class KeyError < Gcloud::Error
    end

    ##
    # # PropertyError
    #
    # Raised when a property is not correct.
    class PropertyError < Gcloud::Error
    end

    ##
    # # TransactionError
    #
    # General error for Transaction problems.
    class TransactionError < Gcloud::Error
    end
  end
end
