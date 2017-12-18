# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
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
        # # Text
        #
        # The results from either the `TEXT_DETECTION` feature (OCR for shorter
        # documents with sparse text) or the `DOCUMENT_TEXT_DETECTION` feature
        # (OCR for longer documents with dense text). Optional. Contains
        # structured representations of OCR extracted text, as well as
        # the entire UTF-8 text as a string.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/text.png"
        #
        #   text = image.text
        #
        #   text.text
        #   # "Google Cloud Client for Ruby an idiomatic, intuitive... "
        #
        #   text.words[0].text #=> "Google"
        #   text.words[0].bounds.count #=> 4
        #   vertex = text.words[0].bounds.first
        #   vertex.x #=> 13
        #   vertex.y #=> 8
        #
        #   # Use `pages` to access a full structural representation
        #   text.pages[0].blocks[0].paragraphs[0].words[0].symbols[0].text
        #   #=> "G"
        #
        class Text
          ##
          # @private The EntityAnnotation GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new Text instance.
          def initialize
            @grpc = nil
            @words = []
          end

          ##
          # The text detected in an image.
          #
          # @return [String] The entire text including newline characters.
          #
          def text
            @grpc.description
          end

          ##
          # The language code detected for `text`.
          #
          # @return [String] The [ISO
          #   639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
          #   language code.
          #
          def locale
            @grpc.locale
          end

          ##
          # The bounds for the detected text in the image.
          #
          # @return [Array<Vertex>]
          #
          def bounds
            return [] unless @grpc.bounding_poly
            @bounds ||= Array(@grpc.bounding_poly.vertices).map do |v|
              Vertex.from_grpc v
            end
          end

          ##
          # Each word in the detected text, with the bounds for each word.
          #
          # @return [Array<Word>]
          #
          def words
            @words
          end

          ##
          # Each page in the detected text, with the metadata for each page.
          # Contains a structured representation of OCR extracted text.
          # The hierarchy of an OCR extracted text structure is like this:
          #   Page -> Block -> Paragraph -> Word -> Symbol
          # Each structural component, starting from Page, may further have its
          # own properties. Properties describe detected languages, breaks etc..
          #
          # @return [Array<Page>]
          #
          def pages
            @pages
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            { text: text, locale: locale, bounds: bounds.map(&:to_h),
              words: words.map(&:to_h), pages: pages.map(&:to_h) }
          end

          # @private
          def to_s
            to_str
          end

          # @private
          def to_str
            text
          end

          # @private
          def inspect
            format "#<Text text: %s, locale: %s, bounds: %i, words: %i," \
                   " pages: %i>", text.inspect, locale.inspect, bounds.count,
                   words.count, pages.count
          end

          ##
          # @private Create a new Annotation::Text by merging two GRPC models of
          # text representation.
          def self.from_grpc grpc_text_annotations, grpc_full_text_annotation
            text, *words = Array grpc_text_annotations
            return nil if text.nil?

            # Since text is taken from grpc_text_annotations, do not use text
            # from grpc_full_text_annotation in this merged model.
            # Instead, just take the pages.
            pages = grpc_full_text_annotation.pages
            new.tap do |t|
              t.instance_variable_set :@grpc, text
              t.instance_variable_set :@words,
                                      words.map { |w| Word.from_grpc w }
              t.instance_variable_set :@pages,
                                      pages.map { |p| Page.from_grpc p }
            end
          end

          ##
          # # Word
          #
          # A word within a detected text (OCR). See {Text#words}.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/text.png"
          #   text = image.text
          #
          #   words = text.words
          #   words.count #=> 28
          #
          #   word = words.first
          #   word.text #=> "Google"
          #   word.bounds.count #=> 4
          #   vertex = word.bounds.first
          #   vertex.x #=> 13
          #   vertex.y #=> 8
          #
          class Word
            ##
            # @private The EntityAnnotation GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Word instance.
            def initialize
              @grpc = nil
            end

            ##
            # The text of the word.
            #
            # @return [String]
            #
            def text
              @grpc.description
            end

            ##
            # The bounds of the word within the detected text.
            #
            # @return [Array<Vertex>]
            #
            def bounds
              return [] unless @grpc.bounding_poly
              @bounds ||= Array(@grpc.bounding_poly.vertices).map do |v|
                Vertex.from_grpc v
              end
            end

            ##
            # Deeply converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { text: text, bounds: bounds.map(&:to_h) }
            end

            # @private
            def to_s
              to_str
            end

            # @private
            def to_str
              text
            end

            # @private
            def inspect
              format "#<Word text: %s, bounds: %i>", text.inspect, bounds.count
            end

            ##
            # @private New Annotation::Text::Word from a GRPC
            # object.
            def self.from_grpc grpc
              new.tap { |w| w.instance_variable_set :@grpc, grpc }
            end
          end

          ##
          # # Page
          #
          # A page within a detected text (OCR). See {Text#pages}.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/text.png"
          #
          #   text = image.text
          #
          #   page = text.pages.first
          #
          #   page.languages.first.code #=> "en"
          #   page.wont_be :prefix_break?
          #   page.width #=> 400
          #   page.height #=> 80
          #   page.blocks.count #=> 1
          #
          class Page
            ##
            # @private The EntityAnnotation GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Page instance.
            def initialize
              @grpc = nil
            end

            ##
            # A list of detected languages together with confidence.
            #
            # @return [Array<Language>]
            #
            def languages
              return [] if @grpc.property.nil?
              @languages ||= Array(@grpc.property.detected_languages).map do |l|
                Language.from_grpc l
              end
            end

            ##
            # The type of a detected break at the start or end of the page.
            #
            # @return [::Symbol]
            #
            def break_type
              return nil if @grpc.property.nil?
              @grpc.property.detected_break &&
                @grpc.property.detected_break.type.to_sym
            end

            ##
            # True if a detected break prepends the page.
            #
            # @return [Boolean]
            #
            def prefix_break?
              return nil if @grpc.property.nil?
              @grpc.property.detected_break &&
                @grpc.property.detected_break.is_prefix
            end

            ##
            # Page width in pixels.
            #
            # @return [Integer]
            #
            def width
              @grpc.width
            end

            ##
            # Page height in pixels.
            #
            # @return [Integer]
            #
            def height
              @grpc.height
            end

            ##
            # List of blocks of text, images etc on this page.
            #
            # @return [Array<Block>]
            #
            def blocks
              @blocks ||= Array(@grpc.blocks).map do |b|
                Block.from_grpc b
              end
            end

            ##
            # Deeply converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { languages: languages.map(&:to_h), break_type: break_type,
                prefix_break: prefix_break?, width: width, height: height,
                blocks: blocks.map(&:to_h) }
            end

            # @private
            def to_s
              tmplt = "languages: %s, break_type: %s, prefix_break: %s," \
                      " width: %s, height: %s, blocks: %i"
              format tmplt, languages.inspect, break_type, prefix_break?, width,
                     height, blocks.count
            end

            # @private
            def inspect
              "#<#{self.class.name} #{self}>"
            end

            ##
            # @private New Annotation::Text::Page from a GRPC
            # object.
            def self.from_grpc grpc
              new.tap { |w| w.instance_variable_set :@grpc, grpc }
            end

            ##
            # # Block
            #
            # A logical element on the page. See {Page}.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/text.png"
            #   text = image.text
            #
            #   block = text.pages[0].blocks.first
            #
            #   block.languages.first.code #=> "en"
            #   block.bounds.count #=> 4
            #   block.paragraphs.count #=> 1
            #
            class Block
              ##
              # @private The EntityAnnotation GRPC object.
              attr_accessor :grpc

              ##
              # @private Creates a new Block instance.
              def initialize
                @grpc = nil
              end

              ##
              # A list of detected languages together with confidence.
              #
              # @return [Array<Language>]
              #
              def languages
                return [] if @grpc.property.nil?
                detected_languages = @grpc.property.detected_languages
                @languages ||= Array(detected_languages).map do |l|
                  Language.from_grpc l
                end
              end

              ##
              # The type of a detected break at the start or end of the page.
              #
              # @return [::Symbol]
              #
              def break_type
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.type.to_sym
              end

              ##
              # True if a detected break prepends the page.
              #
              # @return [Boolean]
              #
              def prefix_break?
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.is_prefix
              end

              ##
              # The bounding box for the block.
              # The vertices are in the order of top-left, top-right,
              # bottom-right, bottom-left. When a rotation of the bounding box
              # is detected the rotation is represented as around the top-left
              # corner as defined when the text is read in the 'natural'
              # orientation.
              # For example:
              #   * when the text is horizontal it might look like:
              #      0----1
              #      |    |
              #      3----2
              #   * when rotated 180 degrees around the top-left corner it
              #     becomes:
              #      2----3
              #      |    |
              #      1----0
              #   and the vertice order will still be (0, 1, 2, 3).
              #
              # @return [Array<Vertex>]
              #
              def bounds
                return [] unless @grpc.bounding_box
                @bounds ||= Array(@grpc.bounding_box.vertices).map do |v|
                  Vertex.from_grpc v
                end
              end

              ##
              # List of paragraphs in this block (if this block is of type
              # text).
              #
              # @return [Array<Paragraph>]
              #
              def paragraphs
                @paragraphs ||= Array(@grpc.paragraphs).map do |b|
                  Paragraph.from_grpc b
                end
              end

              ##
              # Detected block type (text, image etc) for the block.
              #
              # @return [::Symbol]
              #
              def block_type
                @grpc.block_type.to_sym
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { languages: languages.map(&:to_h), break_type: break_type,
                  prefix_break: prefix_break?, bounds: bounds.map(&:to_h),
                  paragraphs: paragraphs.map(&:to_h), block_type: block_type }
              end

              # @private
              def to_s
                tmplt = "languages: %s, break_type: %s, prefix_break: %s," \
                        " bounds: %i, paragraphs: %i, block_type: %s"
                format tmplt, languages.inspect, break_type, prefix_break?,
                       bounds.count, paragraphs.count, block_type
              end

              # @private
              def inspect
                "#<#{self.class.name} #{self}>"
              end

              ##
              # @private New Annotation::Text::Page::Block from a GRPC
              # object.
              def self.from_grpc grpc
                new.tap { |w| w.instance_variable_set :@grpc, grpc }
              end
            end

            ##
            # # Paragraph
            #
            # Structural unit of text representing a number of words in certain
            # order. See {Block}.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/text.png"
            #   text = image.text
            #
            #   paragraph = text.pages[0].blocks[0].paragraphs.first
            #
            #   paragraph.languages.first.code #=> "en"
            #   paragraph.bounds.count #=> 4
            #   paragraph.words.count #=> 10
            #
            class Paragraph
              ##
              # @private The EntityAnnotation GRPC object.
              attr_accessor :grpc

              ##
              # @private Creates a new Paragraph instance.
              def initialize
                @grpc = nil
              end

              ##
              # A list of detected languages together with confidence.
              #
              # @return [Array<Language>]
              #
              def languages
                return [] if @grpc.property.nil?
                detected_languages = @grpc.property.detected_languages
                @languages ||= Array(detected_languages).map do |l|
                  Language.from_grpc l
                end
              end

              ##
              # The type of a detected break at the start or end of the page.
              #
              # @return [::Symbol]
              #
              def break_type
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.type.to_sym
              end

              ##
              # True if a detected break prepends the page.
              #
              # @return [Boolean]
              #
              def prefix_break?
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.is_prefix
              end

              ##
              # The bounding box for the paragraph.
              # The vertices are in the order of top-left, top-right,
              # bottom-right, bottom-left. When a rotation of the bounding box
              # is detected the rotation is represented as around the top-left
              # corner as defined when the text is read in the 'natural'
              # orientation.
              # For example:
              #   * when the text is horizontal it might look like:
              #      0----1
              #      |    |
              #      3----2
              #   * when rotated 180 degrees around the top-left corner it
              #     becomes:
              #      2----3
              #      |    |
              #      1----0
              #   and the vertice order will still be (0, 1, 2, 3).
              #
              # @return [Array<Vertex>]
              #
              def bounds
                return [] unless @grpc.bounding_box
                @bounds ||= Array(@grpc.bounding_box.vertices).map do |v|
                  Vertex.from_grpc v
                end
              end

              ##
              # List of words in this paragraph.
              #
              # @return [Array<Word>]
              #
              def words
                @words ||= Array(@grpc.words).map do |b|
                  Word.from_grpc b
                end
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { languages: languages.map(&:to_h), break_type: break_type,
                  prefix_break: prefix_break?, bounds: bounds.map(&:to_h),
                  words: words.map(&:to_h) }
              end

              # @private
              def to_s
                tmplt = "languages: %s, break_type: %s, prefix_break: %s," \
                        " bounds: %i, words: %i"
                format tmplt, languages.inspect, break_type, prefix_break?,
                       bounds.count, words.count
              end

              # @private
              def inspect
                "#<#{self.class.name} #{self}>"
              end

              ##
              # @private New Annotation::Text::Page::Paragraph from a GRPC
              # object.
              def self.from_grpc grpc
                new.tap { |w| w.instance_variable_set :@grpc, grpc }
              end
            end

            ##
            # # Word
            #
            # A word representation. See {Paragraph}.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/text.png"
            #   text = image.text
            #
            #   word = text.pages[0].blocks[0].paragraphs[0].words.first
            #
            #   word.languages.first.code #=> "en"
            #   word.bounds.count #=> 4
            #   word.symbols.count #=> 6
            #
            class Word
              ##
              # @private The EntityAnnotation GRPC object.
              attr_accessor :grpc

              ##
              # @private Creates a new Word instance.
              def initialize
                @grpc = nil
              end

              ##
              # A list of detected languages together with confidence.
              #
              # @return [Array<Language>]
              #
              def languages
                return [] if @grpc.property.nil?
                detected_languages = @grpc.property.detected_languages
                @languages ||= Array(detected_languages).map do |l|
                  Language.from_grpc l
                end
              end

              ##
              # The type of a detected break at the start or end of the page.
              #
              # @return [::Symbol]
              #
              def break_type
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.type.to_sym
              end

              ##
              # True if a detected break prepends the page.
              #
              # @return [Boolean]
              #
              def prefix_break?
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.is_prefix
              end

              ##
              # The bounding box for the word.
              # The vertices are in the order of top-left, top-right,
              # bottom-right, bottom-left. When a rotation of the bounding box
              # is detected the rotation is represented as around the top-left
              # corner as defined when the text is read in the 'natural'
              # orientation.
              # For example:
              #   * when the text is horizontal it might look like:
              #      0----1
              #      |    |
              #      3----2
              #   * when rotated 180 degrees around the top-left corner it
              #     becomes:
              #      2----3
              #      |    |
              #      1----0
              #   and the vertice order will still be (0, 1, 2, 3).
              #
              # @return [Array<Vertex>]
              #
              def bounds
                return [] unless @grpc.bounding_box
                @bounds ||= Array(@grpc.bounding_box.vertices).map do |v|
                  Vertex.from_grpc v
                end
              end

              ##
              # List of symbols in the word. The order of the symbols follows
              # the natural reading order.
              #
              # @return [Array<Symbol>]
              #
              def symbols
                @symbols ||= Array(@grpc.symbols).map do |b|
                  Symbol.from_grpc b
                end
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { languages: languages.map(&:to_h), break_type: break_type,
                  prefix_break: prefix_break?, bounds: bounds.map(&:to_h),
                  symbols: symbols.map(&:to_h) }
              end

              # @private
              def to_s
                tmplt = "languages: %s, break_type: %s, prefix_break: %s," \
                        " bounds: %i, symbols: %i"
                format tmplt, languages.inspect, break_type, prefix_break?,
                       bounds.count, symbols.count
              end

              # @private
              def inspect
                "#<#{self.class.name} #{self}>"
              end

              ##
              # @private New Annotation::Text::Page::Word from a GRPC
              # object.
              def self.from_grpc grpc
                new.tap { |w| w.instance_variable_set :@grpc, grpc }
              end
            end

            ##
            # # Symbol
            #
            # A word representation. See {Paragraph}.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/text.png"
            #   text = image.text
            #   page = text.pages.first
            #
            #   symbol = page.blocks[0].paragraphs[0].words[0].symbols[0]
            #
            #   symbol.languages.first.code #=> "en"
            #   symbol.bounds.count #=> 4
            #   symbol.text #=> "G"
            #
            class Symbol
              ##
              # @private The EntityAnnotation GRPC object.
              attr_accessor :grpc

              ##
              # @private Creates a new Symbol instance.
              def initialize
                @grpc = nil
              end

              ##
              # A list of detected languages together with confidence.
              #
              # @return [Array<Language>]
              #
              def languages
                return [] if @grpc.property.nil?
                detected_languages = @grpc.property.detected_languages
                @languages ||= Array(detected_languages).map do |l|
                  Language.from_grpc l
                end
              end

              ##
              # The type of a detected break at the start or end of the page.
              #
              # @return [::Symbol]
              #
              def break_type
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.type.to_sym
              end

              ##
              # True if a detected break prepends the page.
              #
              # @return [Boolean]
              #
              def prefix_break?
                return nil if @grpc.property.nil?
                @grpc.property.detected_break &&
                  @grpc.property.detected_break.is_prefix
              end

              ##
              # The bounding box for the symbol.
              # The vertices are in the order of top-left, top-right,
              # bottom-right, bottom-left. When a rotation of the bounding box
              # is detected the rotation is represented as around the top-left
              # corner as defined when the text is read in the 'natural'
              # orientation.
              # For example:
              #   * when the text is horizontal it might look like:
              #      0----1
              #      |    |
              #      3----2
              #   * when rotated 180 degrees around the top-left corner it
              #     becomes:
              #      2----3
              #      |    |
              #      1----0
              #   and the vertice order will still be (0, 1, 2, 3).
              #
              # @return [Array<Vertex>]
              #
              def bounds
                return [] unless @grpc.bounding_box
                @bounds ||= Array(@grpc.bounding_box.vertices).map do |v|
                  Vertex.from_grpc v
                end
              end

              ##
              # The actual UTF-8 representation of the symbol.
              #
              # @return [String]
              #
              def text
                @grpc.text
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { languages: languages.map(&:to_h), break_type: break_type,
                  prefix_break: prefix_break?, bounds: bounds.map(&:to_h),
                  text: text }
              end

              # @private
              def to_s
                tmplt = "languages: %s, break_type: %s, prefix_break: %s," \
                        " bounds: %i, text: %s"
                format tmplt, languages.inspect, break_type, prefix_break?,
                       bounds.count, text
              end

              # @private
              def inspect
                "#<#{self.class.name} #{self}>"
              end

              ##
              # @private New Annotation::Text::Page::Symbol from a GRPC
              # object.
              def self.from_grpc grpc
                new.tap { |w| w.instance_variable_set :@grpc, grpc }
              end
            end

            ##
            # # Language
            #
            # A language within a detected text (OCR). See {Text#pages}.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/text.png"
            #   text = image.text
            #   page = text.pages.first
            #
            #   language = page.languages.first
            #   language.code #=> "en"
            #
            class Language
              ##
              # @private The EntityAnnotation GRPC object.
              attr_accessor :grpc

              ##
              # @private Creates a new Language instance.
              def initialize
                @grpc = nil
              end

              ##
              # The language code detected for a structural component.
              #
              # @return [String] The [ISO
              #   639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
              #   language code.
              #
              def code
                @grpc.language_code
              end

              ##
              # Confidence of detected language.
              #
              # @return [Float] A value in the range [0,1].
              #
              def confidence
                @grpc.confidence
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { code: code, confidence: confidence }
              end

              # @private
              def to_s
                format "code: %s, confidence: %s", code, confidence
              end

              # @private
              def inspect
                "#<#{self.class.name} #{self}>"
              end

              ##
              # @private New Annotation::Text::Page::Language from a GRPC
              # object.
              def self.from_grpc grpc
                new.tap { |w| w.instance_variable_set :@grpc, grpc }
              end
            end
          end
        end
      end
    end
  end
end
