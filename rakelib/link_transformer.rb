# finds markdown files and tranforms markdown links into yard links
class LinkTransformer

  def find_markdown_files
    Dir.glob("*.md")
  end

  # read and tranform links in markdown files 
  def transform_links_in_files(files)

    files.each do |filename|
      text = File.read(filename)
      content = transform_links_in_text(text)
      File.open(filename, "w") {|file| file << content}
    end
  end

  def transform_links_in_text(text)
    text.gsub(/\[([^\]]*)\]\(([^)]*\.md)\)/, "{file:\\2 \\1}")
  end

end