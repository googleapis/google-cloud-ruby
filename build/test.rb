require "pty"

command_groups = [
  ["rvm-exec 2.4.0 gem install bundler",
   "rvm-exec 2.4.0 bundle update",
   "rvm-exec 2.4.0 bundle exec rake circleci:build"],
  ["rvm-exec 2.3.1 gem install bundler",
   "rvm-exec 2.3.1 bundle update",
   "rvm-exec 2.3.1 bundle exec rake circleci:build"],
  ["rvm-exec 2.2.5 gem install bundler",
   "rvm-exec 2.2.5 bundle update",
   "rvm-exec 2.2.5 bundle exec rake circleci:build"],
  ["rvm rubygems current",
   "gem install bundler",
   "bundle update",
   "bundle exec rake circleci:build"],
  ["rvm-exec 2.0.0-p648 gem install bundler",
   "rvm-exec 2.0.0-p648 bundle update",
   "rvm-exec 2.0.0-p648 bundle exec rake circleci:build"]
]

node_index = Integer ENV["CIRCLE_NODE_INDEX"]
node_total = Integer ENV["CIRCLE_NODE_TOTAL"]

command_groups.each_with_index do |commands, index|
  # only run the commands that are for the current node
  if node_index == index % node_total
    begin
      commands.each do |command|
        PTY.spawn(command) do |stdout, _stdin, pid|
          begin
            stdout.each_char { |c| print c }
          rescue Errno::EIO
          end
          Process.wait(pid)
        end
        status = $?.exitstatus
        exit status if status && status != 0
      end
    rescue PTY::ChildExited
      puts "The test process exited."
    end
  end
end
