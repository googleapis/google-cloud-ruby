# Copyright 2018 Google LLC
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

module Google
  module Cloud
    module Language
      module V1beta2
        # ================================================================ #
        #
        # Represents the input to API methods.
        # @!attribute [rw] type
        #   @return [Google::Cloud::Language::V1beta2::Document::Type]
        #     Required. If the type is not set or is +TYPE_UNSPECIFIED+,
        #     returns an +INVALID_ARGUMENT+ error.
        # @!attribute [rw] content
        #   @return [String]
        #     The content of the input in string format.
        # @!attribute [rw] gcs_content_uri
        #   @return [String]
        #     The Google Cloud Storage URI where the file content is located.
        #     This URI must be of the form: gs://bucket_name/object_name. For more
        #     details, see https://cloud.google.com/storage/docs/reference-uris.
        #     NOTE: Cloud Storage object versioning is not supported.
        # @!attribute [rw] language
        #   @return [String]
        #     The language of the document (if not specified, the language is
        #     automatically detected). Both ISO and BCP-47 language codes are
        #     accepted.<br>
        #     [Language Support](https://cloud.google.com/natural-language/docs/languages)
        #     lists currently supported languages for each API method.
        #     If the language (either specified by the caller or automatically detected)
        #     is not supported by the called API method, an +INVALID_ARGUMENT+ error
        #     is returned.
        class Document
          # The document types enum.
          module Type
            # The content type is not specified.
            TYPE_UNSPECIFIED = 0

            # Plain text
            PLAIN_TEXT = 1

            # HTML
            HTML = 2
          end
        end

        # Represents a sentence in the input document.
        # @!attribute [rw] text
        #   @return [Google::Cloud::Language::V1beta2::TextSpan]
        #     The sentence text.
        # @!attribute [rw] sentiment
        #   @return [Google::Cloud::Language::V1beta2::Sentiment]
        #     For calls to {AnalyzeSentiment} or if
        #     {Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features#extract_document_sentiment AnnotateTextRequest::Features#extract_document_sentiment} is set to
        #     true, this field will contain the sentiment for the sentence.
        class Sentence; end

        # Represents a phrase in the text that is a known entity, such as
        # a person, an organization, or location. The API associates information, such
        # as salience and mentions, with entities.
        # @!attribute [rw] name
        #   @return [String]
        #     The representative name for the entity.
        # @!attribute [rw] type
        #   @return [Google::Cloud::Language::V1beta2::Entity::Type]
        #     The entity type.
        # @!attribute [rw] metadata
        #   @return [Hash{String => String}]
        #     Metadata associated with the entity.
        #
        #     Currently, Wikipedia URLs and Knowledge Graph MIDs are provided, if
        #     available. The associated keys are "wikipedia_url" and "mid", respectively.
        # @!attribute [rw] salience
        #   @return [Float]
        #     The salience score associated with the entity in the [0, 1.0] range.
        #
        #     The salience score for an entity provides information about the
        #     importance or centrality of that entity to the entire document text.
        #     Scores closer to 0 are less salient, while scores closer to 1.0 are highly
        #     salient.
        # @!attribute [rw] mentions
        #   @return [Array<Google::Cloud::Language::V1beta2::EntityMention>]
        #     The mentions of this entity in the input document. The API currently
        #     supports proper noun mentions.
        # @!attribute [rw] sentiment
        #   @return [Google::Cloud::Language::V1beta2::Sentiment]
        #     For calls to {AnalyzeEntitySentiment} or if
        #     {Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features#extract_entity_sentiment AnnotateTextRequest::Features#extract_entity_sentiment} is set to
        #     true, this field will contain the aggregate sentiment expressed for this
        #     entity in the provided document.
        class Entity
          # The type of the entity.
          module Type
            # Unknown
            UNKNOWN = 0

            # Person
            PERSON = 1

            # Location
            LOCATION = 2

            # Organization
            ORGANIZATION = 3

            # Event
            EVENT = 4

            # Work of art
            WORK_OF_ART = 5

            # Consumer goods
            CONSUMER_GOOD = 6

            # Other types
            OTHER = 7
          end
        end

        # Represents the smallest syntactic building block of the text.
        # @!attribute [rw] text
        #   @return [Google::Cloud::Language::V1beta2::TextSpan]
        #     The token text.
        # @!attribute [rw] part_of_speech
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech]
        #     Parts of speech tag for this token.
        # @!attribute [rw] dependency_edge
        #   @return [Google::Cloud::Language::V1beta2::DependencyEdge]
        #     Dependency tree parse for this token.
        # @!attribute [rw] lemma
        #   @return [String]
        #     [Lemma](https://en.wikipedia.org/wiki/Lemma_%28morphology%29) of the token.
        class Token; end

        # Represents the feeling associated with the entire text or entities in
        # the text.
        # @!attribute [rw] magnitude
        #   @return [Float]
        #     A non-negative number in the [0, +inf) range, which represents
        #     the absolute magnitude of sentiment regardless of score (positive or
        #     negative).
        # @!attribute [rw] score
        #   @return [Float]
        #     Sentiment score between -1.0 (negative sentiment) and 1.0
        #     (positive sentiment).
        class Sentiment; end

        # Represents part of speech information for a token.
        # @!attribute [rw] tag
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Tag]
        #     The part of speech tag.
        # @!attribute [rw] aspect
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Aspect]
        #     The grammatical aspect.
        # @!attribute [rw] case
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Case]
        #     The grammatical case.
        # @!attribute [rw] form
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Form]
        #     The grammatical form.
        # @!attribute [rw] gender
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Gender]
        #     The grammatical gender.
        # @!attribute [rw] mood
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Mood]
        #     The grammatical mood.
        # @!attribute [rw] number
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Number]
        #     The grammatical number.
        # @!attribute [rw] person
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Person]
        #     The grammatical person.
        # @!attribute [rw] proper
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Proper]
        #     The grammatical properness.
        # @!attribute [rw] reciprocity
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Reciprocity]
        #     The grammatical reciprocity.
        # @!attribute [rw] tense
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Tense]
        #     The grammatical tense.
        # @!attribute [rw] voice
        #   @return [Google::Cloud::Language::V1beta2::PartOfSpeech::Voice]
        #     The grammatical voice.
        class PartOfSpeech
          # The part of speech tags enum.
          module Tag
            # Unknown
            UNKNOWN = 0

            # Adjective
            ADJ = 1

            # Adposition (preposition and postposition)
            ADP = 2

            # Adverb
            ADV = 3

            # Conjunction
            CONJ = 4

            # Determiner
            DET = 5

            # Noun (common and proper)
            NOUN = 6

            # Cardinal number
            NUM = 7

            # Pronoun
            PRON = 8

            # Particle or other function word
            PRT = 9

            # Punctuation
            PUNCT = 10

            # Verb (all tenses and modes)
            VERB = 11

            # Other: foreign words, typos, abbreviations
            X = 12

            # Affix
            AFFIX = 13
          end

          # The characteristic of a verb that expresses time flow during an event.
          module Aspect
            # Aspect is not applicable in the analyzed language or is not predicted.
            ASPECT_UNKNOWN = 0

            # Perfective
            PERFECTIVE = 1

            # Imperfective
            IMPERFECTIVE = 2

            # Progressive
            PROGRESSIVE = 3
          end

          # The grammatical function performed by a noun or pronoun in a phrase,
          # clause, or sentence. In some languages, other parts of speech, such as
          # adjective and determiner, take case inflection in agreement with the noun.
          module Case
            # Case is not applicable in the analyzed language or is not predicted.
            CASE_UNKNOWN = 0

            # Accusative
            ACCUSATIVE = 1

            # Adverbial
            ADVERBIAL = 2

            # Complementive
            COMPLEMENTIVE = 3

            # Dative
            DATIVE = 4

            # Genitive
            GENITIVE = 5

            # Instrumental
            INSTRUMENTAL = 6

            # Locative
            LOCATIVE = 7

            # Nominative
            NOMINATIVE = 8

            # Oblique
            OBLIQUE = 9

            # Partitive
            PARTITIVE = 10

            # Prepositional
            PREPOSITIONAL = 11

            # Reflexive
            REFLEXIVE_CASE = 12

            # Relative
            RELATIVE_CASE = 13

            # Vocative
            VOCATIVE = 14
          end

          # Depending on the language, Form can be categorizing different forms of
          # verbs, adjectives, adverbs, etc. For example, categorizing inflected
          # endings of verbs and adjectives or distinguishing between short and long
          # forms of adjectives and participles
          module Form
            # Form is not applicable in the analyzed language or is not predicted.
            FORM_UNKNOWN = 0

            # Adnomial
            ADNOMIAL = 1

            # Auxiliary
            AUXILIARY = 2

            # Complementizer
            COMPLEMENTIZER = 3

            # Final ending
            FINAL_ENDING = 4

            # Gerund
            GERUND = 5

            # Realis
            REALIS = 6

            # Irrealis
            IRREALIS = 7

            # Short form
            SHORT = 8

            # Long form
            LONG = 9

            # Order form
            ORDER = 10

            # Specific form
            SPECIFIC = 11
          end

          # Gender classes of nouns reflected in the behaviour of associated words.
          module Gender
            # Gender is not applicable in the analyzed language or is not predicted.
            GENDER_UNKNOWN = 0

            # Feminine
            FEMININE = 1

            # Masculine
            MASCULINE = 2

            # Neuter
            NEUTER = 3
          end

          # The grammatical feature of verbs, used for showing modality and attitude.
          module Mood
            # Mood is not applicable in the analyzed language or is not predicted.
            MOOD_UNKNOWN = 0

            # Conditional
            CONDITIONAL_MOOD = 1

            # Imperative
            IMPERATIVE = 2

            # Indicative
            INDICATIVE = 3

            # Interrogative
            INTERROGATIVE = 4

            # Jussive
            JUSSIVE = 5

            # Subjunctive
            SUBJUNCTIVE = 6
          end

          # Count distinctions.
          module Number
            # Number is not applicable in the analyzed language or is not predicted.
            NUMBER_UNKNOWN = 0

            # Singular
            SINGULAR = 1

            # Plural
            PLURAL = 2

            # Dual
            DUAL = 3
          end

          # The distinction between the speaker, second person, third person, etc.
          module Person
            # Person is not applicable in the analyzed language or is not predicted.
            PERSON_UNKNOWN = 0

            # First
            FIRST = 1

            # Second
            SECOND = 2

            # Third
            THIRD = 3

            # Reflexive
            REFLEXIVE_PERSON = 4
          end

          # This category shows if the token is part of a proper name.
          module Proper
            # Proper is not applicable in the analyzed language or is not predicted.
            PROPER_UNKNOWN = 0

            # Proper
            PROPER = 1

            # Not proper
            NOT_PROPER = 2
          end

          # Reciprocal features of a pronoun.
          module Reciprocity
            # Reciprocity is not applicable in the analyzed language or is not
            # predicted.
            RECIPROCITY_UNKNOWN = 0

            # Reciprocal
            RECIPROCAL = 1

            # Non-reciprocal
            NON_RECIPROCAL = 2
          end

          # Time reference.
          module Tense
            # Tense is not applicable in the analyzed language or is not predicted.
            TENSE_UNKNOWN = 0

            # Conditional
            CONDITIONAL_TENSE = 1

            # Future
            FUTURE = 2

            # Past
            PAST = 3

            # Present
            PRESENT = 4

            # Imperfect
            IMPERFECT = 5

            # Pluperfect
            PLUPERFECT = 6
          end

          # The relationship between the action that a verb expresses and the
          # participants identified by its arguments.
          module Voice
            # Voice is not applicable in the analyzed language or is not predicted.
            VOICE_UNKNOWN = 0

            # Active
            ACTIVE = 1

            # Causative
            CAUSATIVE = 2

            # Passive
            PASSIVE = 3
          end
        end

        # Represents dependency parse tree information for a token.
        # @!attribute [rw] head_token_index
        #   @return [Integer]
        #     Represents the head of this token in the dependency tree.
        #     This is the index of the token which has an arc going to this token.
        #     The index is the position of the token in the array of tokens returned
        #     by the API method. If this token is a root token, then the
        #     +head_token_index+ is its own index.
        # @!attribute [rw] label
        #   @return [Google::Cloud::Language::V1beta2::DependencyEdge::Label]
        #     The parse label for the token.
        class DependencyEdge
          # The parse label enum for the token.
          module Label
            # Unknown
            UNKNOWN = 0

            # Abbreviation modifier
            ABBREV = 1

            # Adjectival complement
            ACOMP = 2

            # Adverbial clause modifier
            ADVCL = 3

            # Adverbial modifier
            ADVMOD = 4

            # Adjectival modifier of an NP
            AMOD = 5

            # Appositional modifier of an NP
            APPOS = 6

            # Attribute dependent of a copular verb
            ATTR = 7

            # Auxiliary (non-main) verb
            AUX = 8

            # Passive auxiliary
            AUXPASS = 9

            # Coordinating conjunction
            CC = 10

            # Clausal complement of a verb or adjective
            CCOMP = 11

            # Conjunct
            CONJ = 12

            # Clausal subject
            CSUBJ = 13

            # Clausal passive subject
            CSUBJPASS = 14

            # Dependency (unable to determine)
            DEP = 15

            # Determiner
            DET = 16

            # Discourse
            DISCOURSE = 17

            # Direct object
            DOBJ = 18

            # Expletive
            EXPL = 19

            # Goes with (part of a word in a text not well edited)
            GOESWITH = 20

            # Indirect object
            IOBJ = 21

            # Marker (word introducing a subordinate clause)
            MARK = 22

            # Multi-word expression
            MWE = 23

            # Multi-word verbal expression
            MWV = 24

            # Negation modifier
            NEG = 25

            # Noun compound modifier
            NN = 26

            # Noun phrase used as an adverbial modifier
            NPADVMOD = 27

            # Nominal subject
            NSUBJ = 28

            # Passive nominal subject
            NSUBJPASS = 29

            # Numeric modifier of a noun
            NUM = 30

            # Element of compound number
            NUMBER = 31

            # Punctuation mark
            P = 32

            # Parataxis relation
            PARATAXIS = 33

            # Participial modifier
            PARTMOD = 34

            # The complement of a preposition is a clause
            PCOMP = 35

            # Object of a preposition
            POBJ = 36

            # Possession modifier
            POSS = 37

            # Postverbal negative particle
            POSTNEG = 38

            # Predicate complement
            PRECOMP = 39

            # Preconjunt
            PRECONJ = 40

            # Predeterminer
            PREDET = 41

            # Prefix
            PREF = 42

            # Prepositional modifier
            PREP = 43

            # The relationship between a verb and verbal morpheme
            PRONL = 44

            # Particle
            PRT = 45

            # Associative or possessive marker
            PS = 46

            # Quantifier phrase modifier
            QUANTMOD = 47

            # Relative clause modifier
            RCMOD = 48

            # Complementizer in relative clause
            RCMODREL = 49

            # Ellipsis without a preceding predicate
            RDROP = 50

            # Referent
            REF = 51

            # Remnant
            REMNANT = 52

            # Reparandum
            REPARANDUM = 53

            # Root
            ROOT = 54

            # Suffix specifying a unit of number
            SNUM = 55

            # Suffix
            SUFF = 56

            # Temporal modifier
            TMOD = 57

            # Topic marker
            TOPIC = 58

            # Clause headed by an infinite form of the verb that modifies a noun
            VMOD = 59

            # Vocative
            VOCATIVE = 60

            # Open clausal complement
            XCOMP = 61

            # Name suffix
            SUFFIX = 62

            # Name title
            TITLE = 63

            # Adverbial phrase modifier
            ADVPHMOD = 64

            # Causative auxiliary
            AUXCAUS = 65

            # Helper auxiliary
            AUXVV = 66

            # Rentaishi (Prenominal modifier)
            DTMOD = 67

            # Foreign words
            FOREIGN = 68

            # Keyword
            KW = 69

            # List for chains of comparable items
            LIST = 70

            # Nominalized clause
            NOMC = 71

            # Nominalized clausal subject
            NOMCSUBJ = 72

            # Nominalized clausal passive
            NOMCSUBJPASS = 73

            # Compound of numeric modifier
            NUMC = 74

            # Copula
            COP = 75

            # Dislocated relation (for fronted/topicalized elements)
            DISLOCATED = 76

            # Aspect marker
            ASP = 77

            # Genitive modifier
            GMOD = 78

            # Genitive object
            GOBJ = 79

            # Infinitival modifier
            INFMOD = 80

            # Measure
            MES = 81

            # Nominal complement of a noun
            NCOMP = 82
          end
        end

        # Represents a mention for an entity in the text. Currently, proper noun
        # mentions are supported.
        # @!attribute [rw] text
        #   @return [Google::Cloud::Language::V1beta2::TextSpan]
        #     The mention text.
        # @!attribute [rw] type
        #   @return [Google::Cloud::Language::V1beta2::EntityMention::Type]
        #     The type of the entity mention.
        # @!attribute [rw] sentiment
        #   @return [Google::Cloud::Language::V1beta2::Sentiment]
        #     For calls to {AnalyzeEntitySentiment} or if
        #     {Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features#extract_entity_sentiment AnnotateTextRequest::Features#extract_entity_sentiment} is set to
        #     true, this field will contain the sentiment expressed for this mention of
        #     the entity in the provided document.
        class EntityMention
          # The supported types of mentions.
          module Type
            # Unknown
            TYPE_UNKNOWN = 0

            # Proper name
            PROPER = 1

            # Common noun (or noun compound)
            COMMON = 2
          end
        end

        # Represents an output piece of text.
        # @!attribute [rw] content
        #   @return [String]
        #     The content of the output text.
        # @!attribute [rw] begin_offset
        #   @return [Integer]
        #     The API calculates the beginning offset of the content in the original
        #     document according to the {Google::Cloud::Language::V1beta2::EncodingType EncodingType} specified in the API request.
        class TextSpan; end

        # Represents a category returned from the text classifier.
        # @!attribute [rw] name
        #   @return [String]
        #     The name of the category representing the document.
        # @!attribute [rw] confidence
        #   @return [Float]
        #     The classifier's confidence of the category. Number represents how certain
        #     the classifier is that this category represents the given text.
        class ClassificationCategory; end

        # The sentiment analysis request message.
        # @!attribute [rw] document
        #   @return [Google::Cloud::Language::V1beta2::Document]
        #     Input document.
        # @!attribute [rw] encoding_type
        #   @return [Google::Cloud::Language::V1beta2::EncodingType]
        #     The encoding type used by the API to calculate sentence offsets for the
        #     sentence sentiment.
        class AnalyzeSentimentRequest; end

        # The sentiment analysis response message.
        # @!attribute [rw] document_sentiment
        #   @return [Google::Cloud::Language::V1beta2::Sentiment]
        #     The overall sentiment of the input document.
        # @!attribute [rw] language
        #   @return [String]
        #     The language of the text, which will be the same as the language specified
        #     in the request or, if not specified, the automatically-detected language.
        #     See {Google::Cloud::Language::V1beta2::Document#language Document#language} field for more details.
        # @!attribute [rw] sentences
        #   @return [Array<Google::Cloud::Language::V1beta2::Sentence>]
        #     The sentiment for all the sentences in the document.
        class AnalyzeSentimentResponse; end

        # The entity-level sentiment analysis request message.
        # @!attribute [rw] document
        #   @return [Google::Cloud::Language::V1beta2::Document]
        #     Input document.
        # @!attribute [rw] encoding_type
        #   @return [Google::Cloud::Language::V1beta2::EncodingType]
        #     The encoding type used by the API to calculate offsets.
        class AnalyzeEntitySentimentRequest; end

        # The entity-level sentiment analysis response message.
        # @!attribute [rw] entities
        #   @return [Array<Google::Cloud::Language::V1beta2::Entity>]
        #     The recognized entities in the input document with associated sentiments.
        # @!attribute [rw] language
        #   @return [String]
        #     The language of the text, which will be the same as the language specified
        #     in the request or, if not specified, the automatically-detected language.
        #     See {Google::Cloud::Language::V1beta2::Document#language Document#language} field for more details.
        class AnalyzeEntitySentimentResponse; end

        # The entity analysis request message.
        # @!attribute [rw] document
        #   @return [Google::Cloud::Language::V1beta2::Document]
        #     Input document.
        # @!attribute [rw] encoding_type
        #   @return [Google::Cloud::Language::V1beta2::EncodingType]
        #     The encoding type used by the API to calculate offsets.
        class AnalyzeEntitiesRequest; end

        # The entity analysis response message.
        # @!attribute [rw] entities
        #   @return [Array<Google::Cloud::Language::V1beta2::Entity>]
        #     The recognized entities in the input document.
        # @!attribute [rw] language
        #   @return [String]
        #     The language of the text, which will be the same as the language specified
        #     in the request or, if not specified, the automatically-detected language.
        #     See {Google::Cloud::Language::V1beta2::Document#language Document#language} field for more details.
        class AnalyzeEntitiesResponse; end

        # The syntax analysis request message.
        # @!attribute [rw] document
        #   @return [Google::Cloud::Language::V1beta2::Document]
        #     Input document.
        # @!attribute [rw] encoding_type
        #   @return [Google::Cloud::Language::V1beta2::EncodingType]
        #     The encoding type used by the API to calculate offsets.
        class AnalyzeSyntaxRequest; end

        # The syntax analysis response message.
        # @!attribute [rw] sentences
        #   @return [Array<Google::Cloud::Language::V1beta2::Sentence>]
        #     Sentences in the input document.
        # @!attribute [rw] tokens
        #   @return [Array<Google::Cloud::Language::V1beta2::Token>]
        #     Tokens, along with their syntactic information, in the input document.
        # @!attribute [rw] language
        #   @return [String]
        #     The language of the text, which will be the same as the language specified
        #     in the request or, if not specified, the automatically-detected language.
        #     See {Google::Cloud::Language::V1beta2::Document#language Document#language} field for more details.
        class AnalyzeSyntaxResponse; end

        # The document classification request message.
        # @!attribute [rw] document
        #   @return [Google::Cloud::Language::V1beta2::Document]
        #     Input document.
        class ClassifyTextRequest; end

        # The document classification response message.
        # @!attribute [rw] categories
        #   @return [Array<Google::Cloud::Language::V1beta2::ClassificationCategory>]
        #     Categories representing the input document.
        class ClassifyTextResponse; end

        # The request message for the text annotation API, which can perform multiple
        # analysis types (sentiment, entities, and syntax) in one call.
        # @!attribute [rw] document
        #   @return [Google::Cloud::Language::V1beta2::Document]
        #     Input document.
        # @!attribute [rw] features
        #   @return [Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features]
        #     The enabled features.
        # @!attribute [rw] encoding_type
        #   @return [Google::Cloud::Language::V1beta2::EncodingType]
        #     The encoding type used by the API to calculate offsets.
        class AnnotateTextRequest
          # All available features for sentiment, syntax, and semantic analysis.
          # Setting each one to true will enable that specific analysis for the input.
          # @!attribute [rw] extract_syntax
          #   @return [true, false]
          #     Extract syntax information.
          # @!attribute [rw] extract_entities
          #   @return [true, false]
          #     Extract entities.
          # @!attribute [rw] extract_document_sentiment
          #   @return [true, false]
          #     Extract document-level sentiment.
          # @!attribute [rw] extract_entity_sentiment
          #   @return [true, false]
          #     Extract entities and their associated sentiment.
          # @!attribute [rw] classify_text
          #   @return [true, false]
          #     Classify the full document into categories.
          class Features; end
        end

        # The text annotations response message.
        # @!attribute [rw] sentences
        #   @return [Array<Google::Cloud::Language::V1beta2::Sentence>]
        #     Sentences in the input document. Populated if the user enables
        #     {Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features#extract_syntax AnnotateTextRequest::Features#extract_syntax}.
        # @!attribute [rw] tokens
        #   @return [Array<Google::Cloud::Language::V1beta2::Token>]
        #     Tokens, along with their syntactic information, in the input document.
        #     Populated if the user enables
        #     {Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features#extract_syntax AnnotateTextRequest::Features#extract_syntax}.
        # @!attribute [rw] entities
        #   @return [Array<Google::Cloud::Language::V1beta2::Entity>]
        #     Entities, along with their semantic information, in the input document.
        #     Populated if the user enables
        #     {Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features#extract_entities AnnotateTextRequest::Features#extract_entities}.
        # @!attribute [rw] document_sentiment
        #   @return [Google::Cloud::Language::V1beta2::Sentiment]
        #     The overall sentiment for the document. Populated if the user enables
        #     {Google::Cloud::Language::V1beta2::AnnotateTextRequest::Features#extract_document_sentiment AnnotateTextRequest::Features#extract_document_sentiment}.
        # @!attribute [rw] language
        #   @return [String]
        #     The language of the text, which will be the same as the language specified
        #     in the request or, if not specified, the automatically-detected language.
        #     See {Google::Cloud::Language::V1beta2::Document#language Document#language} field for more details.
        # @!attribute [rw] categories
        #   @return [Array<Google::Cloud::Language::V1beta2::ClassificationCategory>]
        #     Categories identified in the input document.
        class AnnotateTextResponse; end

        # Represents the text encoding that the caller uses to process the output.
        # Providing an +EncodingType+ is recommended because the API provides the
        # beginning offsets for various outputs, such as tokens and mentions, and
        # languages that natively use different text encodings may access offsets
        # differently.
        module EncodingType
          # If +EncodingType+ is not specified, encoding-dependent information (such as
          # +begin_offset+) will be set at +-1+.
          NONE = 0

          # Encoding-dependent information (such as +begin_offset+) is calculated based
          # on the UTF-8 encoding of the input. C++ and Go are examples of languages
          # that use this encoding natively.
          UTF8 = 1

          # Encoding-dependent information (such as +begin_offset+) is calculated based
          # on the UTF-16 encoding of the input. Java and Javascript are examples of
          # languages that use this encoding natively.
          UTF16 = 2

          # Encoding-dependent information (such as +begin_offset+) is calculated based
          # on the UTF-32 encoding of the input. Python is an example of a language
          # that uses this encoding natively.
          UTF32 = 3
        end
      end
    end
  end
end