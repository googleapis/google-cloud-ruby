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

##
# This file is here to be autorequired by bundler, so that the .bigquery and
# #bigquery methods can be available, but the library and all dependencies won't
# be loaded until required and used.


gem "google-cloud-bigquery"
gem "google-cloud-datastore"
gem "google-cloud-dns"
gem "google-cloud-logging"
gem "google-cloud-pubsub"
gem "google-cloud-resource_manager"
gem "google-cloud-storage"
gem "google-cloud-translate"
gem "google-cloud-vision"

require "google-cloud-bigquery"
require "google-cloud-datastore"
require "google-cloud-dns"
require "google-cloud-logging"
require "google-cloud-pubsub"
require "google-cloud-resource_manager"
require "google-cloud-storage"
require "google-cloud-translate"
require "google-cloud-vision"
