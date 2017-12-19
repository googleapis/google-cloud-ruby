# Copyright 2017, Google LLC All rights reserved.
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

module Google
  module Type
    # Represents a whole calendar date, e.g. date of birth. The time of day and
    # time zone are either specified elsewhere or are not significant. The date
    # is relative to the Proleptic Gregorian Calendar. The day may be 0 to
    # represent a year and month where the day is not significant, e.g. credit card
    # expiration date. The year may be 0 to represent a month and day independent
    # of year, e.g. anniversary date. Related types are {Google::Type::TimeOfDay}
    # and +google.protobuf.Timestamp+.
    # @!attribute [rw] year
    #   @return [Integer]
    #     Year of date. Must be from 1 to 9999, or 0 if specifying a date without
    #     a year.
    # @!attribute [rw] month
    #   @return [Integer]
    #     Month of year. Must be from 1 to 12.
    # @!attribute [rw] day
    #   @return [Integer]
    #     Day of month. Must be from 1 to 31 and valid for the year and month, or 0
    #     if specifying a year/month where the day is not significant.
    class Date; end
  end
end