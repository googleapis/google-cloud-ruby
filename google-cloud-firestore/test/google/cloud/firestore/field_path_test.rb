# Copyright (c) 2021 Motoyuki OHMORI.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require "helper"

describe Google::Cloud::Firestore::FieldPath do
  describe :quote_field_path do
    it "does not quote simple characters" do
      field_path = Google::Cloud::Firestore::FieldPath.new "bakt1k_"
      _(field_path.formatted_string).must_equal "bakt1k_"
    end

    it "does not quote a heading _ (underbar)" do
      field_path = Google::Cloud::Firestore::FieldPath.new "_baktik"
      _(field_path.formatted_string).must_equal "_baktik"
    end

    it "does not quote a heading upper case letter" do
      field_path = Google::Cloud::Firestore::FieldPath.new "Baktik"
      _(field_path.formatted_string).must_equal "Baktik"
    end

    it "quotes a heading number character" do
      field_path = Google::Cloud::Firestore::FieldPath.new "0baktik"
      _(field_path.formatted_string).must_equal "`0baktik`"
    end

    it "escapes a backquote and a backslash" do
      field_path = Google::Cloud::Firestore::FieldPath.new "bak`tik\\"
      _(field_path.formatted_string).must_equal "`bak\\`tik\\\\`"
    end

    it "quotes non-simple characters" do
      field_path = Google::Cloud::Firestore::FieldPath.new "bak-tik~"
      _(field_path.formatted_string).must_equal "`bak-tik~`"
    end
  end
end
