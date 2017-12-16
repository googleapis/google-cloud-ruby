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

require "speech_helper"

describe "Streaming Recognition", :speech do
  let(:filepath) { "acceptance/data/audio.raw" }

  it "default params" do
    counters = Hash.new { |h, k| h[k] = 0 }

    stream = speech.stream encoding: :linear16, sample_rate: 16000, language: "en-US"

    stream.on_interim      { counters[:interim] += 1 }
    stream.on_result       { counters[:result] += 1 }
    stream.on_complete     { counters[:complete] += 1 }
    stream.on_utterance    { counters[:utterance] += 1 }
    stream.on_error do |error|
      puts "The following error occurred while streaming: #{error}"
    end

    stream.send File.read(filepath, mode: "rb")

    stream.stop

    stream.wait_until_complete!

    results = stream.results

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.9, 0.1
    results.first.alternatives.must_be :empty?

    counters[:interim].must_be :zero?
    counters[:result].must_equal 1
    counters[:complete].must_equal 1
    counters[:utterance].must_be :zero?
  end

  it "sends multiple times" do
    counters = Hash.new { |h, k| h[k] = 0 }

    stream = speech.stream encoding: :linear16, sample_rate: 16000, language: "en-US"

    stream.on_interim      { counters[:interim] += 1 }
    stream.on_result       { counters[:result] += 1 }
    stream.on_complete     { counters[:complete] += 1 }
    stream.on_utterance    { counters[:utterance] += 1 }
    stream.on_error do |error|
      puts "The following error occurred while streaming: #{error}"
    end
    stream.on_error do |error|
      puts "The following error occurred while streaming: #{error}"
    end

    file = File.open filepath, "rb"

    # simulate a live stream, by sending a second at a time
    until file.eof?
      stream.send file.read(32000) # about a seconds worth of data
      sleep 1
    end

    stream.stop

    stream.wait_until_complete!

    results = stream.results

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.9, 0.1
    results.first.alternatives.must_be :empty?

    counters[:interim].must_be :zero?
    counters[:result].must_equal 1
    counters[:complete].must_equal 1
    counters[:utterance].must_be :zero?
  end

  describe "interim" do
    it "default params" do
      counters = Hash.new { |h, k| h[k] = 0 }

      stream = speech.stream encoding: :linear16, sample_rate: 16000, language: "en-US", interim: true

      stream.on_interim      { counters[:interim] += 1 }
      stream.on_result       { counters[:result] += 1 }
      stream.on_complete     { counters[:complete] += 1 }
      stream.on_utterance    { counters[:utterance] += 1 }
      stream.on_error do |error|
        puts "The following error occurred while streaming: #{error}"
      end

      stream.send File.read(filepath, mode: "rb")

      stream.stop

      stream.wait_until_complete!

      results = stream.results

      results.count.must_equal 1
      results.first.transcript.must_equal "how old is the Brooklyn Bridge"
      results.first.confidence.must_be_close_to 0.9, 0.1
      results.first.alternatives.must_be :empty?

      counters[:interim].must_be :>, 0
      counters[:result].must_equal 1
      counters[:complete].must_equal 1
      counters[:utterance].must_be :zero?
    end

    it "sends multiple times" do
      counters = Hash.new { |h, k| h[k] = 0 }

      stream = speech.stream encoding: :linear16, sample_rate: 16000, language: "en-US", interim: true

      stream.on_interim      { counters[:interim] += 1 }
      stream.on_result       { counters[:result] += 1 }
      stream.on_complete     { counters[:complete] += 1 }
      stream.on_utterance    { counters[:utterance] += 1 }
      stream.on_error do |error|
        puts "The following error occurred while streaming: #{error}"
      end

      file = File.open filepath, "rb"

      # simulate a live stream, by sending a second at a time
      until file.eof?
        stream.send file.read(32000) # about a seconds worth of data
        sleep 1
      end

      stream.stop

      stream.wait_until_complete!

      results = stream.results

      results.count.must_equal 1
      results.first.transcript.must_equal "how old is the Brooklyn Bridge"
      results.first.confidence.must_be_close_to 0.9, 0.1
      results.first.alternatives.must_be :empty?

      counters[:interim].must_be :>, 0
      counters[:result].must_equal 1
      counters[:complete].must_equal 1
      counters[:utterance].must_be :zero?
    end
  end

  describe "utterance" do
    it "default params" do
      counters = Hash.new { |h, k| h[k] = 0 }

      stream = speech.stream encoding: :linear16, sample_rate: 16000, language: "en-US", utterance: true

      stream.on_interim      { counters[:interim] += 1 }
      stream.on_result       { counters[:result] += 1 }
      stream.on_complete     { counters[:complete] += 1 }
      stream.on_utterance    { counters[:utterance] += 1 }
      stream.on_error do |error|
        puts "The following error occurred while streaming: #{error}"
      end

      stream.send File.read(filepath, mode: "rb")

      # send 5 seconds of silence to kick off the utterance callback
      silent_frame = Array(0).pack("s<").encode("ASCII-8BIT")
      silent_second = silent_frame * 1600
      5.times do
        stream.send silent_second
        sleep 1
      end

      stream.stop

      stream.wait_until_complete!

      results = stream.results

      results.count.must_equal 1
      results.first.transcript.must_equal "how old is the Brooklyn Bridge"
      results.first.confidence.must_be_close_to 0.9, 0.1
      results.first.alternatives.must_be :empty?

      counters[:interim].must_equal 0
      counters[:result].must_equal 1
      counters[:complete].must_equal 1
      counters[:utterance].must_be :>=, 0
    end

    it "sends multiple times" do
      counters = Hash.new { |h, k| h[k] = 0 }

      stream = speech.stream encoding: :linear16, sample_rate: 16000, language: "en-US", utterance: true

      stream.on_interim      { counters[:interim] += 1 }
      stream.on_result       { counters[:result] += 1 }
      stream.on_complete     { counters[:complete] += 1 }
      stream.on_utterance    { counters[:utterance] += 1 }
      stream.on_error do |error|
        puts "The following error occurred while streaming: #{error}"
      end

      file = File.open filepath, "rb"

      # simulate a live stream, by sending a second at a time
      until file.eof?
        stream.send file.read(32000) # about a seconds worth of data
        sleep 1
      end
      # send 5 seconds of silence to kick off the utterance callback
      silent_frame = Array(0).pack("s<").encode("ASCII-8BIT")
      silent_second = silent_frame * 1600
      5.times do
        stream.send silent_second
        sleep 1
      end

      stream.stop

      stream.wait_until_complete!

      results = stream.results

      results.count.must_equal 1
      results.first.transcript.must_equal "how old is the Brooklyn Bridge"
      results.first.confidence.must_be_close_to 0.9, 0.1
      results.first.alternatives.must_be :empty?

      counters[:interim].must_equal 0
      counters[:result].must_equal 1
      counters[:complete].must_equal 1
      counters[:utterance].must_be :>=, 0
    end
  end

  it "uses words" do
    counters = Hash.new { |h, k| h[k] = 0 }

    stream = speech.stream encoding: :linear16, sample_rate: 16000, language: "en-US", words: true

    stream.on_interim      { counters[:interim] += 1 }
    stream.on_result       { counters[:result] += 1 }
    stream.on_complete     { counters[:complete] += 1 }
    stream.on_utterance    { counters[:utterance] += 1 }
    stream.on_error do |error|
      puts "The following error occurred while streaming: #{error}"
    end

    stream.send File.read(filepath, mode: "rb")

    stream.stop

    stream.wait_until_complete!

    results = stream.results

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.9, 0.1
    results.first.words.wont_be :empty?
    results.first.words.map(&:word).must_equal %w{how old is the Brooklyn Bridge}
    results.first.alternatives.must_be :empty?

    counters[:interim].must_be :zero?
    counters[:result].must_equal 1
    counters[:complete].must_equal 1
    counters[:utterance].must_be :zero?
  end
end
