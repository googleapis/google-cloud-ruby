# frozen_string_literal: true

# Copyright 2022 Google LLC
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

##
# A utility module that loads and introspects well-formed samples.
# This is useful for testing samples and running them from a CLI.
#
# ## Usage
#
# This module expects to be run with the current directory within one of the
# library directories (i.e. it will not work from the repository root).
#
# * Get a list of sample files present in the current library using
#   `SampleLoader.list`
# * Get info for a sample using `SampleLoader.load("filename.rb")`.
# * The returned sample object provides a variety of information, including:
#     * The full text of the sample.
#     * Information on the parameters taken by the sample method.
#     * Ability to run the sample.
#
# SampleLoader loads each sample method in a unique class to avoid conflicts
# between samples as well as conflicts with other methods in the system.
#
module SampleLoader
  @samples = {}

  ##
  # Namespace under which all sample classes will live
  #
  module Classes
  end

  ##
  # Info about a single sample file. This may represent an actual well-formed
  # sample (in which case `well_formed?` will return `true`) or not (in which
  # case `well_formed?` will return `false`).
  #
  # Do not construct this object directly. Use {SampleLoader.load}.
  #
  class Sample
    # @private
    def initialize filename
      @file_name = filename
    end

    ##
    # The file path of a sample relative to the samples directory.
    #
    # @return [String]
    #
    attr_reader :file_name

    ##
    # The absolute path to the sample.
    #
    # @return [String]
    #
    def file_path
      @file_path ||= File.join SampleLoader.samples_dir, file_name
    end

    ##
    # An array of strings representing the parts of the path to a sample.
    # For example, the sample `foo/bar_baz.rb` will have segments
    # `["foo", "bar_baz"]`.
    #
    # @return [Array<String>]
    #
    def name_segments
      @name_segments ||= begin
        segs = file_name.gsub(%r{^/+|/+$}, "").split("/")
        segs.push File.basename segs.pop, ".rb"
        segs
      end
    end
  
    ##
    # The method name of a sample. This is equal to the last name segment.
    #
    # @return [String]
    #
    def method_name
      name_segments.last
    end

    ##
    # The original sample code as loaded from the sample file. There is no
    # guarantee that the sample is actually well-formed (see {well_formed?}).
    # Returns the empty string if the sample file couldn't be read at all.
    #
    # @return [String]
    #
    def sample_text
      @sample_text ||= File.read file_path rescue ""
    end

    ##
    # A class containing the sample as loaded from the file. There is no
    # guarantee that the sample is actually well-formed (see {well_formed?}).
    #
    # @return [Class]
    #
    def sample_class
      @sample_class ||= begin
        klass = SampleLoader::Classes
        name_segments.map { |seg| camelize seg }.each_with_index do |name, index|
          type = index == name_segments.size - 1 ? Class : Module
          klass = traverse_name klass, name, type
        end
        bind = klass.class_eval { binding }
        begin
          eval sample_text, bind, file_path
        rescue StandardError, ScriptError
          # Just fails to create whatever sample stuff is expected.
        end
        klass
      end
    end

    ##
    # Get the names of the keyword arguments taken by the sample.
    #
    # @return [Array<Symbol>]
    #
    def param_names
      @param_names ||=
        if well_formed?
          sample_class.instance_method(method_name)
                      .parameters
                      .select { |param| [:keyreq, :key].include? param.first }
                      .map(&:last)
        else
          []
        end
    end

    ##
    # Return the type expected by the given parameter name, obtained from the
    # yardoc comments associated with the sample method.
    #
    # @param name [Symbol] The parameter name
    # @return [String] if the given name is actually a parameter
    # @return [nil] if the given name is not a parameter
    #
    def param_type name
      name = name.to_sym
      return nil unless param_names.include? name
      parse_yardoc
      param = @parameters.find { |parameter| parameter[0] == name }
      param ? param[1] : "String"
    end

    ##
    # Return the description of the parameter, obtained from the yardoc comments
    # associated with the sample method.
    #
    # @param name [Symbol] The parameter name
    # @return [String] if the given name is actually a parameter
    # @return [nil] if the given name is not a parameter
    #
    def param_desc name
      name = name.to_sym
      return nil unless param_names.include? name
      parse_yardoc
      param = @parameters.find { |parameter| parameter[0] == name }
      param ? param[2] : "Value for the #{name} input"
    end

    ##
    # Return a description of the sample from yardoc comments.
    #
    # @return [String]
    #
    def description
      parse_yardoc
      @description
    end

    ##
    # Whether this sample exists and is well-formed. If this method returns
    # false, the sample cannot be run.
    #
    # @return [boolean]
    #
    def well_formed?
      sample_class.public_method_defined? method_name, false
    end

    ##
    # Instantiate the sample class and run the sample, passing the given params.
    #
    # @param params [keywords] keyword arguments to pass to the sample. Must
    #     match the keyword arguments accepted by the sample method.
    # @raises RuntimeError if the sample is not well-formed
    #
    def run **params
      raise "Sample #{file_name} is not well-formed" unless well_formed?
      sample_class.new.send method_name, **params
    end

    private

    def camelize name
      ::File.basename(name, ".rb").split("_").map(&:capitalize).join
    end

    def traverse_name mod, name, type
      if mod.const_defined? name
        cur = mod.const_get name
        return cur if type == Module && cur.is_a?(Module)
        num = 1
        orig_name = name
        while true
          name = "#{orig_name}__#{num}"
          break unless mod.const_defined? name
        end
      end
      obj = type.new
      mod.const_set name, obj
      obj
    end

    def parse_yardoc
      unless defined? @parameters
        @parameters = @description = ""
        if sample_text =~ /(?:^|\n)((?:\s*#[^\n]*\n)+)\s*def #{method_name}/
          cur_param = nil
          desc = []
          params = []
          Regexp.last_match[1].split("\n").each do |line|
            line = line.strip.gsub(/^#+\s?/, "")
            if line.start_with? "@"
              params << cur_param if cur_param
              cur_param = false
              if line =~ /^@param\s+(\w+)\s+\[(.+)\](?:\s+(.+))?/
                match = Regexp.last_match
                name = match[1].to_sym
                cur_param = [name, match[2], [match[3] || ""]] if param_names.include? name
              end
            elsif !line.empty?
              if cur_param
                cur_param[2] << line
              elsif cur_param.nil?
                desc << line
              end
            end
          end
          params << cur_param if cur_param
          @description = desc.join " "
          @parameters = params.map { |param| [param[0], param[1], param[2].join(" ")] }
        end
      end
    end
  end

  class << self
    ##
    # Returns all the potential samples found for this library. Generally, this
    # includes all Ruby files under the samples directory, omitting any files
    # under a directory called `acceptance`. It returns file paths relative to
    # the samples directory. Returns the empty array if there is no samples
    # directory or the current directory is not under a library directory.
    #
    # @return [Array<String>]
    #
    def list
      if samples_dir
        tentative = Dir.glob "**/*.rb", base: samples_dir
        tentative.delete_if { |filename| filename =~ %r{(^|/)acceptance/} }
      else
        []
      end
    end

    ##
    # Attempt to load the sample given a relative file path.
    # This always returns a Sample object. Check the object's `well_formed?`
    # method to determine whether the file is actually a well-formed sample.
    #
    # @param filename [String] Relative file path
    # @return [SampleLoader::Sample]
    #
    def load filename
      filename = filename.to_s
      filename = "#{filename}.rb" unless filename.end_with? ".rb"
      @samples[filename] ||= Sample.new filename
    end

    ##
    # Find the samples directory for the current library.
    #
    # @return [String] if the samples directory could be found.
    # @return [nil] if the samples directory could not be found.
    #
    def samples_dir
      unless defined? @samples_dir
        @samples_dir = nil
        base_dir = "#{File.dirname File.dirname __dir__}/"
        cur_dir = Dir.getwd
        if cur_dir.start_with? base_dir
          gem_name = cur_dir[base_dir.length..].split("/").first
          tentative_dir = File.join base_dir, gem_name, "samples"
          @samples_dir = tentative_dir if ::File.directory? tentative_dir
        end
      end
      @samples_dir
    end
  end
end
