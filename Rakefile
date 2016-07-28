require "bundler"

desc "Runs tests for all gems."
task :test do
  gems.each do |gem|
    $LOAD_PATH.unshift "#{gem}/lib", "#{gem}/test"
    Dir.glob("#{gem}/test/**/*_test.rb").each { |file| require_relative file }
    $LOAD_PATH.delete "#{gem}/lib"
    $LOAD_PATH.delete "#{gem}/test"
  end
end

namespace :test do
  desc "Runs tests for all gems individually."
  task :each do
    gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          header "BUNDLE UPDATE FOR #{gem}"
          sh "bundle update"

          header "TESTS FOR #{gem}"
          sh "bundle exec rake test"
        end
      end
    end
  end

  desc "Runs tests with coverage for all gems."
  task :coverage do
    FileUtils.remove_dir "coverage", force: true
    FileUtils.mkdir "coverage"

    require "simplecov"
    SimpleCov.start do
      command_name :coverage
      track_files "lib/**/*.rb"
      add_filter "test/"
      gems.each { |gem| add_group gem, "#{gem}/lib" }
    end

    Rake::Task["test"].invoke
  end

  desc "Runs tests with coverage for all gems."
  task :coveralls do
    FileUtils.remove_dir "coverage", force: true
    FileUtils.mkdir "coverage"

    require "simplecov"
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
    SimpleCov.start do
      command_name :coveralls
      track_files "lib/**/*.rb"
      add_filter "test/"
      gems.each { |gem| add_group gem, "#{gem}/lib" }
    end

    Rake::Task["test"].invoke
  end
end

task :travis do
  Rake::Task["test:coveralls"].invoke
end

def gems
  `git ls-files -- */*.gemspec`.split("\n").map { |gem| gem.split("/").first }.sort
end

def header str
  line_length = str.length + 8
  puts ""
  puts "#" * line_length
  puts "### #{str} ###"
  puts "#" * line_length
  puts ""
end

task :default => :test
