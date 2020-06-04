require "erb"

require_relative "command.rb"

class KokoroBuilder < Command
  attr_reader :ruby_versions, :gems

  def initialize ruby_versions, gems
    @ruby_versions         = ruby_versions
    @gems                  = gems
    @dockerfiles           = ["autosynth", "multi", "release"]
    @dependent_dockerfiles = ["multi-node"]
  end

  def build
    remove_old_ruby_versions
    build_kokoro_configs
    generate_dockerfiles
  end

  def publish
    (@dockerfiles + @dependent_dockerfiles).each do |docker_image|
      Dir.chdir "./.kokoro/docker/#{docker_image}" do
        image_tag = "gcr.io/cloud-devrel-kokoro-resources/yoshi-ruby/#{docker_image}"
        run "docker build -t #{image_tag} ."
        run "docker push #{image_tag}"
      end
    end
  end

  def from_template template, output, gem: nil, base: nil, ruby_version: nil
    File.open output, "w" do |f|
      config = ERB.new File.read(template)
      f.write config.result(binding)
    end
  end

  def remove_old_ruby_versions
    files = Dir.glob "./.kokoro/**/*.cfg"
    files.select! { |file| file.match(/ruby_\d+\.\d+\.\d+\.cfg/) }
    files.each do |file|
      FileUtils.remove_file file
    end
  end

  def build_kokoro_configs
    gems.each do |gem|
      name = gem.split("google-cloud-").last
      build_types = [:continuous, :nightly]
      build_types << :samples_latest unless name =~ /-v\d\w*$/
      [:linux, :windows, :osx].each do |os_version|
        build_types.each do |build_type|
          from_template "./.kokoro/templates/#{os_version}.cfg.erb",
                        "./.kokoro/#{build_type}/#{os_version}/#{name}.cfg",
                        gem: gem
        end
      end
      from_template "./.kokoro/templates/release.cfg.erb",
                    "./.kokoro/release/#{name}.cfg",
                    gem: gem
    end
    KOKORO_RUBY_VERSIONS.each do |ruby_version|
      from_template "./.kokoro/templates/linux.cfg.erb",
                    "./.kokoro/samples_presubmit/linux/ruby_#{ruby_version}.cfg",
                    ruby_version: ruby_version
    end
    from_template "./.kokoro/templates/linux.cfg.erb",
                  "./.kokoro/continuous/linux/post.cfg",
                  gem: "post"
    from_template "./.kokoro/templates/release.cfg.erb",
                  "./.kokoro/release/republish.cfg",
                  gem: "republish"
    from_template "./.kokoro/templates/osx.sh.erb",
                  "./.kokoro/osx.sh"
    from_template "./.kokoro/templates/trampoline.sh.erb",
                  "./.kokoro/trampoline.sh"
  end

  def generate_dockerfiles
    @dockerfiles.each do |docker_image|
      from_template "./.kokoro/templates/#{docker_image}.Dockerfile.erb",
                    "./.kokoro/docker/#{docker_image}/Dockerfile"
    end
  end
end
