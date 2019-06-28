require "json"
require_relative "repo_doc_common.rb"

class RepoMetadata < RepoDocCommon
  def initialize data
    @data = data
    normalize_data!
  end

  def allowed_fields
    [
      "name", "version", "language", "distribution-name",
      "product-page", "github-repository", "issue-tracker"
    ]
  end

  def build output_directory
    fields = @data.to_a.map { |kv| "--#{kv[0]} #{kv[1]}" }
    Dir.chdir output_directory do
      cmd "python3 -m docuploader create-metadata #{fields.join ' '}"
    end
  end

  def normalize_data!
    # Required until distribution_name is changed to distribution-name
    @data.transform_keys! { |k| k.sub "_", "-" }
    @data["name"] = @data["distribution-name"]
    @data.delete_if { |k, _| !allowed_fields.include? k }
  end

  def [] key
    self.data[key]
  end

  def []= key, value
    @data[key] = value
  end

  def data
    Marshal.load Marshal.dump(@data)
  end

  def self.from_source source
    if source.is_a? RepoMetadata
      data = source.data
    elsif source.is_a? Hash
      data = source
    elsif File.file? source
      data = JSON.parse File.read(source)
    else
      raise "Source must be a path, hash, or RepoMetadata instance"
    end
    RepoMetadata.new data
  end
end
