# Copyright 2020 Google LLC
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

def define_bucket_website_configuration bucket_name:, main_page_suffix:, not_found_page:
  # [START storage_define_bucket_website_configuration]
  # bucket_name = "your-bucket-name"
  # main_page_suffix = "index.html"
  # not_found_page = "404.html"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.update do |b|
    b.website_main = main_page_suffix
    b.website_404 = not_found_page
  end

  puts "Static website bucket #{bucket_name} is set up to use #{main_page_suffix} as the index page and " \
       "#{not_found_page} as the 404 page"
  # [END storage_define_bucket_website_configuration]
end

if $PROGRAM_NAME == __FILE__
  define_bucket_website_configuration bucket_name: ARGV.shift, main_page_suffix: ARGV.shift, not_found_page: ARGV.shift
end
