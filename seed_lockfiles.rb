#!/usr/bin/env ruby
# seed_lockfiles.rb
#
# Usage:
#   ruby seed_lockfiles.rb --continue --size 25 --push

require 'optparse'
require 'fileutils'
require 'thread'

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

# 2. Filter unseeded libraries
unseeded_gems = all_gems.select do |dir|
  !File.exist?(File.join(dir, "Gemfile.lock"))
end

puts "🔍 [Seeder] Found #{unseeded_gems.size} libraries without a Gemfile.lock"

if unseeded_gems.empty?
  puts "🎉 All libraries have been seeded!"
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
puts "📦 [Seeder] Batch targets #{batch_gems.size} gems."

# 3. Create branch if requested
if options[:push]
  system("git checkout main && git pull", exception: true)
  system("git checkout -b #{branch_name}", exception: true)
end

# 4. Generate lockfiles CONCURRENTLY
# We use a thread-safe Queue and a Mutex to prevent terminal print interleaving
queue = Queue.new
batch_gems.each { |g| queue << g }
STDOUT_MUTEX = Mutex.new

platforms = %w[ruby x86_64-linux x86_64-darwin arm64-darwin x64-mingw-ucrt x64-mingw32]
platform_args = platforms.map { |p| "--add-platform #{p}" }.join(" ")

workers = 8.times.map do
  Thread.new do
    loop do
      # Non-blocking pop; raises ThreadError when the queue is identically empty
      gem_name = queue.pop(true) rescue break
      
      STDOUT_MUTEX.synchronize { puts "⏳ Seeding #{gem_name}..." }
      
      # Run bundle lock with all requested generic, Mac, and Windows platforms
      system("cd #{gem_name} && bundle lock #{platform_args}", exception: true)
      
      system("git add #{gem_name}/Gemfile.lock", exception: true) if options[:push]
    end
  end
end

# Await completion of all threads
workers.each(&:join)

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
