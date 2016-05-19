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

require "helper"
require "gcloud/upload"

describe Gcloud::Upload do
  let(:minimum_chunk_size) { 256*1024 }

  it "sets the defaults properly" do
    Gcloud::Upload.resumable_threshold.must_equal 5000000
    Gcloud::Upload.default_chunk_size.must_equal  10485760
  end

  describe :default_chunk_size do
    before do
      @original_chunk_size = Gcloud::Upload.default_chunk_size
    end

    after do
      Gcloud::Upload.default_chunk_size = @original_chunk_size
    end

    it "can't set chunk_size to less than 256KB" do
      Gcloud::Upload.default_chunk_size = (256*1024)-1
      Gcloud::Upload.default_chunk_size.must_equal minimum_chunk_size
    end

    it "can set chunk_size to larger than 256KB" do
      Gcloud::Upload.default_chunk_size = (256*1024)+1
      Gcloud::Upload.default_chunk_size.must_equal minimum_chunk_size
    end

    it "can set chunk_size to 16MB" do
      Gcloud::Upload.default_chunk_size = (16*1024*1024)
      Gcloud::Upload.default_chunk_size.must_equal (16*1024*1024)
    end

    it "can verifies the chunk_size is a multiple of 256KB" do
      Gcloud::Upload.default_chunk_size = ((8*minimum_chunk_size) - minimum_chunk_size/2)
      Gcloud::Upload.default_chunk_size.must_equal (7*minimum_chunk_size)
    end
  end

  # This is the internal API
  describe :verify_chunk_size do
    describe "file size is less than default chunk size" do
      let(:file_size) { 6*minimum_chunk_size }

      it "gives the default chunk_size when given nil" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size nil, file_size
          my_chunk_size.must_be :nil?
        end
      end

      it "gives the default chunk_size when given 0" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size 0, file_size
          my_chunk_size.must_be :nil?
        end
      end

      it "verifies chunk_size less than 256KB" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size minimum_chunk_size-1, file_size
          my_chunk_size.must_equal minimum_chunk_size
        end
      end

      it "verifies chunk_size larger than 256KB" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size minimum_chunk_size+1, file_size
          my_chunk_size.must_equal minimum_chunk_size
        end
      end

      it "verifies chunk_size smaller than file size" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size 5*minimum_chunk_size, file_size
          my_chunk_size.must_equal 5*minimum_chunk_size
        end
      end

      it "verifies chunk_size larger than file size" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size 16*minimum_chunk_size, file_size
          my_chunk_size.must_be :nil?
        end
      end

      it "verifies the chunk_size is a multiple of 256KB" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size ((4*minimum_chunk_size) - minimum_chunk_size/2), file_size
          my_chunk_size.must_equal (3*minimum_chunk_size)
        end
      end
    end

    describe "file size is larger than default chunk size" do
      let(:file_size) { 10*minimum_chunk_size }

      it "gives the default chunk_size when given nil" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size nil, file_size
          my_chunk_size.must_equal Gcloud::Upload.default_chunk_size
        end
      end

      it "gives the default chunk_size when given 0" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size 0, file_size
          my_chunk_size.must_equal Gcloud::Upload.default_chunk_size
        end
      end

      it "verifies chunk_size less than 256KB" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size minimum_chunk_size-1, file_size
          my_chunk_size.must_equal minimum_chunk_size
        end
      end

      it "verifies chunk_size larger than 256KB" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size minimum_chunk_size+1, file_size
          my_chunk_size.must_equal minimum_chunk_size
        end
      end

      it "verifies chunk_size smaller than file size" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size 9*minimum_chunk_size, file_size
          my_chunk_size.must_equal 9*minimum_chunk_size
        end
      end

      it "verifies chunk_size larger than file size" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size 16*minimum_chunk_size, file_size
          my_chunk_size.must_be :nil?
        end
      end

      it "verifies the chunk_size is a multiple of 256KB" do
        Gcloud::Upload.stub :default_chunk_size, 8*minimum_chunk_size do
          my_chunk_size = Gcloud::Upload.verify_chunk_size ((4*minimum_chunk_size) - minimum_chunk_size/2), file_size
          my_chunk_size.must_equal (3*minimum_chunk_size)
        end
      end
    end
  end
end
