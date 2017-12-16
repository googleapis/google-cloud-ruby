# Copyright 2016 Google LLC
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


require "google/cloud/vision/annotation/vertex"

module Google
  module Cloud
    module Vision
      class Annotation
        ##
        # # Web
        #
        # Relevant information for the image from the Internet.
        #
        # See {Annotation#web}.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   web = image.web
        #
        #   entity = web.entities.first
        #   entity.entity_id #=> "/m/019dvv"
        #   entity.score #=> 107.34591674804688
        #   entity.description #=> "Mount Rushmore National Memorial"
        #
        #   full_matching_image = web.full_matching_images.first
        #   full_matching_image.url #=> "http://example.com/images/123.jpg"
        #   full_matching_image.score #=> 0.10226666927337646
        #
        #   page_with_matching_images = web.pages_with_matching_images.first
        #   page_with_matching_images.url #=> "http://example.com/posts/123"
        #   page_with_matching_images.score #=> 8.114753723144531
        #
        class Web
          ##
          # @private The WebDetection GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new Web instance.
          def initialize
            @grpc = nil
          end

          ##
          # Deduced entities from similar images on the Internet.
          #
          # @return [Array<Google::Cloud::Vision::Annotation::Web::Entity>]
          #
          def entities
            @entities ||= Array(@grpc.web_entities).map do |e|
              Entity.from_grpc e
            end
          end

          ##
          # Fully matching images from the Internet. They're definite neardups
          # and most often a copy of the query image with merely a size change.
          #
          # @return [Array<Google::Cloud::Vision::Annotation::Web::Image>]
          #
          def full_matching_images
            images = @grpc.full_matching_images
            @full_matching_images ||= Array(images).map do |i|
              Image.from_grpc i
            end
          end

          ##
          # Partial matching images from the Internet. Those images are similar
          # enough to share some key-point features. For example an original
          # image will likely have partial matching for its crops.
          #
          # @return [Array<Google::Cloud::Vision::Annotation::Web::Image>]
          #
          def partial_matching_images
            images = @grpc.partial_matching_images
            @partial_matching_images ||= Array(images).map do |i|
              Image.from_grpc i
            end
          end

          ##
          # Web pages containing the matching images from the Internet.
          #
          # @return [Array<Google::Cloud::Vision::Annotation::Web::Page>]
          #
          def pages_with_matching_images
            pages = @grpc.pages_with_matching_images
            @pages_with_matching_images ||= Array(pages).map do |p|
              Page.from_grpc p
            end
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            {
              entities: entities.map(&:to_h),
              full_matching_images: full_matching_images.map(&:to_h),
              partial_matching_images: partial_matching_images.map(&:to_h),
              pages_with_matching_images: pages_with_matching_images.map(&:to_h)
            }
          end

          # @private
          def to_s
            # Keep console output low by not showing all sub-objects.
            format "(entities: %i, full_matching_images: %i," \
                   " partial_matching_images: %i," \
                   " pages_with_matching_images: %i)",
                   entities.count, full_matching_images.count,
                   partial_matching_images.count,
                   pages_with_matching_images.count
          end

          # @private
          def inspect
            "#<#{self.class.name} #{self}>"
          end

          ##
          # @private New Annotation::Face from a GRPC object.
          def self.from_grpc grpc
            new.tap { |f| f.instance_variable_set :@grpc, grpc }
          end

          ##
          # # Entity
          #
          # Entity deduced from similar images on the Internet.
          #
          # See {Web}.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/landmark.jpg"
          #
          #   web = image.web
          #
          #   entity = web.entities.first
          #   entity.entity_id #=> "/m/019dvv"
          #   entity.score #=> 107.34591674804688
          #   entity.description #=> "Mount Rushmore National Memorial"
          #
          class Entity
            ##
            # @private The WebEntity GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Entity instance.
            def initialize
              @grpc = nil
            end

            ##
            # Opaque entity ID.
            #
            # @return [String]
            #
            def entity_id
              @grpc.entity_id
            end

            ##
            # Overall relevancy score for the entity. Not normalized and not
            # comparable across different image queries.
            #
            # @return [Float]
            #
            def score
              @grpc.score
            end

            ##
            # Canonical description of the entity, in English.
            #
            # @return [String]
            #
            def description
              @grpc.description
            end

            ##
            # Returns the object's property values as an array.
            #
            # @return [Array]
            #
            def to_a
              [entity_id, score, description]
            end

            ##
            # Converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { entity_id: entity_id, score: score, description: description }
            end

            # @private
            def to_s
              format "(entity_id: %s, score: %s, description: %s)",
                     entity_id.inspect, score.inspect, description.inspect
            end

            # @private
            def inspect
              "#<Web::Entity #{self}>"
            end

            ##
            # @private New Google::Cloud::Vision::Annotation::Web::Entity from
            # a GRPC object.
            def self.from_grpc grpc
              new.tap { |f| f.instance_variable_set :@grpc, grpc }
            end
          end

          ##
          # # Image
          #
          # Metadata for online images.
          #
          # See {Web}.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/landmark.jpg"
          #
          #   web = image.web
          #
          #   full_matching_image = web.full_matching_images.first
          #   full_matching_image.url #=> "http://example.com/images/123.jpg"
          #   full_matching_image.score #=> 0.10226666927337646
          #
          class Image
            ##
            # @private The WebImage GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Image instance.
            def initialize
              @grpc = nil
            end

            ##
            # The result image URL.
            #
            # @return [String]
            #
            def url
              @grpc.url
            end

            ##
            # Overall relevancy score for the image. Not normalized and not
            # comparable across different image queries.
            #
            # @return [Float]
            #
            def score
              @grpc.score
            end

            ##
            # Returns the object's property values as an array.
            #
            # @return [Array]
            #
            def to_a
              [url, score]
            end

            ##
            # Converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { url: url, score: score }
            end

            # @private
            def to_s
              format "(url: %s, score: %s)", url.inspect, score.inspect
            end

            # @private
            def inspect
              "#<Web::Image #{self}>"
            end

            ##
            # @private New Google::Cloud::Vision::Annotation::Web::Image from
            # a GRPC object.
            def self.from_grpc grpc
              new.tap { |f| f.instance_variable_set :@grpc, grpc }
            end
          end

          ##
          # # Page
          #
          # Metadata for web pages.
          #
          # See {Web}.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/landmark.jpg"
          #
          #   web = image.web
          #
          #   page_with_matching_images = web.pages_with_matching_images.first
          #   page_with_matching_images.url #=> "http://example.com/posts/123"
          #   page_with_matching_images.score #=> 8.114753723144531
          #
          class Page
            ##
            # @private The WebPage GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Page instance.
            def initialize
              @grpc = nil
            end

            ##
            # The result web page URL.
            #
            # @return [String]
            #
            def url
              @grpc.url
            end

            ##
            # Overall relevancy score for the web page. Not normalized and not
            # comparable across different image queries.
            #
            # @return [Float]
            #
            def score
              @grpc.score
            end

            ##
            # Returns the object's property values as an array.
            #
            # @return [Array]
            #
            def to_a
              [url, score]
            end

            ##
            # Converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { url: url, score: score }
            end

            # @private
            def to_s
              format "(url: %s, score: %s)", url.inspect, score.inspect
            end

            # @private
            def inspect
              "#<Web::Page #{self}>"
            end

            ##
            # @private New Google::Cloud::Vision::Annotation::Web::Page from
            # a GRPC object.
            def self.from_grpc grpc
              new.tap { |f| f.instance_variable_set :@grpc, grpc }
            end
          end
        end
      end
    end
  end
end
