desc "List built versions"

flag :latest_only
flag :single_line

include :exec, e: true

def run
  data = {}
  capture(["gsutil", "ls", "gs://docs-staging-v2"]).split("\n").each do |url|
    if url =~ %r{^gs://docs-staging-v2/docfx-ruby-(.+)-v(\d+\.\d+\.\d+)\.tar\.gz$}
      (data[Regexp.last_match[1]] ||= []) << Gem::Version.new(Regexp.last_match[2])
    end
  end
  data.transform_values! { |versions| versions.sort }
  data.transform_values! { |versions| [versions.last] } if latest_only
  output = []
  data.keys.sort.each do |gem_name|
    data[gem_name].each do |gem_version|
      output << "#{gem_name}:#{gem_version}"
    end
  end
  if single_line
    puts output.join " "
  else
    output.each { |line| puts line }
  end
end
