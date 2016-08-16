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


require "google/cloud/errors"
require "google/cloud/core/gce"
require "google/cloud/language/service"
require "google/cloud/language/document"
require "google/cloud/language/annotation"

module Google
  module Cloud
    module Language
      ##
      # # Project
      #
      # ...
      #
      # See {Google::Cloud#language}
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   language = gcloud.language
      #
      #   # ...
      #
      class Project
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private Creates a new Language Project instance.
        def initialize service
          @service = service
        end

        # The Language project connected to.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new "my-project-id",
        #                              "/path/to/keyfile.json"
        #   language = gcloud.language
        #
        #   language.project #=> "my-project-id"
        #
        def project
          service.project
        end

        ##
        # @private Default project.
        def self.default_project
          ENV["LANGUAGE_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud::Core::GCE.project_id
        end

        ##
        # Returns a new document from the given content.
        #
        # TODO: Details
        #
        # @param [String, Google::Cloud::Storage::File] content A string of text
        #   to be annotated, or a Cloud Storage URI of the form
        #   `"gs://bucketname/path/to/document.ext"`; or an instance of
        #   Google::Cloud::Storage::File of the text to be annotated.
        #
        # @return [Document] An document for the Language service.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "it was the best of times, it was..."
        #
        # @example With a Google Cloud Storage URI:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "gs://bucket-name/path/to/document"
        #
        # @example With a Google Cloud Storage File object:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   storage = gcloud.storage
        #
        #   bucket = storage.bucket "bucket-name"
        #   file = bucket.file "path/to/document"
        #
        #   language = gcloud.language
        #
        #   doc = language.document file
        #
        def document content, format: nil, language: nil
          return content if content.is_a? Document
          Document.from_source content, @service, format: format,
                                                  language: language
        end
        alias_method :doc, :document

        def text content, language: nil
          document content, format: :text, language: language
        end

        def html content, language: nil
          document content, format: :html, language: language
        end

        ##
        # TODO: Details
        #
        # @param [String, Document, Google::Cloud::Storage::File] content The
        #   content to annotate. This can be an {Document} instance, or any
        #   other type that converts to an {Document}. See {#document} for
        #   details.
        # @param [Boolean] text Whether to perform the textual analysis.
        #   Optional.
        # @param [Boolean] entities Whether to perform the entitiy analysis.
        #   Optional.
        # @param [Boolean] sentiment Whether to perform the sentiment analysis.
        #   Optional.
        # @param [String] format The format of the document (TEXT/HTML).
        #   Optional.
        # @param [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation>] The results for the content analysis.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "Hello world!"
        #
        #   annotation = language.annotate doc
        #   annotation.thing #=> Some Result
        #
        def annotate content, text: false, entities: false, sentiment: false,
                     format: nil, language: nil, encoding: nil
          ensure_service!
          doc = document content, language: language, format: format
          grpc = service.annotate doc.to_grpc, text: text, entities: entities,
                                               sentiment: sentiment,
                                               encoding: encoding
          Annotation.from_grpc grpc
        end
        alias_method :mark, :annotate
        alias_method :detect, :annotate

        ##
        # TODO: Details
        #
        # @param [String, Document] content The content to annotate. This
        #   can be an {Document} instance, or any other type that converts to an
        #   {Document}. See {#document} for details.
        # @param [String] format The format of the document (TEXT/HTML).
        #   Optional.
        # @param [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation::Entities>] The results for the entities analysis.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "Hello Chris and Mike!"
        #
        #   entities = language.entities doc
        #   entities.count #=> 2
        #
        def entities content, format: :text, language: nil, encoding: nil
          ensure_service!
          doc = document content, language: language, format: format
          grpc = service.entities doc.to_grpc, encoding: encoding
          Annotation::Entities.from_grpc grpc
        end

        ##
        # TODO: Details
        #
        # @param [String, Document] content The content to annotate. This
        #   can be an {Document} instance, or any other type that converts to an
        #   {Document}. See {#document} for details.
        # @param [String] format The format of the document (TEXT/HTML).
        #   Optional.
        # @param [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Annotation::Sentiment>] The results for the sentiment
        #   analysis.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "Hello Chris and Mike!"
        #
        #   sentiment = language.sentiment doc
        #   sentiment.polarity #=> 1.0
        #   sentiment.magnitude #=> 0.8999999761581421
        #
        def sentiment content, format: :text, language: nil
          ensure_service!
          doc = document content, language: language, format: format
          grpc = service.sentiment doc.to_grpc
          Annotation::Sentiment.from_grpc grpc
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
