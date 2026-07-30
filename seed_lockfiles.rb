#!/usr/bin/env ruby
# seed_lockfiles.rb
#
# Usage:
#   ruby seed_lockfiles.rb --continue --size 15 --push

require 'optparse'
require 'fileutils'

options = {
  batch_index: 0,
  batch_size: 15,
  auto_continue: false,
  push: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby seed_lockfiles.rb [options]"

  opts.on("-s", "--size N", Integer, "Number of libraries in the batch (default: 15)") do |s|
    options[:batch_size] = s
  end

  opts.on("-i", "--index N", Integer, "Manual batch index (0-indexed)") do |i|
    options[:batch_index] = i
  end

  opts.on("-c", "--continue", "Automatically resume from the first unseeded library") do
    options[:auto_continue] = true
  end

  opts.on("-p", "--push", "Create a branch, commit (but do not push automatically to allow review)") do
    options[:push] = true
  end
end.parse!

# 1. Discover all libraries
all_gems = Dir.glob("*/").map { |d| d.chomp('/') }.select do |dir|
  File.exist?(File.join(dir, "#{dir}.gemspec"))
end.sort

# 2. Filter unseeded & eligible libraries
unseeded_gems = all_gems.select do |dir|
  # Skip if it already has a lockfile physically present
  next false if File.exist?(File.join(dir, "Gemfile.lock"))
  
  # Skip if Gemfile.lock is still listed inside this gem's .gitignore
  gitignore_path = File.join(dir, ".gitignore")
  if File.exist?(gitignore_path)
    is_ignored = File.readlines(gitignore_path).any? { |line| line.strip == "Gemfile.lock" }
    next false if is_ignored
  end
  
  true
end

puts "🔍 [Seeder] Found #{unseeded_gems.size} eligible libraries (no lockfile AND not .gitignored)"

if unseeded_gems.empty?
  puts "🎉 All eligible libraries have been seeded!"
  exit 0
end

if options[:auto_continue]
  puts "⏭️  [Seeder] --continue flag detected."
  options[:batch_index] = 0
end

start_offset = options[:batch_index] * options[:batch_size]
batch_gems = unseeded_gems[start_offset, options[:batch_size]]

if batch_gems.nil? || batch_gems.empty?
  puts "❌ [Seeder] Batch index #{options[:batch_index]} is out of bounds!"
  exit 1
end

branch_name = "chore/seed-lockfiles-#{Time.now.to_i}"
puts "📦 [Seeder] Batch targets #{batch_gems.size} gems:"
batch_gems.each { |g| puts "   - #{g}" }

# 3. Create branch if requested
if options[:push]
  system("git checkout main && git pull", exception: true)
  system("git checkout -b #{branch_name}", exception: true)
end

# 4. Generate lockfiles SEQUENTIALLY
platforms = %w[ruby x86_64-linux x86_64-darwin arm64-darwin x64-mingw-ucrt x64-mingw32]
platform_args = platforms.map { |p| "--add-platform #{p}" }.join(" ")

batch_gems.each_with_index do |gem_name, i|
  puts "⏳ [#{i + 1}/#{batch_gems.size}] Seeding #{gem_name}..."

  Dir.chdir(gem_name) do
    # Run bundle lock synchronously 
    system("bundle lock #{platform_args}", exception: true)
  end

  # Stage the file sequentially so we safely avoid Git index lock conflicts
  system("git add #{gem_name}/Gemfile.lock", exception: true) if options[:push]
end

# 5. Commit if requested
if options[:push]
  commit_msg = "chore(lockfiles): seed Gemfile.lock for #{batch_gems.size} libraries\n\nGems included in this batch:\n" + batch_gems.map { |g| "- #{g}" }.join("\n")
  File.write(".git/COMMIT_EDITMSG", commit_msg)
  system("git commit -F .git/COMMIT_EDITMSG", exception: true)
  File.delete(".git/COMMIT_EDITMSG")

  puts "\n✅ Batch committed to local branch #{branch_name}!"
  puts "👉 You can now review the commit and push it:"
  puts "    git push -u origin #{branch_name}"
else
  puts "\n✅ Batch seeded locally. Run with --push to automatically branch and commit."
end
